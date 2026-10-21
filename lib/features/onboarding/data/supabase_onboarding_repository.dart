import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/validation/onboarding_validators.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/onboarding_repository.dart';
import '../domain/business_profile.dart';
import '../domain/onboarding_draft.dart';

class SupabaseOnboardingRepository extends OnboardingRepository {
  SupabaseOnboardingRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'businesses';

  String? get _ownerId => _client.auth.currentUser?.id;

  @override
  Future<BusinessProfile?> findOwnedBusiness() async {
    try {
      final userId = _ownerId;
      if (userId == null) {
        return null;
      }
      final row =
          await _client
              .from(_table)
              .select()
              .eq('owner_id', userId)
              .maybeSingle();
      if (row == null) {
        return null;
      }
      final profile = BusinessProfile.fromMap(row);
      if (!profile.belongsTo(userId)) {
        throw const AuthFailure(
          'This business does not belong to the signed-in account.',
        );
      }
      return profile;
    } catch (error) {
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessProfile> save(OnboardingDraft draft) async {
    final userId = _requireOwnerId();
    final payload = _payload(draft);
    try {
      final existing = await findOwnedBusiness();
      if (existing != null) {
        return _updateRow(
          businessId: existing.id,
          ownerId: userId,
          payload: payload,
        );
      }
      final inserted =
          await _client.from(_table).insert(payload).select().single();
      return _owned(BusinessProfile.fromMap(inserted), userId);
    } catch (error) {
      if (error is PostgrestException && error.code == '23505') {
        final existing = await findOwnedBusiness();
        if (existing != null) {
          return _updateRow(
            businessId: existing.id,
            ownerId: userId,
            payload: payload,
          );
        }
      }
      throw _mapError(error);
    }
  }

  @override
  Future<BusinessProfile> updateExisting({
    required String businessId,
    required OnboardingDraft draft,
  }) {
    final userId = _requireOwnerId();
    return _updateRow(
      businessId: businessId,
      ownerId: userId,
      payload: _payload(draft),
    );
  }

  Map<String, dynamic> _payload(OnboardingDraft draft) {
    return draft.toWriteMap(
      openingBalanceMinor: parseOpeningBalanceMinor(draft.openingCashText),
    );
  }

  Future<BusinessProfile> _updateRow({
    required String businessId,
    required String ownerId,
    required Map<String, dynamic> payload,
  }) async {
    assert(!payload.containsKey('owner_id'));
    try {
      final updated =
          await _client
              .from(_table)
              .update(payload)
              .eq('id', businessId)
              .eq('owner_id', ownerId)
              .select()
              .maybeSingle();
      if (updated == null) {
        throw const AuthFailure(
          'Could not update this business. It may not exist or you may not own it.',
        );
      }
      return _owned(BusinessProfile.fromMap(updated), ownerId);
    } catch (error) {
      throw _mapError(error);
    }
  }

  BusinessProfile _owned(BusinessProfile profile, String ownerId) {
    if (!profile.belongsTo(ownerId)) {
      throw const AuthFailure(
        'This business does not belong to the signed-in account.',
      );
    }
    return profile;
  }

  String _requireOwnerId() {
    final userId = _ownerId;
    if (userId == null) {
      throw AuthFailure.fromCode('session_expired');
    }
    return userId;
  }

  AuthFailure _mapError(Object error) {
    if (error is AuthFailure) {
      return error;
    }
    if (error is PostgrestException) {
      return AuthFailure.fromMessage(error.message);
    }
    if (error is SocketException ||
        error is TimeoutException ||
        error is AuthRetryableFetchException) {
      return const AuthFailure.network();
    }
    return AuthFailure.fromMessage(error.toString());
  }
}
