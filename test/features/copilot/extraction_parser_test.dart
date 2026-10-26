import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/core/money/money_limits.dart';
import 'package:kgwebo/features/copilot/application/extraction_parser.dart';

void main() {
  group('parseExtractionOutput', () {
    test('extracts a sale and an expense from the shirts example', () {
      const raw = '''
{
  "transactions": [
    {"type": "sale", "amount_pula": "300.00", "item": "shirts", "quantity": 2},
    {"type": "expense", "amount_pula": "80.00", "item": "transport", "category": "transport"}
  ]
}
''';

      final result = parseExtractionOutput(raw);

      expect(result.isRejected, isFalse);
      expect(result.drafts, hasLength(2));
      expect(result.drafts[0].type, MoneyMovementType.sale);
      expect(result.drafts[0].amountMinor, 30000);
      expect(result.drafts[0].item, 'shirts');
      expect(result.drafts[0].quantity, 2);
      expect(result.drafts[0].categoryCode, isNull);
      expect(result.drafts[0].occurredOn, isNull);
      expect(result.drafts[0].paymentStatus, isNull);
      expect(result.drafts[1].type, MoneyMovementType.expense);
      expect(result.drafts[1].amountMinor, 8000);
      expect(result.drafts[1].categoryCode, 'transport');
    });

    test('keeps missing amounts unknown instead of inventing them', () {
      const raw = '''
{"transactions":[{"type":"sale","item":"shirts"}]}
''';

      final result = parseExtractionOutput(raw);

      expect(result.isRejected, isFalse);
      expect(result.drafts, hasLength(1));
      expect(result.drafts.single.amountMinor, isNull);
      expect(result.drafts.single.missingRequired, contains('amount'));
    });

    test('ignores hallucinated dates and product ids', () {
      const raw = '''
{
  "transactions": [
    {
      "type": "sale",
      "amount_pula": "50.00",
      "occurred_on": "2020-01-01",
      "date": "yesterday",
      "product_id": "prod-invented",
      "payment_status": "paid"
    }
  ]
}
''';

      final result = parseExtractionOutput(raw);

      expect(result.drafts.single.occurredOn, isNull);
      expect(result.drafts.single.item, isNull);
      expect(result.drafts.single.paymentStatus, PaymentStatus.paid);
    });

    test('does not treat a ZAR amount as pula', () {
      final result = parseExtractionOutput(
        '{"transactions":[{"type":"expense","amount_pula":"100.00","currency":"ZAR","item":"domains"}]}',
      );

      expect(result.drafts.single.amountMinor, isNull);
      expect(result.drafts.single.detectedCurrencyCode, 'ZAR');
      expect(result.drafts.single.isComplete, isFalse);
    });

    test('keeps a ZAR amount when the profile currency is ZAR', () {
      final result = parseExtractionOutput(
        '{"transactions":[{"type":"expense","amount_pula":"100.00","currency":"ZAR","item":"domains","category":"fees","payment_status":"paid"}]}',
        currencyCode: 'ZAR',
      );

      expect(result.drafts.single.amountMinor, 10000);
      expect(result.drafts.single.detectedCurrencyCode, 'ZAR');
      expect(result.drafts.single.hasForeignCurrency, isFalse);
      expect(result.drafts.single.isComplete, isTrue);
    });

    test('rejects malformed JSON', () {
      final result = parseExtractionOutput('not json at all');

      expect(result.isRejected, isTrue);
      expect(result.drafts, isEmpty);
      expect(result.issues, isNotEmpty);
    });

    test('rejects negative, zero and oversized amounts', () {
      expect(
        parseExtractionOutput(
          '{"transactions":[{"type":"sale","amount_pula":"-10.00"}]}',
        ).rejectedItemCount,
        1,
      );
      expect(
        parseExtractionOutput(
          '{"transactions":[{"type":"sale","amount_pula":"0"}]}',
        ).rejectedItemCount,
        1,
      );
      expect(
        parseExtractionOutput(
          '{"transactions":[{"type":"sale","amount_pula":"${MoneyLimits.maxMinorUnits}"}]}',
        ).rejectedItemCount,
        1,
      );
    });

    test('rejects unsupported transaction types', () {
      final result = parseExtractionOutput(
        '{"transactions":[{"type":"refund","amount_pula":"20.00"}]}',
      );

      expect(result.drafts, isEmpty);
      expect(result.rejectedItemCount, 1);
      expect(result.issues.single, contains('unsupported'));
    });

    test('rejects invented categories that are not allowed codes', () {
      final result = parseExtractionOutput(
        '{"transactions":[{"type":"sale","amount_pula":"10.00","category":"mystery"}]}',
      );

      expect(result.drafts.single.categoryCode, isNull);
    });

    test('extracts JSON from surrounding model chatter', () {
      const raw = '''
Sure, here is the result:
```json
{"transactions":[{"type":"sale","amount_pula":"12.50"}]}
```
Hope that helps.
''';

      final result = parseExtractionOutput(raw);

      expect(result.drafts.single.amountMinor, 1250);
    });

    test('treats a whole JSON number as pula, not thebe', () {
      final result = parseExtractionOutput(
        '{"transactions":[{"type":"expense","amount_pula":80}]}',
      );

      expect(result.drafts.single.amountMinor, 8000);
    });

    test('rejects floating JSON numbers as unreliable money', () {
      final result = parseExtractionOutput(
        '{"transactions":[{"type":"sale","amount_pula":10.1}]}',
      );

      expect(result.drafts, isEmpty);
      expect(result.rejectedItemCount, 1);
    });
  });
}
