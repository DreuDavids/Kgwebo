import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/app/config/config_providers.dart';
import 'package:kgwebo/app/theme/kgwebo_theme.dart';
import 'package:kgwebo/core/money/money_formatter.dart';
import 'package:kgwebo/features/authentication/application/session_controller.dart';
import 'package:kgwebo/features/authentication/domain/app_session.dart';
import 'package:kgwebo/features/authentication/domain/auth_failure.dart';
import 'package:kgwebo/features/authentication/domain/auth_user.dart';
import 'package:kgwebo/features/onboarding/domain/business_profile.dart';
import 'package:kgwebo/features/reports/application/report_controller.dart';
import 'package:kgwebo/features/reports/application/report_exporter.dart';
import 'package:kgwebo/features/reports/application/report_pdf.dart';
import 'package:kgwebo/features/reports/presentation/reports_screen.dart';
import '../../helpers/fake_auth.dart';
import '../../helpers/fake_products.dart';
import '../../helpers/fake_transactions.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_config.dart';

class FakeReportExporter implements ReportExporter {
  Uint8List? lastBytes;
  String? lastFilename;
  Object? nextError;
  int shareCalls = 0;

  @override
  Future<void> share({
    required Uint8List bytes,
    required String filename,
  }) async {
    shareCalls += 1;
    final error = nextError;
    nextError = null;
    if (error != null) {
      throw error;
    }
    lastBytes = bytes;
    lastFilename = filename;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> pumpReports(
    WidgetTester tester, {
    required FakeTransactionRepository repository,
    FakeReportExporter? exporter,
    bool stale = false,
    Size size = const Size(360, 800),
  }) async {
    await setSurface(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoryDatabaseOverride(),
          appConfigProvider.overrideWithValue(
            testConfig(anonKey: 'sb_publishable_test'),
          ),
          appSessionProvider.overrideWith(
            (ref) =>
                AppSessionReady(user: user, business: business, isStale: stale),
          ),
          currentOwnerIdProvider.overrideWithValue(user.id),
          authRepositoryProvider.overrideWith(
            (ref) => FakeAuthRepository(user: user),
          ),
          onboardingRepositoryProvider.overrideWith(
            (ref) => FakeOnboardingRepository(business: business),
          ),
          transactionRepositoryProvider.overrideWith((ref) => repository),
          productRepositoryProvider.overrideWith(
            (ref) => FakeProductRepository(),
          ),
          reportExporterProvider.overrideWithValue(
            exporter ?? FakeReportExporter(),
          ),
        ],
        child: MaterialApp(
          theme: KgweboTheme.light(),
          home: const ReportsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty period shows a clear empty state and zeros', (
    tester,
  ) async {
    await pumpReports(tester, repository: FakeTransactionRepository());
    expect(find.textContaining('No confirmed transactions'), findsWidgets);
    expect(find.text('P 0.00'), findsWidgets);
    expect(find.textContaining('cash-basis'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
  });

  testWidgets('preview matches engine totals and excludes pending rows', (
    tester,
  ) async {
    final repository =
        FakeTransactionRepository()
          ..items.addAll([
            sampleSale(amount: 50000),
            sampleExpense(amount: 10000),
            sampleSale(id: 'pending', amount: 7700, pendingSync: true),
          ]);
    await pumpReports(tester, repository: repository);
    expect(find.text('Kgale Stall'), findsOneWidget);
    expect(
      find.text(MoneyFormatter.formatMinor(50000, currencyCode: 'BWP')),
      findsWidgets,
    );
    expect(
      find.text(MoneyFormatter.formatMinor(10000, currencyCode: 'BWP')),
      findsWidgets,
    );
    expect(find.text('P 77.00'), findsNothing);
    expect(find.textContaining('No confirmed transactions'), findsNothing);
  });

  testWidgets('stale cache is labelled and still shows confirmed totals', (
    tester,
  ) async {
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    await pumpReports(tester, repository: repository, stale: true);
    expect(
      find.textContaining('Showing saved figures from this device'),
      findsWidgets,
    );
    expect(find.text('P 500.00'), findsWidgets);
  });

  testWidgets('export shares a PDF with the same filename pattern', (
    tester,
  ) async {
    final exporter = FakeReportExporter();
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    await pumpReports(tester, repository: repository, exporter: exporter);
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();
    expect(exporter.shareCalls, 1);
    expect(exporter.lastFilename, contains('Kgwebo-Kgale-Stall'));
    expect(exporter.lastFilename, endsWith('.pdf'));
    expect(exporter.lastBytes, isNotNull);
    expect(String.fromCharCodes(exporter.lastBytes!.take(5)), '%PDF-');
    expect(find.textContaining('PDF ready'), findsOneWidget);
  });

  testWidgets('export errors are shown without fake success', (tester) async {
    final exporter =
        FakeReportExporter()
          ..nextError = const ReportPdfException('Could not share the PDF.');
    final repository = FakeTransactionRepository()..items.add(sampleSale());
    await pumpReports(tester, repository: repository, exporter: exporter);
    await tester.tap(find.text('Export PDF'));
    await tester.pumpAndSettle();
    expect(find.text('Could not share the PDF.'), findsOneWidget);
    expect(find.textContaining('PDF ready'), findsNothing);
  });

  testWidgets('failed load is not shown as an empty zero report', (
    tester,
  ) async {
    final repository =
        FakeTransactionRepository()..nextError = const AuthFailure.network();
    await pumpReports(tester, repository: repository);
    expect(find.text('Could not load the report'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('reports layout does not overflow at 320x568', (tester) async {
    final overflows = <String>[];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) {
        overflows.add(text);
      }
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    final repository =
        FakeTransactionRepository()
          ..items.addAll([sampleSale(), sampleExpense()]);
    await pumpReports(
      tester,
      repository: repository,
      size: const Size(320, 568),
    );
    expect(overflows, isEmpty, reason: overflows.join('\n'));
    expect(find.text('Export PDF'), findsOneWidget);
  });
}
