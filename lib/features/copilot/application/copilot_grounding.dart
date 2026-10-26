import '../../../core/finance/ledger_entry.dart';
import '../../../core/money/currency_names.dart';
import '../../../core/money/minor_units.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/money/money_parser.dart';
import '../../recommendations/domain/visible_recommendation.dart';
import '../domain/copilot_session.dart';
import '../domain/copilot_turn.dart';
import '../domain/extracted_draft.dart';
import 'copilot_book.dart';
import 'copilot_hands_free.dart';
import 'copilot_intent.dart';
import 'extraction_parser.dart';
import 'financial_read_port.dart';
import 'help_corpus.dart';
import 'heuristic_extractor.dart';

final _moneyToken = RegExp(
  r'(?:P|R|ZAR|BWP)\s*[\d,]+(?:\.\d{1,2})?|[\d,]+\.\d{2}',
  caseSensitive: false,
);

CopilotTurn groundCopilotTurn({
  required String userText,
  required VerifiedFinancialSnapshot? snapshot,
  CopilotBook? book,
  CopilotSession? session,
  CopilotLlmDraft? llm,
  List<VisibleRecommendation> recommendations = const [],
  List<ExtractedDraft> localDrafts = const [],
  bool offline = false,
}) {
  final currencyCode = snapshot?.currencyCode ?? 'BWP';
  final spoken = CurrencyNames.spoken(currencyCode);
  final resolvedBook = book ?? CopilotBook(snapshot: snapshot);
  final intent = (llm?.intent ?? _localIntent(userText)).toLowerCase();
  var drafts = _mergeDrafts(
    llm?.transactionsJson,
    localDrafts,
    userText,
    currencyCode,
  );
  drafts = [for (final draft in drafts) _matchStock(draft, resolvedBook)];
  final offer = CopilotHandsFree.offerFor(userText);
  final kind = classifyCopilotIntent(userText, currencyCode: currencyCode);

  if (offer != CopilotOffer.none &&
      !CopilotHandsFree.wantsOpenForm(userText) &&
      drafts.every((draft) => draft.amountMinor == null)) {
    if (session?.hasConfirmedOnce == true) {
      return CopilotTurn(
        source: CopilotSource.appGuidance,
        reply: CopilotHandsFree.helpPrompt(offer, currencyCode: currencyCode),
        languageCode: llm?.languageCode,
        offline: offline,
      );
    }
    return CopilotTurn(
      source: CopilotSource.appGuidance,
      reply: CopilotHandsFree.prompt(offer),
      offer: offer,
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }

  if (kind == CopilotIntentKind.bills) {
    return CopilotTurn(
      source: CopilotSource.verifiedRecords,
      snapshot: snapshot,
      reply: billsReply(resolvedBook),
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }
  if (kind == CopilotIntentKind.stock) {
    return CopilotTurn(
      source: CopilotSource.verifiedRecords,
      snapshot: snapshot,
      reply: stockReply(resolvedBook),
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }
  if (kind == CopilotIntentKind.recent) {
    return CopilotTurn(
      source: CopilotSource.verifiedRecords,
      snapshot: snapshot,
      reply: recentReply(resolvedBook),
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }

  if (intent == 'finances' || _looksFinancial(userText)) {
    if (snapshot == null) {
      return CopilotTurn(
        source: CopilotSource.needsRecords,
        reply:
            'I can only explain recorded Kgwebo figures. Sign in with a saved business, or record sales and expenses first. I will not invent a cash balance.',
        languageCode: llm?.languageCode,
        offline: offline,
      );
    }
    return CopilotTurn(
      source: CopilotSource.verifiedRecords,
      snapshot: snapshot,
      chart:
          _chartKind(llm?.chart) == CopilotChartKind.cashPath
              ? CopilotChartKind.cashPath
              : CopilotChartKind.totals,
      reply: _financialReply(snapshot, llm?.reply),
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }

  if (intent == 'recommendations' || _looksRecommendations(userText)) {
    return CopilotTurn(
      source: CopilotSource.verifiedRecords,
      snapshot: snapshot,
      recommendations: recommendations,
      chart: CopilotChartKind.none,
      reply: _recommendationReply(recommendations, snapshot),
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }

  if (drafts.isNotEmpty) {
    return CopilotTurn(
      source: CopilotSource.drafts,
      drafts: drafts,
      reply: _draftReply(drafts, spoken),
      warning:
          drafts.any((draft) => draft.hasForeignCurrency)
              ? 'A named currency is not $spoken. Enter the $spoken amount before saving.'
              : null,
      languageCode: llm?.languageCode,
      navigateRouteName: _allowedNavigate(llm?.navigate),
      offline: offline,
    );
  }

  if (intent == 'navigate') {
    final route = _allowedNavigate(llm?.navigate) ?? _localNavigate(userText);
    if (route == 'record-sale' || route == 'record-expense') {
      final formOffer =
          route == 'record-sale'
              ? CopilotOffer.recordSale
              : CopilotOffer.recordExpense;
      if (!CopilotHandsFree.wantsOpenForm(userText)) {
        return CopilotTurn(
          source: CopilotSource.appGuidance,
          reply: CopilotHandsFree.prompt(formOffer),
          offer: formOffer,
          languageCode: llm?.languageCode,
          offline: offline,
        );
      }
    }
    return CopilotTurn(
      source: CopilotSource.appGuidance,
      reply:
          route == null
              ? 'I can open Money, Stock, Bills, Reports, or a sale or expense form.'
              : 'Opening that screen. You can also keep talking here.',
      navigateRouteName: route,
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }

  final openRoute = _localNavigate(userText);
  if (openRoute != null) {
    return CopilotTurn(
      source: CopilotSource.appGuidance,
      reply: 'Opening that screen. You can also keep talking here.',
      navigateRouteName: openRoute,
      languageCode: llm?.languageCode,
      offline: offline,
    );
  }

  final article = KgweboHelpCorpus.match(userText);
  if (article != null) {
    return CopilotTurn(
      source: CopilotSource.appGuidance,
      reply: '${article.title}. ${article.body}',
      languageCode: llm?.languageCode,
      navigateRouteName: _allowedNavigate(llm?.navigate),
      offline: offline,
    );
  }

  final modelReply = llm?.reply?.trim();
  if (modelReply != null &&
      modelReply.isNotEmpty &&
      !_containsDisallowedMoney(modelReply, snapshot)) {
    return CopilotTurn(
      source: CopilotSource.appGuidance,
      reply:
          '$modelReply\n\nThis is general app guidance, not a verified financial figure.',
      languageCode: llm?.languageCode,
      navigateRouteName: _allowedNavigate(llm?.navigate),
      offline: offline,
    );
  }

  return CopilotTurn(
    source: CopilotSource.unknown,
    reply:
        'I can record a sale or expense after you review it, explain recorded cash, show recommendations, or open Kgwebo screens. I will not invent a balance.',
    languageCode: llm?.languageCode,
    offline: offline,
  );
}

ExtractedDraft _matchStock(ExtractedDraft draft, CopilotBook book) {
  final matched = book.matchProductName(draft.item);
  if (matched == null || draft.note != null) {
    return draft;
  }
  return draft.copyWith(note: 'Matches stock: $matched');
}

List<ExtractedDraft> _mergeDrafts(
  String? transactionsJson,
  List<ExtractedDraft> localDrafts,
  String userText,
  String currencyCode,
) {
  final heuristic =
      localDrafts.isNotEmpty
          ? localDrafts
          : extractHeuristicDrafts(userText, currencyCode: currencyCode);
  if (heuristic.isNotEmpty) {
    return heuristic;
  }
  if (transactionsJson != null && transactionsJson.trim().isNotEmpty) {
    final parsed = parseExtractionOutput(
      transactionsJson,
      currencyCode: currencyCode,
    );
    if (!parsed.isRejected && parsed.drafts.isNotEmpty) {
      return [
        for (final draft in parsed.drafts)
          _stripUnnamedAmount(draft, userText, currencyCode),
      ];
    }
  }
  return heuristic;
}

ExtractedDraft _stripUnnamedAmount(
  ExtractedDraft draft,
  String userText,
  String currencyCode,
) {
  final amount = draft.amountMinor;
  if (amount == null || _userNamedBookAmount(userText, amount, currencyCode)) {
    return draft;
  }
  return draft.copyWith(clearAmount: true);
}

bool _userNamedBookAmount(String userText, int minor, String currencyCode) {
  final text = userText.toLowerCase();
  final aliases = CurrencyNames.aliases(currencyCode);
  final plain = MinorUnits.format(minor, group: false);
  final whole = (minor ~/ 100).toString();
  final tokens = <String>{plain, if (minor % 100 == 0) whole};
  for (final token in tokens) {
    final escaped = RegExp.escape(token);
    for (final alias in aliases) {
      final named = RegExp.escape(alias);
      if (RegExp(
        '(?:$named\\s*)$escaped\\b',
        caseSensitive: false,
      ).hasMatch(text)) {
        return true;
      }
      if (RegExp(
        '\\b$escaped\\s*$named\\b',
        caseSensitive: false,
      ).hasMatch(text)) {
        return true;
      }
    }
  }
  final parsedHits = RegExp(r'(\d+(?:\.\d{1,2})?)').allMatches(userText);
  for (final hit in parsedHits) {
    final parsed = tryParseMinorUnits(hit.group(1)!);
    if (parsed != minor) {
      continue;
    }
    final before = text.substring(0, hit.start);
    final after = text.substring(hit.end);
    if (_foreignCurrencyBeside(before, after, currencyCode)) {
      continue;
    }
    if (_bookCurrencyBeside(before, after, aliases)) {
      return true;
    }
  }
  return extractHeuristicDrafts(
    userText,
    currencyCode: currencyCode,
  ).any((draft) => draft.amountMinor == minor && !draft.hasForeignCurrency);
}

bool _foreignCurrencyBeside(String before, String after, String currencyCode) {
  const named = ['zar', 'rand', 'pula', 'bwp', 'usd', 'nad', 'dollar'];
  for (final token in named) {
    final code = CurrencyNames.codeOf(token);
    if (code == null || code == currencyCode) {
      continue;
    }
    if (RegExp('$token\\s*\$', caseSensitive: false).hasMatch(before) ||
        RegExp('^\\s*$token', caseSensitive: false).hasMatch(after)) {
      return true;
    }
  }
  return false;
}

bool _bookCurrencyBeside(String before, String after, Set<String> aliases) {
  for (final alias in aliases) {
    final named = RegExp.escape(alias);
    if (RegExp('$named\\s*\$', caseSensitive: false).hasMatch(before) ||
        RegExp('^\\s*$named\\b', caseSensitive: false).hasMatch(after)) {
      return true;
    }
  }
  return false;
}

String _draftReply(List<ExtractedDraft> drafts, String spoken) {
  if (drafts.length == 1) {
    final draft = drafts.single;
    final kind = draft.type == MoneyMovementType.sale ? 'sale' : 'expense';
    final amount =
        draft.amountMinor == null
            ? null
            : MinorUnits.format(draft.amountMinor!, group: false);
    final what = [
      if (draft.quantity != null && draft.quantity! > 1) '${draft.quantity}',
      if (draft.item != null) draft.item!,
    ].join(' ');
    if (amount != null && what.isNotEmpty) {
      return 'I drafted a $amount $spoken $kind for $what. Check it and confirm. Nothing is saved until you confirm.';
    }
    if (amount != null) {
      return 'I drafted a $amount $spoken $kind. Check it and confirm. Nothing is saved until you confirm.';
    }
  }
  return 'Review each suggestion. Nothing is saved until you confirm. Amounts in another currency stay unknown until you enter $spoken.';
}

CopilotChartKind _chartKind(String? raw) {
  return switch (raw?.trim().toLowerCase()) {
    'cash_path' || 'cash' => CopilotChartKind.cashPath,
    'totals' || 'sales' => CopilotChartKind.totals,
    _ => CopilotChartKind.none,
  };
}

String _financialReply(VerifiedFinancialSnapshot snapshot, String? modelReply) {
  final verified = verifiedFinancialCopy(snapshot);
  final raw = modelReply?.trim();
  if (raw == null || raw.isEmpty) {
    return verified;
  }
  if (_containsDisallowedMoney(raw, snapshot)) {
    return verified;
  }
  return raw;
}

String verifiedFinancialCopy(VerifiedFinancialSnapshot snapshot) {
  final cash = MoneyFormatter.formatMinor(
    snapshot.recordedCashMinor,
    currencyCode: snapshot.currencyCode,
  );
  final sales = MoneyFormatter.formatMinor(
    snapshot.recordedSalesMinor,
    currencyCode: snapshot.currencyCode,
  );
  final expenses = MoneyFormatter.formatMinor(
    snapshot.recordedExpensesMinor,
    currencyCode: snapshot.currencyCode,
  );
  final result = MoneyFormatter.formatMinor(
    snapshot.netOperatingResultMinor,
    currencyCode: snapshot.currencyCode,
  );
  return 'These figures come from recorded Kgwebo data for ${snapshot.periodLabel}, not from the AI. '
      'Recorded cash is $cash. Recorded sales are $sales. '
      'Recorded operating expenses are $expenses. '
      'Net recorded operating result is $result. '
      'This is not audited profit, tax advice or a bank balance.';
}

String _recommendationReply(
  List<VisibleRecommendation> recommendations,
  VerifiedFinancialSnapshot? snapshot,
) {
  if (recommendations.isEmpty) {
    return 'There is no active recommendation from recorded Kgwebo data right now. '
        'Recommendations come from bills, stock and totals, not from the AI.';
  }
  final buffer = StringBuffer(
    'These recommendations come from recorded Kgwebo data, not from the AI.\n',
  );
  for (final item in recommendations.take(5)) {
    buffer
      ..writeln()
      ..writeln(item.title)
      ..writeln(item.explanation)
      ..writeln(item.evidence);
  }
  if (snapshot != null) {
    buffer
      ..writeln()
      ..write(verifiedFinancialCopy(snapshot));
  }
  return buffer.toString();
}

bool _containsDisallowedMoney(
  String text,
  VerifiedFinancialSnapshot? snapshot,
) {
  final allowed = snapshot == null ? <String>{} : _allowedMoneyTokens(snapshot);
  for (final match in _moneyToken.allMatches(text)) {
    final token = _normalizeMoney(match.group(0)!);
    if (!allowed.contains(token)) {
      return true;
    }
  }
  return false;
}

Set<String> _allowedMoneyTokens(VerifiedFinancialSnapshot snapshot) {
  final minors = [
    snapshot.recordedCashMinor,
    snapshot.recordedSalesMinor,
    snapshot.recordedExpensesMinor,
    snapshot.netOperatingResultMinor,
  ];
  final tokens = <String>{};
  for (final minor in minors) {
    tokens.add(
      _normalizeMoney(
        MoneyFormatter.formatMinor(minor, currencyCode: snapshot.currencyCode),
      ),
    );
    tokens.add(
      _normalizeMoney(
        MoneyFormatter.formatMinor(
          minor,
          currencyCode: snapshot.currencyCode,
          group: false,
        ),
      ),
    );
    tokens.add(_normalizeMoney(MinorUnits.format(minor, group: true)));
    tokens.add(_normalizeMoney(MinorUnits.format(minor, group: false)));
  }
  return tokens;
}

String _normalizeMoney(String raw) {
  return raw.toUpperCase().replaceAll(RegExp(r'[\s,]'), '');
}

bool _looksFinancial(String question) {
  final text = question.toLowerCase();
  if (text.contains('how do i') ||
      text.contains('how to') ||
      text.contains('opening cash')) {
    return false;
  }
  const keys = [
    'how much',
    'my cash',
    'cash do i',
    'my sales',
    'my profit',
    'operating result',
    'my balance',
    'graph',
    'chart',
    'report',
    'madi',
    'ke na le',
  ];
  return keys.any(text.contains);
}

bool _looksRecommendations(String question) {
  if (CopilotHandsFree.wantsOpenForm(question)) {
    return false;
  }
  final text = question.toLowerCase();
  return text.contains('recommend') ||
      text.contains('should i') ||
      text.contains('what should') ||
      text.contains('watch');
}

String _localIntent(String question) {
  if (_looksFinancial(question)) {
    return 'finances';
  }
  if (_looksRecommendations(question)) {
    return 'recommendations';
  }
  return 'chat';
}

String? _allowedNavigate(String? raw) {
  return switch (raw?.trim()) {
    'dashboard' => 'dashboard',
    'transactions' || 'money' => 'transactions',
    'recordSale' || 'sale' => 'record-sale',
    'recordExpense' || 'expense' => 'record-expense',
    'products' || 'stock' => 'products',
    'cashFlow' || 'bills' => 'cash-flow',
    'recommendations' => 'recommendations',
    'reports' => 'reports',
    'settings' => 'settings',
    'businessProfile' || 'business' => 'business-profile',
    _ => null,
  };
}

String? _localNavigate(String question) {
  final text = question.toLowerCase();
  if (CopilotHandsFree.wantsOpenForm(text) &&
      (text.contains('sale') || text.contains('sold'))) {
    return 'record-sale';
  }
  if (CopilotHandsFree.wantsOpenForm(text) && text.contains('expense')) {
    return 'record-expense';
  }
  if (text.contains('open money') || text.contains('open transactions')) {
    return 'transactions';
  }
  return null;
}
