import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';

/// Compact line from real values. Renders nothing when there are fewer than
/// two points so preview and empty states never show a fake chart.
class KgweboSparkline extends StatelessWidget {
  const KgweboSparkline({
    super.key,
    required this.values,
    this.color = KgweboColors.lime,
    this.height = 36,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(height: height);
    }
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) {
      return;
    }
    var min = values.first;
    var max = values.first;
    for (final value in values) {
      if (value < min) {
        min = value;
      }
      if (value > max) {
        max = value;
      }
    }
    final span = max - min;
    final stepX = size.width / (values.length - 1);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = stepX * i;
      final t = span == 0 ? 0.5 : (values[i] - min) / span;
      final y = size.height - (t * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
