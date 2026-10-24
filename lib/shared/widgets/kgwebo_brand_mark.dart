import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';

/// Compact Kgwebo mark. Lime geometric K on a black disc, matching
/// `assets/brand/kgwebo-mark.svg`.
class KgweboBrandMark extends StatelessWidget {
  const KgweboBrandMark({super.key, this.showName = true, this.onDark = false});

  final bool showName;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nameColor = onDark ? KgweboColors.onInk : KgweboColors.ink;
    final discColor = onDark ? KgweboColors.heroWell : KgweboColors.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: showName ? null : 'Kgwebo',
          excludeSemantics: showName,
          child: SizedBox(
            width: 40,
            height: 40,
            child: CustomPaint(
              painter: _KgweboKMarkPainter(discColor: discColor),
            ),
          ),
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

/// Draws the canonical Well K: extra-round disc and three round-capped strokes.
class _KgweboKMarkPainter extends CustomPainter {
  const _KgweboKMarkPainter({
    required this.discColor,
    this.kColor = KgweboColors.lime,
  });

  final Color discColor;
  final Color kColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.shortestSide / 2),
      ),
      Paint()..color = discColor,
    );

    final stroke =
        Paint()
          ..color = kColor
          ..strokeWidth = 13 * scaleX
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    void line(double x1, double y1, double x2, double y2) {
      canvas.drawLine(
        Offset(x1 * scaleX, y1 * scaleY),
        Offset(x2 * scaleX, y2 * scaleY),
        stroke,
      );
    }

    line(36, 28, 36, 72);
    line(36, 50, 66, 30);
    line(36, 50, 66, 70);
  }

  @override
  bool shouldRepaint(_KgweboKMarkPainter oldDelegate) {
    return oldDelegate.discColor != discColor || oldDelegate.kColor != kColor;
  }
}
