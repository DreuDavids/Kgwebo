import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_radii.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../shared/widgets/kgwebo_brand_mark.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_wash_scaffold.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _step = 0;

  static const _pages = [
    (
      title: 'Your business, clearly seen.',
      body:
          'Kgwebo helps informal traders and small retailers record activity, understand cash, and decide what to do next — without accounting software.',
    ),
    (
      title: 'Track what actually happened.',
      body:
          'Sales, expenses and stock belong in one place. Kgwebo turns those records into cash and profit you can trust, once you start saving them.',
    ),
    (
      title: 'See the next thirty days.',
      body:
          'When obligations are recorded, Kgwebo can show whether the cash you have is likely to cover what is coming due. Nothing is invented.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final page = _pages[_step];
    final last = _step == _pages.length - 1;

    return KgweboWashScaffold(
      header: Row(
        children: [
          const KgweboBrandMark(),
          const Spacer(),
          if (!last)
            KgweboButton(
              label: 'Skip',
              variant: KgweboButtonVariant.text,
              onPressed: () => context.go(AppRoutes.signUp),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          KgweboSpacing.lg,
          KgweboSpacing.md,
          KgweboSpacing.lg,
          KgweboSpacing.md,
        ),
        children: [
          Text(
            page.title,
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
          Text(
            page.body,
            style: textTheme.bodyLarge?.copyWith(
              color: KgweboColors.ink,
              height: 1.55,
            ),
          ),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < _pages.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: KgweboSpacing.xs),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _step ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _step ? KgweboColors.ink : KgweboColors.line,
                      borderRadius: KgweboRadii.borderPill,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: KgweboSpacing.md),
          KgweboButton(
            label: last ? 'Create an account' : 'Continue',
            expanded: true,
            onPressed: () {
              if (last) {
                context.go(AppRoutes.signUp);
              } else {
                setState(() => _step += 1);
              }
            },
          ),
          const SizedBox(height: KgweboSpacing.sm),
          if (_step > 0)
            KgweboButton(
              label: 'Back',
              expanded: true,
              variant: KgweboButtonVariant.secondary,
              onPressed: () => setState(() => _step -= 1),
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
