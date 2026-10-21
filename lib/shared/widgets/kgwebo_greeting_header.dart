import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';
import '../../core/finance/business_calendar.dart';

/// Time-of-day greeting used on home and similar product screens.
class KgweboGreetingHeader extends StatelessWidget {
  const KgweboGreetingHeader({
    super.key,
    this.businessName,
    this.subtitle,
    this.now,
  });

  final String? businessName;
  final String? subtitle;
  final DateTime? now;

  static const tagline = 'Your business. Clearer decisions. Stronger growth.';

  static String greetingFor(DateTime utcNow) {
    final hour = BusinessCalendar.gaboroneWallTime(utcNow).hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final greeting = greetingFor(now ?? DateTime.now().toUtc());
    final resolvedSubtitle = subtitle ?? tagline;
    final headline = businessName ?? greeting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello,',
          style: textTheme.titleMedium?.copyWith(color: KgweboColors.inkMuted),
        ),
        Text(
          headline,
          style: textTheme.displayMedium?.copyWith(color: KgweboColors.ink),
        ),
        if (businessName != null) ...[
          const SizedBox(height: KgweboSpacing.xxs),
          Text(
            greeting,
            style: textTheme.titleMedium?.copyWith(
              color: KgweboColors.inkMuted,
            ),
          ),
          const SizedBox(height: KgweboSpacing.xxs),
          Text(
            'Totals come from saved records, not estimates.',
            style: textTheme.bodyMedium?.copyWith(
              color: KgweboColors.inkMuted,
              height: 1.45,
            ),
          ),
        ],
        const SizedBox(height: KgweboSpacing.sm),
        Text(
          resolvedSubtitle,
          style: textTheme.titleMedium?.copyWith(color: KgweboColors.inkMuted),
        ),
      ],
    );
  }
}
