import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<void> saveReportFile({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) {
  return SharePlus.instance.share(
    ShareParams(
      files: [
        XFile.fromData(
          bytes,
          mimeType: mimeType,
          name: filename,
        ),
      ],
    ),
  );
}
