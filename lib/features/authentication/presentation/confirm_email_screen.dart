import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../application/session_controller.dart';
import '../domain/app_session.dart';
import '../domain/auth_failure.dart';
import 'widgets/auth_layout.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  const ConfirmEmailScreen({super.key});

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  bool _submitting = false;
  String? _message;
  String? _error;

  Future<void> _resend(String email) async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
      _message = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .resendSignupEmail(email);
      if (!mounted) {
        return;
      }
      setState(() => _message = 'A new confirmation email is on its way.');
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final email =
        session is AppSessionNeedsEmailConfirmation
            ? session.email
            : 'your email';

    return AuthLayout(
      title: 'Confirm your email',
      subtitle:
          'This Supabase project requires email confirmation. Open the link sent to $email, then return to Kgwebo.',
      footer: KgweboButton(
        label: 'Back to sign in',
        variant: KgweboButtonVariant.text,
        expanded: true,
        onPressed: () => context.go(AppRoutes.signIn),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null)
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: _error!,
            ),
          if (_message != null)
            KgweboStatusBanner(tone: KgweboBannerTone.info, message: _message!),
          const SizedBox(height: 16),
          KgweboButton(
            label: 'Resend confirmation email',
            expanded: true,
            isLoading: _submitting,
            onPressed: _submitting ? null : () => _resend(email),
          ),
        ],
      ),
    );
  }
}
