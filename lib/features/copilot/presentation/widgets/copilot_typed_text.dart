import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';

class CopilotTypedText extends StatefulWidget {
  const CopilotTypedText({
    super.key,
    required this.text,
    required this.style,
    required this.animate,
    this.onFinished,
  });

  final String text;
  final TextStyle? style;
  final bool animate;
  final VoidCallback? onFinished;

  @override
  State<CopilotTypedText> createState() => _CopilotTypedTextState();
}

class _CopilotTypedTextState extends State<CopilotTypedText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _notified = false;

  @override
  void initState() {
    super.initState();
    final chars = widget.text.length;
    final ms = widget.animate ? (chars * 16).clamp(350, 2800) : 1;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..addStatusListener(_status);
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_status)
      ..dispose();
    super.dispose();
  }

  void _status(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _notify();
    }
  }

  void _notify() {
    if (_notified) {
      return;
    }
    _notified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onFinished?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final count = (widget.text.length * _controller.value).round();
        final shown = widget.text.substring(
          0,
          count.clamp(0, widget.text.length),
        );
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: shown, style: widget.style),
              if (widget.animate && _controller.value < 1)
                TextSpan(
                  text: '▍',
                  style: widget.style?.copyWith(color: KgweboColors.inkMuted),
                ),
            ],
          ),
        );
      },
    );
  }
}
