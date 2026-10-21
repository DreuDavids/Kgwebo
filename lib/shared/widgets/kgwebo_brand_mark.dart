import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';
import '../../app/theme/kgwebo_typography.dart';

/// Compact Kgwebo mark. Fraunces is used only for the letter K.
class KgweboBrandMark extends StatelessWidget {
  const KgweboBrandMark({super.key, this.showName = true, this.onDark = false});

  final bool showName;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameColor = onDark ? KgweboColors.onInk : KgweboColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: onDark ? KgweboColors.heroWell : KgweboColors.ink,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('K', style: KgweboTypography.brandMark),
        ),
        if (showName) ...[
          const SizedBox(width: KgweboSpacing.sm),
          Text(
            'Kgwebo',
            style: textTheme.titleLarge?.copyWith(color: nameColor),
          ),
        ],
      ],
    );
  }
}
