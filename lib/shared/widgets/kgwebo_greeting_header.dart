import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';

/// Home header with a short hello and the business name.
class KgweboGreetingHeader extends StatelessWidget {
  const KgweboGreetingHeader({super.key, this.businessName, this.subtitle});

  final String? businessName;
  final String? subtitle;

  static const tagline = 'Your business. Clearer decisions. Stronger growth.';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedSubtitle = subtitle ?? tagline;
    final name = businessName?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: textTheme.displayMedium,
            children: [
              TextSpan(
                text: 'Hello,',
                style: textTheme.displayMedium?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
              if (name != null && name.isNotEmpty)
                TextSpan(
                  text: ' $name',
                  style: textTheme.displayMedium?.copyWith(
                    color: KgweboColors.ink,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: KgweboSpacing.sm),
        Text(
          resolvedSubtitle,
          style: textTheme.titleMedium?.copyWith(color: KgweboColors.inkMuted),
        ),
      ],
    );
  }
}
