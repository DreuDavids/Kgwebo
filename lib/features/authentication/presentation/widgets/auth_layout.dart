import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_elevation.dart';
import '../../../../app/theme/kgwebo_radii.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../shared/widgets/kgwebo_brand_mark.dart';

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
      backgroundColor: KgweboColors.canvas,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
