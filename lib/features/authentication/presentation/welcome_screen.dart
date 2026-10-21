import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_radii.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../app/theme/kgwebo_typography.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';

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
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final last = _step == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: KgweboContentConstraint(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              KgweboSpacing.md,
              KgweboSpacing.lg,
              KgweboSpacing.md,
              KgweboSpacing.lg + bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: KgweboColors.forest,
                        borderRadius: KgweboRadii.borderMd,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'K',
                        style: textTheme.titleLarge?.copyWith(
                          fontFamily: KgweboTypography.serif,
                          color: KgweboColors.onForest,
                        ),
                      ),
                    ),
                    const SizedBox(width: KgweboSpacing.sm),
                    Text(
                      'Kgwebo',
                      style: textTheme.titleLarge?.copyWith(
                        color: KgweboColors.forest,
                      ),
                    ),
                    const Spacer(),
                    if (!last)
                      KgweboButton(
                        label: 'Skip',
                        variant: KgweboButtonVariant.text,
                        onPressed: () => context.go(AppRoutes.signUp),
                      ),
                  ],
                ),
                const SizedBox(height: KgweboSpacing.xl),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: textTheme.displayMedium?.copyWith(
                            fontFamily: KgweboTypography.serif,
                            color: KgweboColors.forest,
                          ),
                        ),
                        const SizedBox(height: KgweboSpacing.md),
                        Text(
                          'Your business. Clearer decisions. Stronger growth.',
                          style: textTheme.titleMedium?.copyWith(
                            color: KgweboColors.teal,
                          ),
                        ),
                        const SizedBox(height: KgweboSpacing.lg),
                        Text(
                          page.body,
                          style: textTheme.bodyLarge?.copyWith(height: 1.55),
                        ),
                      ],
                    ),
                  ),
                ),
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
                            color:
                                i == _step
                                    ? KgweboColors.forest
                                    : KgweboColors.line,
                            borderRadius: KgweboRadii.borderSm,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: KgweboSpacing.lg),
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
          ),
        ),
      ),
    );
  }
}
