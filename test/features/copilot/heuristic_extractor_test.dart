import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/copilot/application/heuristic_extractor.dart';

void main() {
  test('does not convert 50zar each into pula', () {
    final drafts = extractHeuristicDrafts('I bought two domains at 50zar each');

    expect(drafts, hasLength(1));
    expect(drafts.single.type, MoneyMovementType.expense);
    expect(drafts.single.detectedCurrencyCode, 'ZAR');
    expect(drafts.single.amountMinor, isNull);
    expect(drafts.single.quantity, 2);
    expect(drafts.single.isComplete, isFalse);
  });

  test('multiplies a named pula unit price by quantity', () {
    final drafts = extractHeuristicDrafts('I sold two shirts for P150 each');

    expect(drafts.single.type, MoneyMovementType.sale);
    expect(drafts.single.amountMinor, 30000);
    expect(drafts.single.detectedCurrencyCode, 'BWP');
  });

  test('prefills two domains at 50 pula each as 100 pula', () {
    final drafts = extractHeuristicDrafts(
      'I bought two domains at 50 pula each',
    );

    expect(drafts, hasLength(1));
    expect(drafts.single.type, MoneyMovementType.expense);
    expect(drafts.single.item, 'domains');
    expect(drafts.single.detectedCurrencyCode, 'BWP');
    expect(drafts.single.quantity, 2);
    expect(drafts.single.amountMinor, 10000);
  });

  test('extracts a transport expense in pula', () {
    final drafts = extractHeuristicDrafts('I spent P80 on transport');

    expect(drafts.single.amountMinor, 8000);
    expect(drafts.single.categoryCode, 'transport');
  });

  test('prefills two domains at 50 each in the business currency', () {
    final drafts = extractHeuristicDrafts(
      'hey I bought 2 domains at 50 each, can you please record this for me',
    );

    expect(drafts, hasLength(1));
    expect(drafts.single.type, MoneyMovementType.expense);
    expect(drafts.single.item, 'domains');
    expect(drafts.single.quantity, 2);
    expect(drafts.single.amountMinor, 10000);
    expect(drafts.single.categoryCode, 'fees');
    expect(drafts.single.paymentStatus, PaymentStatus.paid);
    expect(drafts.single.detectedCurrencyCode, 'BWP');
    expect(drafts.single.hasForeignCurrency, isFalse);
  });

  test('uses the profile currency for unnamed amounts', () {
    final drafts = extractHeuristicDrafts(
      'I bought 2 domains at 50 each',
      currencyCode: 'ZAR',
    );

    expect(drafts.single.amountMinor, 10000);
    expect(drafts.single.detectedCurrencyCode, 'ZAR');
    expect(drafts.single.hasForeignCurrency, isFalse);
  });

  test('sells two fat cakes at 10 each as 20 in the book currency', () {
    final drafts = extractHeuristicDrafts('I sold two fat cakes at 10 each');

    expect(drafts.single.type, MoneyMovementType.sale);
    expect(drafts.single.item, 'fat cakes');
    expect(drafts.single.amountMinor, 2000);
    expect(drafts.single.categoryCode, 'goods');
  });

  test('records airtime 50 as a utilities expense', () {
    final drafts = extractHeuristicDrafts('I bought airtime 50');

    expect(drafts.single.type, MoneyMovementType.expense);
    expect(drafts.single.item, 'airtime');
    expect(drafts.single.amountMinor, 5000);
    expect(drafts.single.categoryCode, 'utilities');
  });

  test('treats on credit as unpaid', () {
    final drafts = extractHeuristicDrafts(
      'I sold two shirts for P300 on credit',
    );

    expect(drafts.single.paymentStatus, PaymentStatus.unpaid);
  });

  test('dates a purchase to yesterday in Gaborone', () {
    final drafts = extractHeuristicDrafts(
      'I spent P80 on transport yesterday',
      now: DateTime.utc(2026, 10, 21, 10),
    );

    expect(drafts.single.occurredOn, DateTime.utc(2026, 10, 19, 22));
  });

  test('reads a mixed Setswana sale', () {
    final drafts = extractHeuristicDrafts(
      'Ke rekisitse dihempe di le 2 ka P150 each',
    );

    expect(drafts.single.type, MoneyMovementType.sale);
    expect(drafts.single.item, 'shirts');
    expect(drafts.single.amountMinor, 30000);
  });

  test('drafts an owner withdrawal', () {
    final drafts = extractHeuristicDrafts('I took 200 for myself');

    expect(drafts.single.type, MoneyMovementType.ownerWithdrawal);
    expect(drafts.single.amountMinor, 20000);
    expect(drafts.single.categoryCode, 'owner_withdrawal');
  });

  test('does not treat named pula as rand when the profile is ZAR', () {
    final drafts = extractHeuristicDrafts(
      'I bought two domains at 50 pula each',
      currencyCode: 'ZAR',
    );

    expect(drafts.single.detectedCurrencyCode, 'BWP');
    expect(drafts.single.amountMinor, isNull);
    expect(drafts.single.hasForeignCurrency, isTrue);
  });
}
