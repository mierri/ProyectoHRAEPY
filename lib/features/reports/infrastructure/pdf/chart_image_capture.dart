import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders the [RepaintBoundary] attached to [key] as a PNG byte array.
/// Returns null if the widget is not yet laid out or capture fails.
/// Call only after the frame is drawn (e.g. in a post-frame callback).
Future<Uint8List?> captureChart(GlobalKey key, {double pixelRatio = 2.0}) async {
  try {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } catch (_) {
    return null;
  }
}
