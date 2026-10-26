import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/financial_engine.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/reports/application/report_builder.dart';
import 'package:kgwebo/features/reports/domain/report_document.dart';

void main() {
  final october = ReportingPeriod(
    startInclusive: BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 10,
      day: 1,
    ),
    endExclusive: BusinessCalendar.utcFromGaborone(
      year: 2026,
      month: 11,
      day: 1,
    ),
  );
  final generatedAt = BusinessCalendar.utcFromGaborone(
    year: 2026,
    month: 10,
    day: 26,
    hour: 16,
  );

  const business = BusinessProfile(
    id: 'biz-1',
    ownerId: 'user-1',
    name: 'Kgale Stall',
    businessType: 'Informal trader',
    countryCode: 'BW',
    currencyCode: 'BWP',
    openingBalanceMinor: 200000,
    description: 'Roadside fruit stall',
    contactPhone: '+26771111111',
  );

  LedgerEntry entry({
    required String id,
    required MoneyMovementType type,
    required int amount,
    DateTime? occurredAt,
    PaymentStatus status = PaymentStatus.paid,
    String currency = 'BWP',
  }) {
    return LedgerEntry(
      id: id,
      type: type,
      amountMinor: amount,
      currencyCode: currency,
      occurredAt:
          occurredAt ??
          BusinessCalendar.utcFromGaborone(year: 2026, month: 10, day: 10),
      paymentStatus: status,
    );
  }

  ReportDocument buildDoc({
    BusinessProfile profile = business,
    Iterable<LedgerEntry>? entries,
    ReportingPeriod? period,
    String periodLabel = 'October 2026',
    bool isStale = false,
    bool historyIncomplete = false,
  }) {
    return ReportBuilder.build(
      business: profile,
      entries:
          entries ??
          [
            entry(id: 'sale', type: MoneyMovementType.sale, amount: 50000),
            entry(id: 'exp', type: MoneyMovementType.expense, amount: 10000),
            entry(
              id: 'in',
              type: MoneyMovementType.ownerContribution,
              amount: 20000,
            ),
            entry(
              id: 'out',
              type: MoneyMovementType.ownerWithdrawal,
              amount: 5000,
            ),
          ],
      period: period ?? october,
      periodLabel: periodLabel,
      generatedAt: generatedAt,
      isStale: isStale,
      historyIncomplete: historyIncomplete,
    );
  }

  test('report totals match the financial engine spec fixture', () {
    final entries = [
      entry(id: 'sale', type: MoneyMovementType.sale, amount: 50000),
      entry(id: 'exp', type: MoneyMovementType.expense, amount: 10000),
      entry(id: 'in', type: MoneyMovementType.ownerContribution, amount: 20000),
      entry(id: 'out', type: MoneyMovementType.ownerWithdrawal, amount: 5000),
    ];
    final engine = FinancialEngine.summarize(
      entries: entries,
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: generatedAt,
    );
    final report = buildDoc(entries: entries);

    expect(report.recordedSalesMinor, engine.recordedSalesMinor);
    expect(report.recordedRefundsMinor, engine.recordedRefundsMinor);
    expect(report.netRecordedSalesMinor, engine.netRecordedSalesMinor);
    expect(
      report.recordedOperatingExpensesMinor,
      engine.recordedOperatingExpensesMinor,
    );
    expect(
      report.netRecordedOperatingResultMinor,
      engine.netRecordedOperatingResultMinor,
    );
    expect(report.currentRecordedCashMinor, engine.currentCashMinor);
    expect(report.currentRecordedCashMinor, 255000);
    expect(report.recordedSalesMinor, 50000);
    expect(report.recordedOperatingExpensesMinor, 10000);
    expect(report.netRecordedOperatingResultMinor, 40000);
  });

  test('contributions and withdrawals are excluded from operating totals', () {
    final report = buildDoc();
    expect(report.recordedSalesMinor, isNot(255000));
    expect(report.recordedOperatingExpensesMinor, isNot(5000));
    expect(report.contributionCount, 1);
    expect(report.withdrawalCount, 1);
    expect(
      report.notes.any((note) => note.toLowerCase().contains('contribution')),
      isTrue,
    );
  });

  test('refunds reduce net sales using engine rules', () {
    final entries = [
      entry(id: 'sale', type: MoneyMovementType.sale, amount: 50000),
      entry(id: 'refund', type: MoneyMovementType.refund, amount: 10000),
    ];
    final engine = FinancialEngine.summarize(
      entries: entries,
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: generatedAt,
    );
    final report = buildDoc(entries: entries);
    expect(report.recordedRefundsMinor, 10000);
    expect(report.netRecordedSalesMinor, engine.netRecordedSalesMinor);
    expect(report.netRecordedSalesMinor, 40000);
    expect(report.refundCount, 1);
  });

  test('unpaid sales are recorded sales and not recorded cash', () {
    final entries = [
      entry(
        id: 'unpaid',
        type: MoneyMovementType.sale,
        amount: 50000,
        status: PaymentStatus.unpaid,
      ),
    ];
    final engine = FinancialEngine.summarize(
      entries: entries,
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: generatedAt,
    );
    final report = buildDoc(entries: entries);
    expect(report.recordedSalesMinor, 50000);
    expect(report.unpaidSalesMinor, engine.unpaidSalesMinor);
    expect(report.currentRecordedCashMinor, 200000);
    expect(
      report.notes.any((note) => note.toLowerCase().contains('unpaid')),
      isTrue,
    );
  });

  test('empty period keeps opening cash and zeros period totals', () {
    final report = buildDoc(entries: const []);
    expect(report.isEmptyPeriod, isTrue);
    expect(report.recordedSalesMinor, 0);
    expect(report.recordedOperatingExpensesMinor, 0);
    expect(report.netRecordedOperatingResultMinor, 0);
    expect(report.confirmedInPeriodCount, 0);
    expect(report.currentRecordedCashMinor, 200000);
  });

  test('currency comes from the business record, including ZAR', () {
    const zar = BusinessProfile(
      id: 'biz-za',
      ownerId: 'user-1',
      name: 'Cape Stall',
      businessType: 'Retail shop',
      countryCode: 'ZA',
      currencyCode: 'ZAR',
      openingBalanceMinor: 100000,
    );
    final entries = [
      entry(
        id: 'sale',
        type: MoneyMovementType.sale,
        amount: 25000,
        currency: 'ZAR',
      ),
    ];
    final report = buildDoc(profile: zar, entries: entries);
    expect(report.currencyCode, 'ZAR');
    expect(report.recordedSalesMinor, 25000);
    expect(report.currentRecordedCashMinor, 125000);
  });

  test('uses Gaborone period boundaries and omits later months', () {
    final novemberSale = entry(
      id: 'nov',
      type: MoneyMovementType.sale,
      amount: 90000,
      occurredAt: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 11,
        day: 1,
      ),
    );
    final lastOfOctober = entry(
      id: 'oct-end',
      type: MoneyMovementType.sale,
      amount: 12000,
      occurredAt: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 10,
        day: 31,
        hour: 23,
        minute: 59,
      ),
    );
    final report = buildDoc(entries: [novemberSale, lastOfOctober]);
    expect(report.recordedSalesMinor, 12000);
    expect(report.saleCount, 1);
    expect(report.confirmedInPeriodCount, 1);
  });

  test('period opening cash uses engine cash just before the period', () {
    final septemberSale = entry(
      id: 'sep',
      type: MoneyMovementType.sale,
      amount: 30000,
      occurredAt: BusinessCalendar.utcFromGaborone(
        year: 2026,
        month: 9,
        day: 15,
      ),
    );
    final octoberSale = entry(
      id: 'oct',
      type: MoneyMovementType.sale,
      amount: 50000,
    );
    final entries = [septemberSale, octoberSale];
    final beforePeriod = october.startInclusive.subtract(
      const Duration(microseconds: 1),
    );
    final opening = FinancialEngine.summarize(
      entries: entries,
      openingCashMinor: 200000,
      currencyCode: 'BWP',
      period: october,
      asOf: beforePeriod,
    );
    final report = buildDoc(entries: entries);
    expect(report.periodOpeningCashMinor, opening.currentCashMinor);
    expect(report.periodOpeningCashMinor, 230000);
    expect(report.periodClosingCashMinor, 280000);
  });

  test('omits period opening cash when history is incomplete', () {
    final report = buildDoc(historyIncomplete: true);
    expect(report.periodOpeningCashMinor, isNull);
    expect(report.periodClosingCashMinor, isNull);
    expect(
      report.notes.any((note) => note.toLowerCase().contains('opening cash')),
      isTrue,
    );
  });

  test('does not include phone numbers or owner ids', () {
    final report = buildDoc();
    expect(report.businessName, 'Kgale Stall');
    expect(report.businessType, 'Informal trader');
    expect(report.description, 'Roadside fruit stall');
    expect(report.contactPhone, isNull);
    expect(report.ownerId, isNull);
    expect(report.disclaimer.toLowerCase(), contains('cash-basis'));
    expect(report.disclaimer.toLowerCase(), contains('not audited'));
  });

  test('stale reports are labelled and still use confirmed engine totals', () {
    final report = buildDoc(isStale: true);
    expect(report.isStale, isTrue);
    expect(report.currentRecordedCashMinor, 255000);
    expect(
      report.notes.any((note) => note.toLowerCase().contains('saved')),
      isTrue,
    );
  });
}
