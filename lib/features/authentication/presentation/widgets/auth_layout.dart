import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../app/theme/kgwebo_typography.dart';
import '../../../../core/responsive/responsive_layout.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.showMark = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final bool showMark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        child: KgweboContentConstraint(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  KgweboSpacing.md,
                  KgweboSpacing.lg,
                  KgweboSpacing.md,
                  KgweboSpacing.xl + bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - KgweboSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showMark) ...[
                        const _BrandMark(),
                        const SizedBox(height: KgweboSpacing.lg),
                      ],
                      Text(
                        title,
                        style: textTheme.displayMedium?.copyWith(
                          fontFamily: KgweboTypography.serif,
                          color: KgweboColors.forest,
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
                      child,
                      if (footer != null) ...[
                        const SizedBox(height: KgweboSpacing.lg),
                        footer!,
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: KgweboTypography.serif,
              color: KgweboColors.onForest,
            ),
          ),
        ),
        const SizedBox(width: KgweboSpacing.sm),
        Text(
          'Kgwebo',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: KgweboColors.forest),
        ),
      ],
    );
  }
}
