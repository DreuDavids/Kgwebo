import 'package:flutter_test/flutter_test.dart';
import 'package:kgwebo/features/reports/application/report_file_name.dart';

void main() {
  test('builds a filesystem-safe name from business and period', () {
    expect(
      ReportFileName.pdf(
        businessName: 'Kgale Stall',
        periodLabel: 'October 2026',
      ),
      'Kgwebo-Kgale-Stall-October-2026.pdf',
    );
  });

  test('strips characters that are unsafe on Android filesystems', () {
    expect(
      ReportFileName.pdf(
        businessName: 'Mama\'s Stall / "Best" fruit?*',
        periodLabel: '1–31 Oct 2026',
      ),
      matches(RegExp(r'^Kgwebo-[A-Za-z0-9-]+-[A-Za-z0-9-]+\.pdf$')),
    );
    expect(
      ReportFileName.pdf(
        businessName: 'Mama\'s Stall / "Best" fruit?*',
        periodLabel: '1–31 Oct 2026',
      ),
      isNot(contains('/')),
    );
    expect(
      ReportFileName.pdf(
        businessName: 'Mama\'s Stall / "Best" fruit?*',
        periodLabel: '1–31 Oct 2026',
      ),
      isNot(contains('*')),
    );
  });

  test('falls back when the business name is empty', () {
    expect(
      ReportFileName.pdf(businessName: '   ', periodLabel: '2026'),
      'Kgwebo-Business-2026.pdf',
    );
  });
}
