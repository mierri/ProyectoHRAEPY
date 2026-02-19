import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors, Column, Row, Expanded, Stack, Positioned, Card, AlertDialog, showDialog;
import 'package:ssapp/utils/theme.dart';

class DrawingCanvas extends StatefulWidget {
  final String title;
  final String? instructions;
  final SignatureController controller;
  final Widget? backgroundImage;
  final double height;
  final bool showColorPicker;

  const DrawingCanvas({
    super.key,
    required this.title,
    this.instructions,
    required this.controller,
    this.backgroundImage,
    this.height = 400,
    this.showColorPicker = false,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title and instructions
        if (widget.instructions != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title).medium().semiBold(),
                  const Gap(8),
                  Text(widget.instructions!).small().muted(),
                ],
              ),
            ),
          ),
          const Gap(16),
        ],

        // Drawing canvas
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: LightModeColors.lightSecondary.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Background image if provided
                if (widget.backgroundImage != null)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.3,
                      child: widget.backgroundImage!,
                    ),
                  ),
                // Signature pad
                Signature(
                  controller: widget.controller,
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),

        const Gap(16),

        // Toolbar
        Row(
          children: [
            // Clear button
            Expanded(
              child: OutlineButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Borrar dibujo'),
                      content: const Text('¿Está seguro que desea borrar todo el dibujo?'),
                      actions: [
                        OutlineButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        PrimaryButton(
                          onPressed: () {
                            widget.controller.clear();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Borrar'),
                        ),
                      ],
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.delete_outline, size: 18),
                    const Gap(8),
                    const Text('Borrar'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget for trail making test with numbered/lettered circles
class TrailMakingCanvas extends StatelessWidget {
  final SignatureController controller;

  const TrailMakingCanvas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DrawingCanvas(
      title: 'Test del Trazo Alterno',
      instructions: 'Dibuje una línea que conecte los números y letras en orden: 1→A→2→B→3→C→4→D→5→E',
      controller: controller,
      height: 500,
      backgroundImage: CustomPaint(
        painter: TrailMakingPainter(),
        child: Container(),
      ),
    );
  }
}

// Painter for trail making test circles
class TrailMakingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Define positions for circles (arranged randomly but logically)
    final positions = [
      {'label': '1', 'x': 0.15, 'y': 0.15, 'isStart': true},
      {'label': 'A', 'x': 0.45, 'y': 0.25},
      {'label': '2', 'x': 0.75, 'y': 0.15},
      {'label': 'B', 'x': 0.85, 'y': 0.45},
      {'label': '3', 'x': 0.65, 'y': 0.65},
      {'label': 'C', 'x': 0.35, 'y': 0.75},
      {'label': '4', 'x': 0.15, 'y': 0.55},
      {'label': 'D', 'x': 0.25, 'y': 0.35},
      {'label': '5', 'x': 0.55, 'y': 0.45},
      {'label': 'E', 'x': 0.85, 'y': 0.75, 'isEnd': true},
    ];

    for (var pos in positions) {
      final x = (pos['x'] as double) * size.width;
      final y = (pos['y'] as double) * size.height;
      final radius = 25.0;

      // Draw circle
      if (pos['isStart'] == true) {
        paint.color = Colors.green.withValues(alpha: 0.3);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), radius, paint);
        paint.color = Colors.green;
        paint.style = PaintingStyle.stroke;
      } else if (pos['isEnd'] == true) {
        paint.color = Colors.red.withValues(alpha: 0.3);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), radius, paint);
        paint.color = Colors.red;
        paint.style = PaintingStyle.stroke;
      } else {
        paint.color = Colors.black;
        paint.style = PaintingStyle.stroke;
      }

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Draw text
      textPainter.text = TextSpan(
        text: pos['label'] as String,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget for cube drawing test with reference image
class CubeDrawingCanvas extends StatelessWidget {
  final SignatureController controller;

  const CubeDrawingCanvas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DrawingCanvas(
      title: 'Dibujo de Cama/Cubo',
      instructions: 'Copie el dibujo de la cama tridimensional lo más preciso posible',
      controller: controller,
      height: 450,
      backgroundImage: CustomPaint(
        painter: CubePainter(),
        child: Container(),
      ),
    );
  }
}

// Painter for cube reference image
class CubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width * 0.3;
    final centerY = size.height * 0.4;
    final cubeSize = 80.0;

    // Draw a 3D cube as reference
    // Front face
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX + cubeSize, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + cubeSize, centerY),
      Offset(centerX + cubeSize, centerY + cubeSize),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + cubeSize, centerY + cubeSize),
      Offset(centerX, centerY + cubeSize),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY + cubeSize),
      Offset(centerX, centerY),
      paint,
    );

    // Back face (offset)
    final offset = cubeSize * 0.5;
    canvas.drawLine(
      Offset(centerX + offset, centerY - offset),
      Offset(centerX + cubeSize + offset, centerY - offset),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + cubeSize + offset, centerY - offset),
      Offset(centerX + cubeSize + offset, centerY + cubeSize - offset),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + cubeSize + offset, centerY + cubeSize - offset),
      Offset(centerX + offset, centerY + cubeSize - offset),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + offset, centerY + cubeSize - offset),
      Offset(centerX + offset, centerY - offset),
      paint,
    );

    // Connecting lines
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX + offset, centerY - offset),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + cubeSize, centerY),
      Offset(centerX + cubeSize + offset, centerY - offset),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + cubeSize, centerY + cubeSize),
      Offset(centerX + cubeSize + offset, centerY + cubeSize - offset),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY + cubeSize),
      Offset(centerX + offset, centerY + cubeSize - offset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget for clock drawing test
class ClockDrawingCanvas extends StatelessWidget {
  final SignatureController controller;

  const ClockDrawingCanvas({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DrawingCanvas(
      title: 'Dibujo del Reloj',
      instructions: 'Dibuje un reloj con todos los números y marque las 10:10 (diez y diez)',
      controller: controller,
      height: 450,
      backgroundImage: CustomPaint(
        painter: ClockGuidePainter(),
        child: Container(),
      ),
    );
  }
}

// Painter for clock guide (just a faint circle)
class ClockGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw a faint circle as guide
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

