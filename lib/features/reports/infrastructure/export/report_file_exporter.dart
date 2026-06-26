import 'dart:typed_data';

import 'report_file_exporter_native.dart'
    if (dart.library.html) 'report_file_exporter_web.dart' as exporter;

Future<void> saveReportFile({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) {
  return exporter.saveReportFile(
    bytes: bytes,
    filename: filename,
    mimeType: mimeType,
  );
}
