abstract final class ReportFileName {
  static String pdf({
    required String businessName,
    required String periodLabel,
  }) {
    final business = _sanitize(businessName, fallback: 'Business');
    final period = _sanitize(periodLabel, fallback: 'Period');
    return 'Kgwebo-$business-$period.pdf';
  }

  static String _sanitize(String raw, {required String fallback}) {
    final replaced = raw
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (replaced.isEmpty) {
      return fallback;
    }
    if (replaced.length <= 40) {
      return replaced;
    }
    return replaced.substring(0, 40).replaceAll(RegExp(r'-+$'), '');
  }
}
