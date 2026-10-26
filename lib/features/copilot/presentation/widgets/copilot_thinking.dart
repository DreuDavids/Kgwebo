import 'package:flutter/material.dart';

import '../../../../app/theme/kgwebo_colors.dart';
import '../../../../app/theme/kgwebo_spacing.dart';
import '../../../../shared/widgets/kgwebo_soft_card.dart';

class CopilotThinking extends StatefulWidget {
  const CopilotThinking({super.key, this.writing = false, this.animate = true});

  final bool writing;
  final bool animate;

  @override
  State<CopilotThinking> createState() => _CopilotThinkingState();
}

class _CopilotThinkingState extends State<CopilotThinking>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.writing ? 'Writing' : 'Thinking';
    return KgweboSoftCard(
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: KgweboColors.inkMuted),
          ),
          const SizedBox(width: KgweboSpacing.sm),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    _Dot(active: ((_controller.value * 3).floor() % 3) == i),
                    if (i < 2) const SizedBox(width: 4),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? KgweboColors.ink : KgweboColors.inkFaint,
      ),
    );
  }
}
