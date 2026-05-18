import 'dart:math' as math;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GaugeSegment {
  final String label;
  final double endValue;
  final Color color;
  const GaugeSegment({required this.label, required this.endValue, required this.color});
}

/// Responsive semicircle gauge. Fills whatever space ChartCard gives it.
class GaugeChart extends StatelessWidget {
  final double value;
  final double maxValue;
  final List<GaugeSegment> segments;
  final String centerLabel;
  final String? sublabel;

  const GaugeChart({
    super.key,
    required this.value,
    required this.maxValue,
    required this.segments,
    required this.centerLabel,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 280.0;
      final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 160.0;
      // The semicircle center is at bottom-center; radius constrained by both dims
      final radius = math.min(w * 0.42, h * 0.82);
      final strokeWidth = (radius * 0.18).clamp(12.0, 26.0);
      final labelFontSize = (radius * 0.22).clamp(14.0, 28.0);
      final sublabelFontSize = (radius * 0.12).clamp(10.0, 16.0);

      return Stack(alignment: Alignment.center, children: [
        CustomPaint(
          size: Size(w, h),
          painter: _GaugePainter(
            value: value.clamp(0, maxValue),
            maxValue: maxValue,
            segments: segments,
            strokeWidth: strokeWidth,
          ),
        ),
        Positioned(
          bottom: h * 0.06,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              centerLabel,
              style: TextStyle(fontSize: labelFontSize, fontWeight: FontWeight.bold),
            ),
            if (sublabel != null)
              Text(
                sublabel!,
                style: TextStyle(fontSize: sublabelFontSize, color: const Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
          ]),
        ),
        // Segment legend at bottom
        Positioned(
          bottom: 0,
          child: Wrap(
            spacing: 6,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            children: segments.map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
              const SizedBox(width: 3),
              Text(s.label, style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280))),
            ])).toList(),
          ),
        ),
      ]);
    });
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final List<GaugeSegment> segments;
  final double strokeWidth;

  const _GaugePainter({
    required this.value,
    required this.maxValue,
    required this.segments,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Center at 88% height so legend has room below
    final cy = size.height * 0.82;
    final radius = math.min(cx * 0.9, cy * 0.92);

    const startAngle = math.pi;
    const sweepTotal = math.pi;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Draw background track
    paint.color = const Color(0xFFE5E7EB);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle, sweepTotal, false, paint,
    );

    // Draw colored segments
    double prevEnd = 0;
    for (final seg in segments) {
      final sweep = (seg.endValue - prevEnd) / maxValue * sweepTotal;
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle + (prevEnd / maxValue * sweepTotal),
        sweep, false, paint,
      );
      prevEnd = seg.endValue;
    }

    // Needle
    final angle = startAngle + (value / maxValue) * sweepTotal;
    final needleLen = radius - strokeWidth * 0.6;
    final needlePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = (strokeWidth * 0.12).clamp(2.0, 4.0)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + needleLen * math.cos(angle), cy + needleLen * math.sin(angle)),
      needlePaint,
    );
    canvas.drawCircle(
        Offset(cx, cy), (strokeWidth * 0.22).clamp(4.0, 8.0),
        Paint()..color = const Color(0xFF1F2937));
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
