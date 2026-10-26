import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/core/finance/business_calendar.dart';
import 'package:kgwebo/core/finance/ledger_entry.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/reports/application/report_builder.dart';
import 'package:kgwebo/features/reports/application/report_copy.dart';
import 'package:kgwebo/features/reports/application/report_pdf.dart';

String pdfInfo(List<int> bytes) => latin1.decode(bytes, allowInvalid: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('pdf contains the same values as the preview copy', () async {
    const business = BusinessProfile(
      id: 'biz-1',
      ownerId: 'user-1',
      name: 'Kgale Stall',
      businessType: 'Informal trader',
      countryCode: 'BW',
      currencyCode: 'BWP',
      openingBalanceMinor: 200000,
    );
    final report = ReportBuilder.build(
      business: business,
      entries: [
        LedgerEntry(
          id: 'sale',
          type: MoneyMovementType.sale,
          amountMinor: 50000,
          currencyCode: 'BWP',
          occurredAt: BusinessCalendar.utcFromGaborone(
            year: 2026,
            month: 10,
            day: 10,
          ),
          paymentStatus: PaymentStatus.paid,
        ),
        LedgerEntry(
          id: 'exp',
          type: MoneyMovementType.expense,
          amountMinor: 10000,
          currencyCode: 'BWP',
          occurredAt: BusinessCalendar.utcFromGaborone(
            year: 2026,
            month: 10,
            day: 12,
          ),
          paymentStatus: PaymentStatus.paid,
        ),
      ],
      period: october,
      periodLabel: 'October 2026',
      generatedAt: generatedAt,
      isStale: false,
      historyIncomplete: false,
    );
    final bytes = await ReportPdf.build(report);
    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
    final info = pdfInfo(bytes);
    expect(info, contains('Kgale Stall'));
    expect(info, contains('October 2026'));
    expect(info, contains('BWP'));
    expect(info, contains('cash-basis summary'));
    expect(ReportCopy.financialMetrics(report).first.value, 'P 500.00');
    expect(
      ReportCopy.money(report, report.currentRecordedCashMinor),
      'P 2,400.00',
    );
  });

  test(
    'pdf uses the ZAR business currency rather than a BWP default',
    () async {
      const business = BusinessProfile(
        id: 'biz-za',
        ownerId: 'user-1',
        name: 'Cape Stall',
        businessType: 'Retail shop',
        countryCode: 'ZA',
        currencyCode: 'ZAR',
        openingBalanceMinor: 100000,
      );
      final report = ReportBuilder.build(
        business: business,
        entries: const [],
        period: october,
        periodLabel: 'October 2026',
        generatedAt: generatedAt,
        isStale: false,
        historyIncomplete: false,
      );
      final bytes = await ReportPdf.build(report);
      final info = pdfInfo(bytes);
      expect(info, contains('ZAR'));
      expect(info, isNot(contains('BWP')));
      expect(ReportCopy.money(report, 100000), 'ZAR 1,000.00');
    },
  );

  test('pdf handles empty periods and long business names', () async {
    const business = BusinessProfile(
      id: 'biz-1',
      ownerId: 'user-1',
      name:
          'Kgale Roadside Cooperative Fruit and Vegetable Stall with a Very Long Trading Name',
      businessType: 'Informal trader',
      countryCode: 'BW',
      currencyCode: 'BWP',
      openingBalanceMinor: 0,
    );
    final report = ReportBuilder.build(
      business: business,
      entries: const [],
      period: october,
      periodLabel: 'October 2026',
      generatedAt: generatedAt,
      isStale: false,
      historyIncomplete: false,
    );
    expect(report.isEmptyPeriod, isTrue);
    final bytes = await ReportPdf.build(report);
    expect(bytes, isNotEmpty);
    expect(latin1.decode(bytes.take(5).toList()), '%PDF-');
    final info = pdfInfo(bytes);
    expect(info, contains('Kgale Roadside Cooperative'));
    expect(report.isEmptyPeriod, isTrue);
  });

  test('pdf generation errors surface a readable failure', () {
    const error = ReportPdfException('Could not create the PDF.');
    expect(error.message, 'Could not create the PDF.');
    expect(error.toString(), contains('Could not create the PDF.'));
  });
}
