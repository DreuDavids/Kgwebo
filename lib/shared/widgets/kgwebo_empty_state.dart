import 'package:flutter/material.dart';

import '../../app/theme/kgwebo_colors.dart';
import '../../app/theme/kgwebo_spacing.dart';
import 'kgwebo_button.dart';
import 'kgwebo_soft_card.dart';

class KgweboEmptyState extends StatelessWidget {
  const KgweboEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KgweboSpacing.md,
        vertical: KgweboSpacing.lg,
      ),
      child: KgweboSoftCard(
        padding: const EdgeInsets.symmetric(
          horizontal: KgweboSpacing.lg,
          vertical: KgweboSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: KgweboColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: KgweboColors.ink, size: 32),
            ),
            const SizedBox(height: KgweboSpacing.md),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(color: KgweboColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KgweboSpacing.xs),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: KgweboColors.inkMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: KgweboSpacing.lg),
              KgweboButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
    return Semantics(
      container: true,
      label: '$title. $message',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) {
            return content;
          }
          return SingleChildScrollView(child: content);
        },
      ),
    );
  }
}
