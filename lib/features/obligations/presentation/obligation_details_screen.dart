import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/finance/business_calendar.dart';
import '../../../core/finance/cash_outlook.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_empty_state.dart';
import '../../../shared/widgets/kgwebo_hero_card.dart';
import '../../../shared/widgets/kgwebo_loading_state.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../authentication/domain/auth_failure.dart';
import '../application/obligation_tick.dart';
import '../domain/business_obligation.dart';
import '../domain/obligation_categories.dart';
import '../domain/obligation_draft.dart';

class ObligationDetailsScreen extends ConsumerStatefulWidget {
  const ObligationDetailsScreen({super.key, required this.obligationId});

  final String obligationId;

  @override
  ConsumerState<ObligationDetailsScreen> createState() =>
      _ObligationDetailsScreenState();
}

class _ObligationDetailsScreenState
    extends ConsumerState<ObligationDetailsScreen> {
  BusinessObligation? _obligation;
  String? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      setState(() {
        _loading = false;
        _error = 'Sign in to view this commitment.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loaded = await ref
          .read(obligationRepositoryProvider)
          .findById(
            ownerId: session.user.id,
            businessId: session.business.id,
            obligationId: widget.obligationId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _obligation = loaded;
        _loading = false;
        if (loaded == null) {
          _error = 'This commitment was not found.';
        }
      });
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _setStatus(CommitmentStatus status) async {
    final obligation = _obligation;
    final session = ref.read(appSessionProvider);
    if (obligation == null || session is! AppSessionReady || _busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final saved = await ref
          .read(obligationRepositoryProvider)
          .update(
            ownerId: session.user.id,
            businessId: session.business.id,
            currencyCode: session.business.currencyCode,
            draft: ObligationDraft(
              title: obligation.title,
              amountText: _amountText(obligation.amountMinor),
              dueOn: obligation.dueOn,
              category: obligation.category,
              status: status,
              notes: obligation.notes ?? '',
              idempotencyKey: obligation.idempotencyKey,
              existingId: obligation.id,
            ),
          );
      if (!mounted) {
        return;
      }
      bumpObligationTick(ref);
      setState(() {
        _obligation = saved;
        _busy = false;
      });
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.message;
      });
    }
  }

  String _amountText(int minor) {
    final whole = minor ~/ 100;
    final fraction = (minor % 100).toString().padLeft(2, '0');
    return '$whole.$fraction';
  }

  Future<void> _confirmDelete() async {
    final obligation = _obligation;
    if (obligation == null || _busy) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete this commitment?'),
            content: const Text(
              'This removes the upcoming bill from your records. It does not delete any expense you already recorded.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep it'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed != true) {
      return;
    }
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(obligationRepositoryProvider)
          .delete(
            ownerId: session.user.id,
            businessId: session.business.id,
            obligationId: obligation.id,
          );
      if (!mounted) {
        return;
      }
      bumpObligationTick(ref);
      context.goNamed(AppRoutes.cashFlowName);
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final obligation = _obligation;
    final zone =
        session is AppSessionReady
            ? BusinessZone.forCountry(session.business.countryCode)
            : BusinessZone.africaGaborone;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commitment'),
        actions: [
          if (obligation != null)
            TextButton(
              onPressed:
                  _busy
                      ? null
                      : () async {
                        await context.pushNamed(
                          AppRoutes.obligationEditName,
                          pathParameters: {'obligationId': obligation.id},
                        );
                        if (mounted) {
                          await _load();
                        }
                      },
              child: const Text('Edit'),
            ),
        ],
      ),
      body: SafeArea(
        child: KgweboFilledBody(child: _body(session, obligation, zone)),
      ),
    );
  }

  Widget _body(
    AppSession session,
    BusinessObligation? obligation,
    BusinessZone zone,
  ) {
    if (session is AppSessionPreview) {
      return const KgweboEmptyState(
        icon: Icons.event_outlined,
        title: 'Preview has no commitments',
        message: 'Sign in to view upcoming bills for your business.',
      );
    }
    if (_loading) {
      return const KgweboLoadingState(message: 'Loading commitment');
    }
    if (obligation == null) {
      return KgweboEmptyState(
        icon: Icons.search_off_outlined,
        title: 'Commitment not found',
        message: _error ?? 'This record is not available on this device.',
      );
    }
    final amount = MoneyFormatter.formatMinor(
      obligation.amountMinor,
      currencyCode: obligation.currencyCode,
    );
    final status = obligation.displayStatus(
      asOf: DateTime.now().toUtc(),
      zone: zone,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.md,
        KgweboSpacing.xl,
      ),
      children: [
        if (_error != null) ...[
          KgweboStatusBanner(tone: KgweboBannerTone.warning, message: _error!),
          const SizedBox(height: KgweboSpacing.md),
        ],
        const KgweboStatusBanner(
          tone: KgweboBannerTone.info,
          message:
              'This is a planned payment. It is not a recorded expense and has not changed current cash.',
        ),
        const SizedBox(height: KgweboSpacing.md),
        KgweboHeroCard(
          label: obligation.title,
          value: amount,
          caption:
              '${ObligationCategories.labelFor(obligation.category)} · due ${DateFormat.yMMMEd().format(obligation.dueOn)}',
        ),
        const SizedBox(height: KgweboSpacing.md),
        KgweboSoftCard(
          padding: const EdgeInsets.all(KgweboSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusCopy(status),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: KgweboColors.ink,
                  height: 1.45,
                ),
              ),
              if (obligation.notes != null && obligation.notes!.isNotEmpty) ...[
                const SizedBox(height: KgweboSpacing.md),
                Text(
                  obligation.notes!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: KgweboColors.inkMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: KgweboSpacing.xl),
        if (obligation.status == CommitmentStatus.unpaid) ...[
          KgweboButton(
            label: 'Mark paid',
            expanded: true,
            isLoading: _busy,
            onPressed: _busy ? null : () => _setStatus(CommitmentStatus.paid),
          ),
          const SizedBox(height: KgweboSpacing.sm),
          KgweboButton(
            label: 'Cancel commitment',
            variant: KgweboButtonVariant.secondary,
            expanded: true,
            onPressed:
                _busy ? null : () => _setStatus(CommitmentStatus.cancelled),
          ),
          const SizedBox(height: KgweboSpacing.sm),
        ],
        KgweboButton(
          label: 'Delete',
          variant: KgweboButtonVariant.text,
          onPressed: _busy ? null : _confirmDelete,
        ),
      ],
    );
  }

  String _statusCopy(ObligationDisplayStatus status) {
    return switch (status) {
      ObligationDisplayStatus.unpaid =>
        'Unpaid. This amount is included in the cash estimate only, not in recorded cash.',
      ObligationDisplayStatus.overdue =>
        'Overdue. Still unpaid after the due date. Recorded cash is unchanged.',
      ObligationDisplayStatus.paid =>
        'Marked paid. If money left the business, record an expense separately so cash stays accurate.',
      ObligationDisplayStatus.cancelled =>
        'Cancelled. This bill is excluded from the cash estimate.',
    };
  }
}
