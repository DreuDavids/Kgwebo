import 'package:flutter/material.dart';

import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_radii.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/sync/outbox_models.dart';

class KgweboSyncStatusLabel extends StatelessWidget {
  const KgweboSyncStatusLabel({
    super.key,
    required this.state,
    this.compact = false,
  });

  final OutboxState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = switch (state) {
      OutboxState.pending => Icons.schedule_outlined,
      OutboxState.syncing => Icons.sync,
      OutboxState.succeeded => Icons.check_circle_outline,
      OutboxState.retryableFailure => Icons.cloud_off_outlined,
      OutboxState.permanentFailure => Icons.error_outline,
    };
    return Semantics(
      label: state.userLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: KgweboColors.surfaceMuted,
          borderRadius: KgweboRadii.borderLg,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? KgweboSpacing.xs : KgweboSpacing.sm,
            vertical: compact ? 2 : KgweboSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 14 : 16, color: KgweboColors.ink),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  state.userLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: KgweboColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
