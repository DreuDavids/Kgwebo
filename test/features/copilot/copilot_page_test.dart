import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/routes.dart';
import 'package:kgwebo/core/money/money_formatter.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/copilot/application/copilot_llm_client.dart';
import 'package:kgwebo/features/copilot/application/copilot_providers.dart';
import 'package:kgwebo/features/copilot/application/copilot_voice.dart';
import 'package:kgwebo/features/copilot/application/financial_read_port.dart';
import 'package:kgwebo/features/copilot/domain/copilot_turn.dart';
import 'package:kgwebo/features/copilot/presentation/copilot_page.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/shell/compact_navigation.dart';

import '../../helpers/pump_app.dart';

class _SnapshotPort implements FinancialReadPort {
  const _SnapshotPort(this.snapshot);

  final VerifiedFinancialSnapshot snapshot;

  @override
  Future<VerifiedFinancialSnapshot?> currentSnapshot() async => snapshot;
}

void main() {
  const snapshot = VerifiedFinancialSnapshot(
    currencyCode: 'BWP',
    recordedCashMinor: 255000,
    recordedSalesMinor: 50000,
    recordedExpensesMinor: 10000,
    netOperatingResultMinor: 40000,
    periodLabel: 'October 2026',
    source: 'FinancialEngine',
  );
  const user = AuthUser(
    id: 'user-1',
    email: 'owner@example.com',
    emailConfirmed: true,
  );
  const business = BusinessProfile(
    id: 'biz-1',
    ownerId: 'user-1',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 200000,
  );
  const session = AppSessionReady(user: user, business: business);
  final cash = MoneyFormatter.formatMinor(255000, currencyCode: 'BWP');

  testWidgets('Ask page grounds a lying model to recorded cash', (
    tester,
  ) async {
    final llm = ScriptedCopilotLlmClient(
      const CopilotLlmDraft(intent: 'finances', reply: 'You have P 9,999.00.'),
    );
    await pumpKgweboApp(
      tester,
      size: const Size(360, 800),
      location: AppRoutes.ask,
      session: session,
      overrides: [
        copilotLlmClientProvider.overrideWithValue(llm),
        copilotMotionProvider.overrideWithValue(false),
        copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
        financialReadPortProvider.overrideWithValue(
          const _SnapshotPort(snapshot),
        ),
      ],
    );

    expect(find.byType(CopilotPage), findsOneWidget);
    expect(find.byKey(const Key('copilot-fallback-sale')), findsNothing);
    expect(find.byKey(const Key('copilot-fallback-expense')), findsNothing);
    expect(find.byKey(const Key('copilot-mic')), findsNothing);
    expect(
      find.textContaining('Nothing is saved until you confirm.'),
      findsOneWidget,
    );
    expect(find.textContaining('I never invent totals'), findsNothing);
    expect(
      find.textContaining('I never save money movements until you confirm'),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const Key('copilot-input')),
      'How much cash do I have?',
    );
    await tester.tap(find.byKey(const Key('copilot-send')));
    await tester.pumpAndSettle();

    expect(find.textContaining(cash, skipOffstage: false), findsWidgets);
    expect(find.textContaining('9,999.00'), findsNothing);
  });

  testWidgets('Ask tab is reachable from compact navigation', (tester) async {
    await pumpKgweboApp(
      tester,
      size: const Size(320, 568),
      session: session,
      overrides: [
        copilotLlmClientProvider.overrideWithValue(
          const NullCopilotLlmClient(),
        ),
        copilotMotionProvider.overrideWithValue(false),
        copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
        financialReadPortProvider.overrideWithValue(
          const _SnapshotPort(snapshot),
        ),
      ],
    );
    await tester.tap(
      find.descendant(
        of: find.byType(CompactNavigation),
        matching: find.text('Ask'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CopilotPage), findsOneWidget);
  });

  testWidgets('ZAR purchase is not converted into pula on Ask', (tester) async {
    await pumpKgweboApp(
      tester,
      size: const Size(360, 800),
      location: AppRoutes.ask,
      session: session,
      overrides: [
        copilotLlmClientProvider.overrideWithValue(
          const NullCopilotLlmClient(),
        ),
        copilotMotionProvider.overrideWithValue(false),
        copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
        financialReadPortProvider.overrideWithValue(
          const _SnapshotPort(snapshot),
        ),
      ],
    );

    await tester.enterText(
      find.byKey(const Key('copilot-input')),
      'I bought two domains at 50zar each',
    );
    await tester.tap(find.byKey(const Key('copilot-send')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Enter the pula amount before saving.'),
      findsOneWidget,
    );
    expect(find.textContaining('999.00'), findsNothing);
    expect(find.text('100.00'), findsNothing);
  });

  testWidgets(
    'Ask drafts two domains at 50 each without asking for pula again',
    (tester) async {
      await pumpKgweboApp(
        tester,
        size: const Size(360, 800),
        location: AppRoutes.ask,
        session: session,
        overrides: [
          copilotLlmClientProvider.overrideWithValue(
            const NullCopilotLlmClient(),
          ),
          copilotMotionProvider.overrideWithValue(false),
          copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
          financialReadPortProvider.overrideWithValue(
            const _SnapshotPort(snapshot),
          ),
        ],
      );

      await tester.enterText(
        find.byKey(const Key('copilot-input')),
        'hey I bought 2 domains at 50 each, can you please record this for me',
      );
      await tester.tap(find.byKey(const Key('copilot-send')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('copilot-offer-help')), findsNothing);
      expect(find.textContaining('Tell me the amount'), findsNothing);
      expect(find.textContaining('domains'), findsWidgets);
      expect(find.text('100.00'), findsOneWidget);
      expect(find.text('Amount in pula'), findsOneWidget);
    },
  );

  testWidgets('Ask amount field uses the profile currency name', (
    tester,
  ) async {
    const zarBusiness = BusinessProfile(
      id: 'biz-1',
      ownerId: 'user-1',
      name: 'Kgale Stall',
      businessType: 'Informal trader',
      countryCode: 'ZA',
      currencyCode: 'ZAR',
      openingBalanceMinor: 200000,
    );
    const zarSession = AppSessionReady(user: user, business: zarBusiness);
    const zarSnapshot = VerifiedFinancialSnapshot(
      currencyCode: 'ZAR',
      recordedCashMinor: 255000,
      recordedSalesMinor: 50000,
      recordedExpensesMinor: 10000,
      netOperatingResultMinor: 40000,
      periodLabel: 'October 2026',
      source: 'FinancialEngine',
    );

    await pumpKgweboApp(
      tester,
      size: const Size(360, 800),
      location: AppRoutes.ask,
      session: zarSession,
      overrides: [
        copilotLlmClientProvider.overrideWithValue(
          const NullCopilotLlmClient(),
        ),
        copilotMotionProvider.overrideWithValue(false),
        copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
        financialReadPortProvider.overrideWithValue(
          const _SnapshotPort(zarSnapshot),
        ),
      ],
    );

    await tester.enterText(
      find.byKey(const Key('copilot-input')),
      'I bought 2 domains at 50 each',
    );
    await tester.tap(find.byKey(const Key('copilot-send')));
    await tester.pumpAndSettle();

    expect(find.text('Amount in rand'), findsOneWidget);
    expect(find.text('Amount in pula'), findsNothing);
    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('Ask prefills 100 pula for two domains at 50 pula each', (
    tester,
  ) async {
    final llm = ScriptedCopilotLlmClient(
      const CopilotLlmDraft(
        intent: 'drafts',
        transactionsJson:
            '{"transactions":[{"type":"expense","amount_pula":"100.00","item":"domains","quantity":2,"category":"fees"}]}',
      ),
    );
    await pumpKgweboApp(
      tester,
      size: const Size(360, 800),
      location: AppRoutes.ask,
      session: session,
      overrides: [
        copilotLlmClientProvider.overrideWithValue(llm),
        copilotMotionProvider.overrideWithValue(false),
        copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
        financialReadPortProvider.overrideWithValue(
          const _SnapshotPort(snapshot),
        ),
      ],
    );

    await tester.enterText(
      find.byKey(const Key('copilot-input')),
      'I bought two domains at 50 pula each',
    );
    await tester.tap(find.byKey(const Key('copilot-send')));
    await tester.pumpAndSettle();

    expect(find.textContaining('domains'), findsWidgets);
    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('Ask offers help or the sale page instead of opening it', (
    tester,
  ) async {
    await pumpKgweboApp(
      tester,
      size: const Size(360, 800),
      location: AppRoutes.ask,
      session: session,
      overrides: [
        copilotLlmClientProvider.overrideWithValue(
          const NullCopilotLlmClient(),
        ),
        copilotMotionProvider.overrideWithValue(false),
        copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
        financialReadPortProvider.overrideWithValue(
          const _SnapshotPort(snapshot),
        ),
      ],
    );

    await tester.enterText(
      find.byKey(const Key('copilot-input')),
      'I want to record a sale',
    );
    await tester.tap(find.byKey(const Key('copilot-send')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('copilot-offer-help')), findsOneWidget);
    expect(find.byKey(const Key('copilot-offer-open')), findsOneWidget);
    expect(find.textContaining('Help me here'), findsOneWidget);
    expect(find.textContaining('Open the page'), findsOneWidget);
  });

  testWidgets('Ask shows thinking while waiting for a reply', (tester) async {
    await pumpKgweboApp(
      tester,
      size: const Size(360, 800),
      location: AppRoutes.ask,
      session: session,
      overrides: [
        copilotLlmClientProvider.overrideWithValue(const _SlowLlm()),
        copilotMotionProvider.overrideWithValue(false),
        copilotVoiceProvider.overrideWithValue(const NullCopilotVoice()),
        financialReadPortProvider.overrideWithValue(
          const _SnapshotPort(snapshot),
        ),
      ],
    );

    await tester.enterText(
      find.byKey(const Key('copilot-input')),
      'Can you greet me?',
    );
    await tester.tap(find.byKey(const Key('copilot-send')));
    await tester.pump();

    expect(find.byKey(const Key('copilot-thinking')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('copilot-thinking')), findsNothing);
    expect(find.textContaining('Hello from Ask.'), findsOneWidget);
  });
}

class _SlowLlm implements CopilotLlmClient {
  const _SlowLlm();

  @override
  Future<CopilotLlmDraft?> complete({
    required String userText,
    required VerifiedFinancialSnapshot? snapshot,
    required List<String> recommendationTitles,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const CopilotLlmDraft(intent: 'chat', reply: 'Hello from Ask.');
  }
}
