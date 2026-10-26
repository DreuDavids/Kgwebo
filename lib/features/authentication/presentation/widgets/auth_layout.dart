import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_elevation.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../shared/widgets/kgwebo_brand_mark.dart';
import '../../../../shared/widgets/kgwebo_illustration.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.showMark = true,
    this.showIllustration = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final bool showMark;
  final bool showIllustration;

  static const double _illustrationMinHeight = 620;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: KgweboColors.canvas,
      body: SafeArea(
        child: KgweboContentConstraint(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final illustrationVisible =
                  showIllustration &&
                  bottom < 48 &&
                  constraints.maxHeight >= _illustrationMinHeight;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      KgweboSpacing.md,
                      KgweboSpacing.lg,
                      KgweboSpacing.md,
                      illustrationVisible ? KgweboSpacing.sm : KgweboSpacing.xl,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showMark) ...[
                            const KgweboBrandMark(),
                            const SizedBox(height: KgweboSpacing.lg),
                          ],
                          Text(
                            title,
                            style: textTheme.displayMedium?.copyWith(
                              color: KgweboColors.ink,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: KgweboSpacing.sm),
                            Text(
                              subtitle!,
                              style: textTheme.bodyLarge?.copyWith(
                                color: KgweboColors.inkMuted,
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: KgweboSpacing.xl),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              color: KgweboColors.surface,
                              borderRadius: KgweboRadii.borderXl,
                              boxShadow: KgweboElevation.soft,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(KgweboSpacing.lg),
                              child: child,
                            ),
                          ),
                          if (footer != null) ...[
                            const SizedBox(height: KgweboSpacing.lg),
                            footer!,
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (illustrationVisible)
                    const SliverFillRemaining(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          KgweboSpacing.md,
                          KgweboSpacing.xs,
                          KgweboSpacing.md,
                          KgweboSpacing.md,
                        ),
                        child: KgweboIllustration(
                          asset: KgweboIllustrationAssets.authScene,
                          maxHeight: 240,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    )
                  else
                    SliverPadding(padding: EdgeInsets.only(bottom: bottom)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
