import 'dart:math' as math;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class GaugeSegment {
  final String label;
  final double endValue;
  final Color color;
  const GaugeSegment({required this.label, required this.endValue, required this.color});
}

/// Semicircle gauge chart with colored segments and a needle.
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
      final size = math.min(constraints.maxWidth, 260.0);
      return SizedBox(
        height: size * 0.6,
        child: CustomPaint(
          size: Size(size, size * 0.6),
          painter: _GaugePainter(
            value: value.clamp(0, maxValue),
            maxValue: maxValue,
            segments: segments,
          ),
          child: Align(
            alignment: const Alignment(0, 0.6),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                centerLabel,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (sublabel != null)
                Text(sublabel!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            ]),
          ),
        ),
      );
    });
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final List<GaugeSegment> segments;

  const _GaugePainter({required this.value, required this.maxValue, required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.95;
    final radius = size.width * 0.46;
    const strokeWidth = 20.0;
    const startAngle = math.pi;
    const sweepTotal = math.pi;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double prevEnd = 0;
    for (final seg in segments) {
      final sweep = (seg.endValue - prevEnd) / maxValue * sweepTotal;
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle + (prevEnd / maxValue * sweepTotal),
        sweep,
        false,
        paint,
      );
      prevEnd = seg.endValue;
    }

    // Needle
    final angle = startAngle + (value / maxValue) * sweepTotal;
    final needlePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final needleLength = radius - strokeWidth / 2 - 4;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + needleLength * math.cos(angle), cy + needleLength * math.sin(angle)),
      needlePaint,
    );
    canvas.drawCircle(Offset(cx, cy), 5, Paint()..color = const Color(0xFF1F2937));
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
