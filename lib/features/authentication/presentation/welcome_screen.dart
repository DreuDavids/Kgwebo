import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../shared/widgets/kgwebo_brand_mark.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_wash_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _bullets = [
    'Record sales and expenses in one place.',
    'See the cash you actually have.',
    'Know which bills are coming due.',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return KgweboWashScaffold(
      header: const KgweboBrandMark(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          KgweboSpacing.lg,
          KgweboSpacing.md,
          KgweboSpacing.lg,
          KgweboSpacing.md,
        ),
        children: [
          Text(
            'See your business clearly.',
            style: textTheme.displayMedium?.copyWith(color: KgweboColors.ink),
          ),
          const SizedBox(height: KgweboSpacing.md),
          Text(
            'Your business. Clearer decisions. Stronger growth.',
            style: textTheme.titleMedium?.copyWith(
              color: KgweboColors.inkMuted,
            ),
          ),
          const SizedBox(height: KgweboSpacing.lg),
          for (final bullet in _bullets) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: KgweboSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: KgweboColors.ink,
                    ),
                  ),
                  const SizedBox(width: KgweboSpacing.sm),
                  Expanded(
                    child: Text(
                      bullet,
                      style: textTheme.bodyLarge?.copyWith(
                        color: KgweboColors.ink,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KgweboButton(
            label: 'Create an account',
            expanded: true,
            onPressed: () => context.go(AppRoutes.signUp),
          ),
          KgweboButton(
            label: 'I already have an account',
            expanded: true,
            variant: KgweboButtonVariant.text,
            onPressed: () => context.go(AppRoutes.signIn),
          ),
        ],
      ),
    );
  }
}
