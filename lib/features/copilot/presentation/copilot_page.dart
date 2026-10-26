import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/kgwebo_colors.dart';
import '../../../app/theme/kgwebo_spacing.dart';
import '../../../core/finance/cash_path.dart';
import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/currency_names.dart';
import '../../../core/money/minor_units.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/money/money_parser.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../shared/widgets/kgwebo_button.dart';
import '../../../shared/widgets/kgwebo_cash_path_chart.dart';
import '../../../shared/widgets/kgwebo_soft_card.dart';
import '../../../shared/widgets/kgwebo_status_banner.dart';
import '../../../shared/widgets/kgwebo_text_field.dart';
import '../../authentication/application/session_controller.dart';
import '../../authentication/domain/app_session.dart';
import '../../dashboard/application/dashboard_finance_controller.dart';
import '../../transactions/domain/payment_method.dart';
import '../../transactions/domain/transaction_categories.dart';
import '../application/copilot_hands_free.dart';
import '../application/copilot_providers.dart';
import '../application/copilot_voice.dart';
import '../application/financial_read_port.dart';
import '../domain/copilot_session.dart';
import '../domain/copilot_turn.dart';
import '../domain/extracted_draft.dart';
import 'widgets/copilot_thinking.dart';
import 'widgets/copilot_typed_text.dart';

class CopilotPage extends ConsumerStatefulWidget {
  const CopilotPage({super.key});

  @override
  ConsumerState<CopilotPage> createState() => _CopilotPageState();
}

class _CopilotPageState extends ConsumerState<CopilotPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final CopilotVoice _voice;
  final _messages = <_ChatItem>[
    _ChatItem.assistant(
      const CopilotTurn(
        source: CopilotSource.appGuidance,
        reply:
            'Ask anything about your stall. I can explain recorded cash, show a chart, walk through recommendations, or draft a sale or expense.',
      ),
    ),
  ];
  bool _working = false;
  bool _writing = false;
  bool _listening = false;
  CopilotOffer _pendingOffer = CopilotOffer.none;
  CopilotSession _askSession = const CopilotSession();

  @override
  void initState() {
    super.initState();
    _voice = ref.read(copilotVoiceProvider);
  }

  @override
  void dispose() {
    unawaited(_voice.stop());
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(dashboardFinanceControllerProvider);
    final session = ref.watch(appSessionProvider);
    final currencyCode =
        session is AppSessionReady ? session.business.currencyCode : 'BWP';
    return Scaffold(
      appBar: AppBar(title: const Text('Ask')),
      body: SafeArea(
        child: KgweboFilledBody(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    KgweboSpacing.md,
                    KgweboSpacing.md,
                    KgweboSpacing.md,
                    KgweboSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const KgweboStatusBanner(
                        tone: KgweboBannerTone.warning,
                        message:
                            'Ask can be wrong. Recorded cash, sales and expenses always come from Kgwebo, not from the model. Nothing is saved until you confirm.',
                      ),
                      const SizedBox(height: KgweboSpacing.md),
                      for (final (index, item) in _messages.indexed) ...[
                        _MessageBubble(
                          item: item,
                          finance: finance,
                          currencyCode: currencyCode,
                          animate: item.animate,
                          onTyped: () {
                            if (!mounted) {
                              return;
                            }
                            setState(() {
                              _writing = false;
                              _messages[index] = _messages[index].copyWith(
                                animate: false,
                              );
                            });
                            _scrollToEnd();
                          },
                          onOfferHelp: () => unawaited(_chooseHelp(item)),
                          onOfferOpen: () => _chooseOpen(item),
                          onDraftChanged: (draftIndex, draft) {
                            final turn = _messages[index].turn;
                            if (turn == null) {
                              return;
                            }
                            final drafts = [...turn.drafts];
                            drafts[draftIndex] = draft;
                            setState(() {
                              _messages[index] = _ChatItem.assistant(
                                turn.copyWith(drafts: drafts),
                              );
                            });
                          },
                          onConfirmDraft:
                              (draftIndex) => _confirmDraft(index, draftIndex),
                        ),
                        const SizedBox(height: KgweboSpacing.sm),
                      ],
                      if (_messages.length == 1 && !_working)
                        Wrap(
                          spacing: KgweboSpacing.sm,
                          runSpacing: KgweboSpacing.sm,
                          children: [
                            KgweboButton(
                              key: const Key('copilot-chip-cash'),
                              label: 'How much cash do I have?',
                              variant: KgweboButtonVariant.secondary,
                              onPressed:
                                  () => unawaited(
                                    _sendText('How much cash do I have?'),
                                  ),
                            ),
                            KgweboButton(
                              key: const Key('copilot-chip-expense'),
                              label: 'Record an expense',
                              variant: KgweboButtonVariant.secondary,
                              onPressed:
                                  () => unawaited(
                                    _sendText('I want to record an expense'),
                                  ),
                            ),
                            KgweboButton(
                              key: const Key('copilot-chip-watch'),
                              label: 'What should I watch?',
                              variant: KgweboButtonVariant.secondary,
                              onPressed:
                                  () => unawaited(
                                    _sendText('What should I watch?'),
                                  ),
                            ),
                          ],
                        ),
                      if (_working)
                        CopilotThinking(
                          key: const Key('copilot-thinking'),
                          writing: _writing,
                          animate: ref.watch(copilotMotionProvider),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KgweboSpacing.md,
                  KgweboSpacing.xs,
                  KgweboSpacing.md,
                  KgweboSpacing.md,
                ),
                child: Column(
                  children: [
                    KgweboTextField(
                      key: const Key('copilot-input'),
                      label: 'Ask Kgwebo',
                      controller: _controller,
                      enabled: !_working,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                    const SizedBox(height: KgweboSpacing.sm),
                    Row(
                      children: [
                        KgweboButton(
                          key: const Key('copilot-mic'),
                          label: _listening ? 'Listening' : 'Mic',
                          variant: KgweboButtonVariant.secondary,
                          icon: Icons.mic_none,
                          onPressed:
                              _working || _listening
                                  ? null
                                  : () => unawaited(_listen()),
                        ),
                        const SizedBox(width: KgweboSpacing.sm),
                        Expanded(
                          child: KgweboButton(
                            key: const Key('copilot-send'),
                            label: 'Send',
                            expanded: true,
                            isLoading: _working,
                            onPressed:
                                _working ? null : () => unawaited(_send()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText(String question) async {
    _controller.text = question;
    await _send();
  }

  Future<void> _listen() async {
    setState(() => _listening = true);
    try {
      final heard = await _voice.listenOnce();
      if (!mounted || heard == null) {
        return;
      }
      _controller.text = heard;
    } finally {
      if (mounted) {
        setState(() => _listening = false);
      }
    }
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty) {
      return;
    }
    _controller.clear();
    unawaited(_voice.stop());
    setState(() {
      _working = true;
      _writing = false;
      _messages.add(_ChatItem.user(question));
    });
    _scrollToEnd();
    try {
      if (_pendingOffer != CopilotOffer.none) {
        if (CopilotHandsFree.wantsOpenForm(question)) {
          await _appendAssistant(
            CopilotTurn(
              source: CopilotSource.appGuidance,
              reply: 'Opening that screen. You can also keep talking here.',
            ),
          );
          final route = CopilotHandsFree.routeForOffer(_pendingOffer);
          _pendingOffer = CopilotOffer.none;
          if (route != null && mounted) {
            context.pushNamed(route);
          }
          return;
        }
        if (CopilotHandsFree.wantsHelpHere(question)) {
          await _appendAssistant(
            CopilotTurn(
              source: CopilotSource.appGuidance,
              reply: CopilotHandsFree.helpPrompt(
                _pendingOffer,
                currencyCode: _bookCurrencyCode(),
              ),
            ),
          );
          _pendingOffer = CopilotOffer.none;
          return;
        }
      }
      if (CopilotHandsFree.wantsConfirm(question)) {
        for (var index = _messages.length - 1; index >= 0; index--) {
          final drafts = _messages[index].turn?.drafts ?? const [];
          if (drafts.isNotEmpty) {
            await _confirmDraft(index, 0);
            return;
          }
        }
      }
      final turn = await ref
          .read(copilotOrchestratorProvider)
          .handle(question, session: _askSession);
      if (!mounted) {
        return;
      }
      _pendingOffer = turn.offer;
      _askSession = _askSession.copyWith(
        lastUserText: question,
        lastDrafts:
            turn.drafts.isNotEmpty ? turn.drafts : _askSession.lastDrafts,
      );
      await _appendAssistant(turn);
      if (!mounted) {
        return;
      }
      if (CopilotHandsFree.wantsOpenForm(question) &&
          turn.navigateRouteName != null) {
        context.pushNamed(turn.navigateRouteName!);
      }
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _writing = _messages.isNotEmpty && _messages.last.animate;
        });
      }
    }
  }

  Future<void> _appendAssistant(CopilotTurn turn) async {
    final animate = ref.read(copilotMotionProvider);
    if (animate && mounted) {
      setState(() => _writing = true);
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) {
        return;
      }
    }
    setState(() {
      _working = false;
      _writing = animate;
      _messages.add(_ChatItem.assistant(turn, animate: animate));
    });
    _scrollToEnd();
    if (turn.shouldSpeak) {
      unawaited(_voice.speak(turn.reply, languageCode: turn.languageCode));
    }
  }

  String _bookCurrencyCode() {
    final session = ref.read(appSessionProvider);
    if (session is AppSessionReady) {
      return session.business.currencyCode;
    }
    return 'BWP';
  }

  Future<void> _chooseHelp(_ChatItem item) async {
    final offer = item.turn?.offer ?? CopilotOffer.none;
    if (offer == CopilotOffer.none) {
      return;
    }
    _pendingOffer = CopilotOffer.none;
    String? lastUser;
    for (var index = _messages.length - 1; index >= 0; index--) {
      if (_messages[index].isUser) {
        lastUser = _messages[index].text;
        break;
      }
    }
    if (lastUser != null) {
      final turn = await ref.read(copilotOrchestratorProvider).handle(lastUser);
      if (!mounted) {
        return;
      }
      if (turn.drafts.any((draft) => draft.amountMinor != null)) {
        await _appendAssistant(turn.copyWith(offer: CopilotOffer.none));
        return;
      }
    }
    await _appendAssistant(
      CopilotTurn(
        source: CopilotSource.appGuidance,
        reply: CopilotHandsFree.helpPrompt(
          offer,
          currencyCode: _bookCurrencyCode(),
        ),
      ),
    );
  }

  void _chooseOpen(_ChatItem item) {
    final offer = item.turn?.offer ?? CopilotOffer.none;
    final route = CopilotHandsFree.routeForOffer(offer);
    if (route == null) {
      return;
    }
    _pendingOffer = CopilotOffer.none;
    context.pushNamed(route);
  }

  Future<void> _confirmDraft(int messageIndex, int draftIndex) async {
    final session = ref.read(appSessionProvider);
    if (session is! AppSessionReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in with a saved business to confirm.'),
        ),
      );
      return;
    }
    final item = _messages[messageIndex];
    final turn = item.turn;
    if (turn == null) {
      return;
    }
    var draft = turn.drafts[draftIndex];
    draft = draft.copyWith(occurredOn: draft.occurredOn ?? DateTime.now());
    if (!draft.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fill ${draft.missingRequired.join(', ')} before confirming.',
          ),
        ),
      );
      return;
    }
    final allowed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final label = draft.type == MoneyMovementType.sale ? 'sale' : 'expense';
        final amountLabel = MoneyFormatter.formatMinor(
          draft.amountMinor!,
          currencyCode: session.business.currencyCode,
        );
        return AlertDialog(
          title: Text('Confirm this $label?'),
          content: Text(
            'Save $amountLabel as a $label. This uses the ordinary Kgwebo transaction service. It is not saved until you confirm.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    if (allowed != true || !mounted) {
      return;
    }
    try {
      await ref
          .read(copilotCommitProvider)
          .confirm(
            draft: draft,
            paymentMethod: PaymentMethod.cash,
            ownerId: session.user.id,
            businessId: session.business.id,
            currencyCode: session.business.currencyCode,
            occurredOn: draft.occurredOn!,
          );
      if (!mounted) {
        return;
      }
      final drafts = [...turn.drafts]..removeAt(draftIndex);
      _askSession = _askSession.copyWith(
        hasConfirmedOnce: true,
        lastDrafts: drafts,
      );
      setState(() {
        _messages[messageIndex] = _ChatItem.assistant(
          turn.copyWith(
            reply:
                'Saved. Recorded totals will update from Kgwebo, not from the AI.',
            source: CopilotSource.verifiedRecords,
            chart: CopilotChartKind.totals,
            drafts: drafts,
            offer: CopilotOffer.none,
            clearNavigate: true,
          ),
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
}

class _ChatItem {
  const _ChatItem._({
    required this.isUser,
    required this.text,
    this.turn,
    this.animate = false,
  });

  factory _ChatItem.user(String text) {
    return _ChatItem._(isUser: true, text: text);
  }

  factory _ChatItem.assistant(CopilotTurn turn, {bool animate = false}) {
    return _ChatItem._(
      isUser: false,
      text: turn.reply,
      turn: turn,
      animate: animate,
    );
  }

  final bool isUser;
  final String text;
  final CopilotTurn? turn;
  final bool animate;

  _ChatItem copyWith({bool? animate, CopilotTurn? turn}) {
    return _ChatItem._(
      isUser: isUser,
      text: text,
      turn: turn ?? this.turn,
      animate: animate ?? this.animate,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.item,
    required this.finance,
    required this.currencyCode,
    required this.animate,
    required this.onTyped,
    required this.onOfferHelp,
    required this.onOfferOpen,
    required this.onDraftChanged,
    required this.onConfirmDraft,
  });

  final _ChatItem item;
  final DashboardFinanceState finance;
  final String currencyCode;
  final bool animate;
  final VoidCallback onTyped;
  final VoidCallback onOfferHelp;
  final VoidCallback onOfferOpen;
  final void Function(int index, ExtractedDraft draft) onDraftChanged;
  final ValueChanged<int> onConfirmDraft;

  @override
  Widget build(BuildContext context) {
    if (item.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: KgweboSoftCard(
            color: KgweboColors.ink,
            child: Text(
              item.text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: KgweboColors.onInk),
            ),
          ),
        ),
      );
    }
    final turn = item.turn!;
    final textTheme = Theme.of(context).textTheme;
    final label = switch (turn.source) {
      CopilotSource.appGuidance => 'App guidance',
      CopilotSource.verifiedRecords => 'From recorded Kgwebo data',
      CopilotSource.needsRecords => 'No recorded figures yet',
      CopilotSource.drafts => 'Review before saving',
      CopilotSource.unknown => 'Limited answer',
    };
    return KgweboSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: KgweboColors.inkMuted),
          ),
          if (turn.offline) ...[
            const SizedBox(height: KgweboSpacing.xxs),
            Text(
              'Ask is using recorded Kgwebo data on this phone. Cloud suggestions are offline.',
              style: textTheme.bodySmall?.copyWith(
                color: KgweboColors.inkMuted,
              ),
            ),
          ],
          const SizedBox(height: KgweboSpacing.xs),
          CopilotTypedText(
            text: turn.reply,
            animate: animate,
            onFinished: onTyped,
            style: textTheme.bodyLarge?.copyWith(color: KgweboColors.ink),
          ),
          if (!animate && turn.offer != CopilotOffer.none) ...[
            const SizedBox(height: KgweboSpacing.sm),
            Wrap(
              spacing: KgweboSpacing.sm,
              runSpacing: KgweboSpacing.sm,
              children: [
                KgweboButton(
                  key: const Key('copilot-offer-help'),
                  label: 'Help me here',
                  onPressed: onOfferHelp,
                ),
                KgweboButton(
                  key: const Key('copilot-offer-open'),
                  label: 'Open the page',
                  variant: KgweboButtonVariant.secondary,
                  onPressed: onOfferOpen,
                ),
              ],
            ),
          ],
          if (!animate && turn.warning != null) ...[
            const SizedBox(height: KgweboSpacing.sm),
            KgweboStatusBanner(
              tone: KgweboBannerTone.warning,
              message: turn.warning!,
            ),
          ],
          if (!animate &&
              turn.snapshot != null &&
              turn.chart != CopilotChartKind.none) ...[
            const SizedBox(height: KgweboSpacing.md),
            _SnapshotMetrics(snapshot: turn.snapshot!),
          ],
          if (!animate &&
              turn.chart == CopilotChartKind.cashPath &&
              finance.forecast != null) ...[
            const SizedBox(height: KgweboSpacing.md),
            KgweboCashPathChart(
              path: CashPath.fromForecast(
                forecast: finance.forecast!,
                bills: [
                  for (final bill in [...finance.overdue, ...finance.upcoming])
                    CashPathBill(
                      id: bill.id,
                      title: bill.title,
                      amountMinor: bill.amountMinor,
                      dueOn: bill.dueOn,
                    ),
                ],
              ),
              compact: true,
            ),
          ],
          if (!animate) ...[
            for (final rec in turn.recommendations) ...[
              const SizedBox(height: KgweboSpacing.md),
              Text(
                rec.title,
                style: textTheme.titleMedium?.copyWith(color: KgweboColors.ink),
              ),
              Text(
                rec.explanation,
                style: textTheme.bodyMedium?.copyWith(color: KgweboColors.ink),
              ),
              Text(
                rec.evidence,
                style: textTheme.bodySmall?.copyWith(
                  color: KgweboColors.inkMuted,
                ),
              ),
            ],
            for (var index = 0; index < turn.drafts.length; index++) ...[
              const SizedBox(height: KgweboSpacing.md),
              _DraftCard(
                index: index,
                draft: turn.drafts[index],
                currencyCode: currencyCode,
                onChanged: (draft) => onDraftChanged(index, draft),
                onConfirm: () => onConfirmDraft(index),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SnapshotMetrics extends StatelessWidget {
  const _SnapshotMetrics({required this.snapshot});

  final VerifiedFinancialSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, int minor) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: KgweboColors.inkMuted),
            ),
            Text(
              MoneyFormatter.formatMinor(
                minor,
                currencyCode: snapshot.currencyCode,
              ),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: KgweboColors.ink),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recorded ${snapshot.periodLabel}',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: KgweboColors.inkMuted),
        ),
        const SizedBox(height: KgweboSpacing.sm),
        Row(
          children: [
            cell('Cash', snapshot.recordedCashMinor),
            cell('Sales', snapshot.recordedSalesMinor),
            cell('Expenses', snapshot.recordedExpensesMinor),
          ],
        ),
      ],
    );
  }
}

class _DraftCard extends StatefulWidget {
  const _DraftCard({
    required this.index,
    required this.draft,
    required this.currencyCode,
    required this.onChanged,
    required this.onConfirm,
  });

  final int index;
  final ExtractedDraft draft;
  final String currencyCode;
  final ValueChanged<ExtractedDraft> onChanged;
  final VoidCallback onConfirm;

  @override
  State<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends State<_DraftCard> {
  late final TextEditingController _amount;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(text: _amountText(widget.draft));
  }

  @override
  void didUpdateWidget(_DraftCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _amountText(widget.draft);
    if (_amount.text == next) {
      return;
    }
    final currentMinor = tryParseMinorUnits(_amount.text);
    if (currentMinor != widget.draft.amountMinor) {
      _amount.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = TransactionCategories.forType(widget.draft.type);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KgweboColors.canvas,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(KgweboSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              switch (widget.draft.type) {
                MoneyMovementType.sale => 'Suggested sale',
                MoneyMovementType.ownerWithdrawal =>
                  'Suggested owner withdrawal',
                MoneyMovementType.ownerContribution =>
                  'Suggested owner contribution',
                _ => 'Suggested expense',
              },
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: KgweboColors.ink),
            ),
            if (widget.draft.item != null)
              Text(
                widget.draft.item!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: KgweboColors.inkMuted),
              ),
            const SizedBox(height: KgweboSpacing.sm),
            KgweboTextField(
              label: 'Amount in ${CurrencyNames.spoken(widget.currencyCode)}',
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                final minor = tryParseMinorUnits(value);
                widget.onChanged(
                  widget.draft.copyWith(
                    amountMinor: minor,
                    clearAmount: minor == null,
                    clearCurrency: true,
                  ),
                );
              },
            ),
            const SizedBox(height: KgweboSpacing.sm),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value:
                  widget.draft.categoryCode != null &&
                          categories.any(
                            (item) => item.code == widget.draft.categoryCode,
                          )
                      ? widget.draft.categoryCode
                      : null,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final item in categories)
                  DropdownMenuItem(
                    value: item.code,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.onChanged(widget.draft.copyWith(categoryCode: value));
                }
              },
            ),
            const SizedBox(height: KgweboSpacing.sm),
            DropdownButtonFormField<PaymentStatus>(
              isExpanded: true,
              value: widget.draft.paymentStatus,
              decoration: const InputDecoration(labelText: 'Payment'),
              items: const [
                DropdownMenuItem(
                  value: PaymentStatus.paid,
                  child: Text('Paid'),
                ),
                DropdownMenuItem(
                  value: PaymentStatus.unpaid,
                  child: Text('Unpaid'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  widget.onChanged(widget.draft.copyWith(paymentStatus: value));
                }
              },
            ),
            const SizedBox(height: KgweboSpacing.sm),
            KgweboButton(
              key: Key('copilot-confirm-draft-${widget.index}'),
              label: 'Confirm',
              expanded: true,
              onPressed: widget.onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

String _amountText(ExtractedDraft draft) {
  return draft.amountMinor == null
      ? ''
      : MinorUnits.format(draft.amountMinor!, group: false);
}
