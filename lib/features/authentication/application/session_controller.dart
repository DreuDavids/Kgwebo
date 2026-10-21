import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../app/config/app_environment.dart';
import '../../../app/config/config_providers.dart';
import '../../../app/supabase/kgwebo_supabase.dart';
import '../../../core/persistence/business_cache.dart';
import '../../../core/persistence/kgwebo_database.dart';
import '../../onboarding/application/onboarding_repository.dart';
import '../../onboarding/data/cached_onboarding_repository.dart';
import '../../onboarding/data/preview_onboarding_repository.dart';
import '../../onboarding/data/supabase_onboarding_repository.dart';
import '../../onboarding/domain/business_profile.dart';
import '../../onboarding/domain/onboarding_draft.dart';
import '../data/preview_auth_repository.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/app_session.dart';
import '../domain/auth_change.dart';
import '../domain/auth_failure.dart';
import '../domain/auth_user.dart';
import '../domain/sign_up_result.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.connectsToBackend) {
    return PreviewAuthRepository(config.runtimeMode);
  }
  return SupabaseAuthRepository(kgweboSupabase);
});

final kgweboDatabaseProvider = Provider<KgweboDatabase>((ref) {
  final database = KgweboDatabase();
  ref.onDispose(database.close);
  return database;
});

final businessCacheProvider = Provider<BusinessCache>((ref) {
  return BusinessCache(ref.watch(kgweboDatabaseProvider));
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.connectsToBackend) {
    return PreviewOnboardingRepository();
  }
  return CachedOnboardingRepository(
    remote: SupabaseOnboardingRepository(kgweboSupabase),
    cache: ref.watch(businessCacheProvider),
    currentOwnerId: () => kgweboSupabase.auth.currentUser?.id,
  );
});

final sessionControllerProvider =
    StateNotifierProvider<SessionController, AppSession>((ref) {
      return SessionController(
        config: ref.watch(appConfigProvider),
        auth: ref.watch(authRepositoryProvider),
        onboarding: ref.watch(onboardingRepositoryProvider),
      );
    });

final appSessionProvider = Provider<AppSession>((ref) {
  return ref.watch(sessionControllerProvider);
});

final currentOwnerIdProvider = Provider<String?>((ref) {
  return switch (ref.watch(appSessionProvider)) {
    AppSessionReady(:final user) => user.id,
    AppSessionNeedsOnboarding(:final user) => user.id,
    AppSessionFailure(:final user) => user?.id,
    AppSessionPasswordRecovery(:final user) => user.id,
    AppSessionNeedsEmailConfirmation(:final user) => user?.id,
    AppSessionPreview() ||
    AppSessionGuest() ||
    AppSessionLoading() ||
    AppSessionResolving() => null,
  };
});

class SessionController extends StateNotifier<AppSession> {
  SessionController({
    required AppConfig config,
    required AuthRepository auth,
    required OnboardingRepository onboarding,
  }) : _config = config,
       _auth = auth,
       _onboarding = onboarding,
       super(const AppSessionLoading()) {
    _start();
  }

  final AppConfig _config;
  final AuthRepository _auth;
  final OnboardingRepository _onboarding;
  StreamSubscription<AuthChange>? _subscription;
  int _generation = 0;
  bool _busy = false;

  bool get isBusy => _busy;

  void _start() {
    if (!_config.connectsToBackend) {
      state = AppSessionPreview(
        _config.runtimeMode == AppRuntimeMode.demo
            ? AppRuntimeMode.demo
            : AppRuntimeMode.local,
      );
      return;
    }
    _subscription = _auth.watch().listen(
      _onChange,
      onError: (_) {
        state = const AppSessionGuest();
      },
    );
  }

  Future<void> _onChange(AuthChange change) async {
    switch (change.kind) {
      case AuthChangeKind.signedOut:
      case AuthChangeKind.userDeleted:
        _generation++;
        state = const AppSessionGuest();
      case AuthChangeKind.passwordRecovery:
        final user = change.user;
        if (user != null) {
          state = AppSessionPasswordRecovery(user);
        }
      case AuthChangeKind.initial:
      case AuthChangeKind.signedIn:
      case AuthChangeKind.tokenRefreshed:
      case AuthChangeKind.userUpdated:
        await _resolve(change.user);
    }
  }

  Future<void> _resolve(AuthUser? user) async {
    if (user == null) {
      _generation++;
      state = const AppSessionGuest();
      return;
    }
    if (!user.emailConfirmed) {
      state = AppSessionNeedsEmailConfirmation(
        email: user.email ?? '',
        user: user,
      );
      return;
    }
    final generation = ++_generation;
    state = const AppSessionResolving();
    try {
      final snapshot = await _onboarding.loadOwnedBusiness();
      if (generation != _generation) {
        return;
      }
      if (snapshot == null || !snapshot.profile.isOnboardingComplete) {
        state = AppSessionNeedsOnboarding(user);
      } else {
        state = AppSessionReady(
          user: user,
          business: snapshot.profile,
          isStale: snapshot.isStale,
        );
      }
    } catch (error) {
      if (generation != _generation) {
        return;
      }
      state = AppSessionFailure(
        error is AuthFailure
            ? error.message
            : 'Could not load your business. Please try again.',
        user: user,
      );
    }
  }

  Future<void> signIn({required String email, required String password}) {
    return _run(() async {
      final user = await _auth.signIn(email: email, password: password);
      await _resolve(user);
    });
  }

  Future<void> signUp({required String email, required String password}) {
    return _run(() async {
      final result = await _auth.signUp(email: email, password: password);
      switch (result) {
        case SignUpConfirmationRequired(:final email):
          state = AppSessionNeedsEmailConfirmation(email: email);
        case SignUpSessionCreated(:final user):
          await _resolve(user);
      }
    });
  }

  Future<void> requestPasswordReset(String email) {
    return _run(() => _auth.requestPasswordReset(email));
  }

  Future<void> updatePassword(String password) {
    return _run(() async {
      await _auth.updatePassword(password);
      final user = await _auth.currentUser();
      await _resolve(user);
    });
  }

  Future<void> resendSignupEmail(String email) {
    return _run(() => _auth.resendSignupEmail(email));
  }

  Future<void> completeOnboarding(OnboardingDraft draft) {
    return _run(() async {
      final business = await _onboarding.save(draft);
      final user = switch (state) {
        AppSessionNeedsOnboarding(:final user) => user,
        AppSessionFailure(:final user) => user,
        AppSessionReady(:final user) => user,
        _ => await _auth.currentUser(),
      };
      if (user == null) {
        throw const AuthFailure('Sign in again to finish setup.');
      }
      state = AppSessionReady(user: user, business: business);
    });
  }

  void applyConfirmedBusiness(BusinessProfile business) {
    final current = state;
    if (current is! AppSessionReady) {
      return;
    }
    if (current.user.id != business.ownerId) {
      return;
    }
    state = AppSessionReady(user: current.user, business: business);
  }

  Future<void> retryOnboardingLoad() async {
    final user = switch (state) {
      AppSessionNeedsOnboarding(:final user) => user,
      AppSessionFailure(:final user) => user,
      AppSessionReady(:final user) => user,
      _ => await _auth.currentUser(),
    };
    await _resolve(user);
  }

  Future<void> signOut() {
    return _run(() async {
      await _auth.signOut();
      _generation++;
      state = const AppSessionGuest();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      await action();
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
