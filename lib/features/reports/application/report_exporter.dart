import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'report_pdf.dart';

abstract class ReportExporter {
  Future<void> share({required Uint8List bytes, required String filename});
}

class DeviceReportExporter implements ReportExporter {
  DeviceReportExporter({
    Future<Directory> Function()? temporaryDirectory,
    Future<ShareResult> Function(String path, String filename)? shareFile,
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _shareFile = shareFile ?? _shareWithSheet;

  final Future<Directory> Function() _temporaryDirectory;
  final Future<ShareResult> Function(String path, String filename) _shareFile;

  Future<void> _deletePreviousReports(Directory directory) async {
    await for (final entity in directory.list()) {
      if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
        try {
          await entity.delete();
        } catch (_) {
          // Previous exports are best-effort cleanup.
        }
      }
    }
  }

  static Future<ShareResult> _shareWithSheet(String path, String filename) {
    return SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'application/pdf', name: filename)],
        title: filename,
        subject: filename,
      ),
    );
  }

  @override
  Future<void> share({
    required Uint8List bytes,
    required String filename,
  }) async {
    if (bytes.isEmpty) {
      throw const ReportPdfException('Could not create the PDF.');
    }
    try {
      final directory = await _temporaryDirectory();
      final reportsDir = Directory(p.join(directory.path, 'kgwebo_reports'));
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }
      await _deletePreviousReports(reportsDir);
      final file = File(p.join(reportsDir.path, filename));
      await file.writeAsBytes(bytes, flush: true);
      await _shareFile(file.path, filename);
    } on ReportPdfException {
      rethrow;
    } catch (_) {
      throw const ReportPdfException(
        'Could not share the PDF. Try again from this device.',
      );
    }
  }
}
