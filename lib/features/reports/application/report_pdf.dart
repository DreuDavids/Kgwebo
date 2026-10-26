import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_copy.dart';
import '../domain/report_document.dart';

class ReportPdfException implements Exception {
  const ReportPdfException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Builds a PDF from a trusted [ReportDocument]. Never recalculates totals.
abstract final class ReportPdf {
  static const _ink = PdfColor.fromInt(0xFF111111);
  static const _onInk = PdfColor.fromInt(0xFFFFFFFF);
  static const _muted = PdfColor.fromInt(0xFF6B7280);
  static const _lime = PdfColor.fromInt(0xFFC6FF4A);
  static const _forest = PdfColor.fromInt(0xFF166534);
  static const _canvas = PdfColor.fromInt(0xFFF4F5F7);
  static const _line = PdfColor.fromInt(0xFFE6E8EC);

  static pw.ThemeData? _theme;

  static Future<pw.ThemeData> _loadTheme() async {
    final cached = _theme;
    if (cached != null) {
      return cached;
    }
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlusJakartaSans-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/PlusJakartaSans-Bold.ttf'),
    );
    return _theme = pw.ThemeData.withFont(base: regular, bold: bold);
  }

  static Future<Uint8List> build(ReportDocument report) async {
    try {
      final theme = await _loadTheme();
      final document = pw.Document(
        compress: false,
        title:
            '${report.businessName} - ${report.periodLabel} - ${report.currencyCode}',
        author: 'Kgwebo',
        creator: 'Kgwebo',
        subject:
            '${report.currencyCode} cash-basis summary for ${report.periodLabel}',
        theme: theme,
      );
      document.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 42),
            theme: theme,
          ),
          header: (context) => _header(report),
          footer: (context) => _footer(context),
          build: (context) => _body(report),
        ),
      );
      return await document.save();
    } catch (error) {
      if (error is ReportPdfException) {
        rethrow;
      }
      throw const ReportPdfException(
        'Could not create the PDF. Try again, or change the reporting period.',
      );
    }
  }

  static pw.Widget _header(ReportDocument report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: _ink,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(width: 8, height: 28, color: _lime),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Kgwebo report',
                      style: pw.TextStyle(
                        color: _lime,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      report.businessName.isEmpty
                          ? 'Business'
                          : report.businessName,
                      style: pw.TextStyle(
                        color: _onInk,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          '${report.periodLabel} - ${report.currencyCode} - ${report.zoneName}',
          style: pw.TextStyle(
            color: _forest,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Generated ${ReportCopy.generatedOn(report)}',
          style: const pw.TextStyle(color: _muted, fontSize: 9),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: _line, thickness: 0.8),
      ],
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Cash-basis records. Not audited accounts.',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: _muted, fontSize: 8),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _body(ReportDocument report) {
    return [
      if (report.businessType.isNotEmpty || report.countryLabel.isNotEmpty)
        pw.Text(
          [
            if (report.businessType.isNotEmpty) report.businessType,
            if (report.countryLabel.isNotEmpty) report.countryLabel,
          ].join(' - '),
          style: const pw.TextStyle(color: _muted, fontSize: 10),
        ),
      if (report.description != null) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          report.description!,
          style: const pw.TextStyle(color: _ink, fontSize: 10),
        ),
      ],
      pw.SizedBox(height: 14),
      if (report.isEmptyPeriod)
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          color: _canvas,
          child: pw.Text(
            'No confirmed transactions were recorded in this period.',
            style: pw.TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      pw.SizedBox(height: 12),
      pw.Text(
        'Financial summary',
        style: pw.TextStyle(
          color: _forest,
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 8),
      ...[
        for (final metric in ReportCopy.financialMetrics(report))
          _metricBlock(metric),
      ],
      pw.SizedBox(height: 12),
      pw.Text(
        'Transaction counts',
        style: pw.TextStyle(
          color: _forest,
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 8),
      ...[for (final metric in ReportCopy.counts(report)) _metricBlock(metric)],
      if (report.notes.isNotEmpty) ...[
        pw.SizedBox(height: 12),
        pw.Text(
          'Notes',
          style: pw.TextStyle(
            color: _forest,
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        for (final note in report.notes)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(
              note,
              style: const pw.TextStyle(color: _ink, fontSize: 10),
            ),
          ),
      ],
      pw.SizedBox(height: 14),
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        color: _canvas,
        child: pw.Text(
          report.disclaimer,
          style: const pw.TextStyle(color: _ink, fontSize: 9),
        ),
      ),
    ];
  }

  static pw.Widget _metricBlock(ReportMetric metric) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: _forest, width: 2.5)),
        color: _canvas,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            metric.label,
            style: const pw.TextStyle(color: _muted, fontSize: 9),
          ),
          pw.Text(
            metric.value,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (metric.caption != null)
            pw.Text(
              metric.caption!,
              style: const pw.TextStyle(color: _muted, fontSize: 8),
            ),
        ],
      ),
    );
  }
}
