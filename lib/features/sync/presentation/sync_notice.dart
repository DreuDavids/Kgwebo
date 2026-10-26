import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../application/sync_queue_controller.dart';

class KgweboSyncNotice extends ConsumerWidget {
  const KgweboSyncNotice({super.key, this.includeReviewAction = true});

  final bool includeReviewAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(syncQueueControllerProvider);
    if (!queue.hasOpen) {
      return const SizedBox.shrink();
    }
    final message =
        queue.actionRequiredCount > 0
            ? '${queue.actionRequiredCount} change${queue.actionRequiredCount == 1 ? '' : 's'} need review. They were not saved.'
            : '${queue.waitingCount} change${queue.waitingCount == 1 ? '' : 's'} waiting to save. Pending items are not included in cash, sales or forecasts.';
    return Padding(
      padding: const EdgeInsets.only(bottom: KgweboSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KgweboStatusBanner(
            tone:
                queue.actionRequiredCount > 0
                    ? KgweboBannerTone.warning
                    : KgweboBannerTone.info,
            icon:
                queue.actionRequiredCount > 0
                    ? Icons.error_outline
                    : Icons.schedule_outlined,
            message: message,
          ),
          if (includeReviewAction) ...[
            const SizedBox(height: KgweboSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.pushNamed(AppRoutes.syncQueueName),
                child: const Text('Review pending changes'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
