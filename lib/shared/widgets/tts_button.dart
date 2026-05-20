import 'package:flutter/material.dart';
import 'package:ssapp/shared/utils/tts_service.dart';

/// Boton de texto a voz reutilizable.
///
/// Uso basico:
/// TtsButton(text: 'Texto a leer en voz alta')
///
/// Parametros opcionales:
/// - [size] tamano del icono (default 22)
/// - [color] color del icono (default primary del tema)
/// - [tooltip] texto del tooltip (default 'Escuchar')
class TtsButton extends StatefulWidget {
  final String text;
  final double size;
  final Color? color;
  final String tooltip;

  const TtsButton({
    super.key,
    required this.text,
    this.size = 22,
    this.color,
    this.tooltip = 'Escuchar',
  });

  @override
  State<TtsButton> createState() => _TtsButtonState();
}

class _TtsButtonState extends State<TtsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  bool get _isActive => TtsService.instance.isReadingText(widget.text);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    TtsService.instance.addListener(_onTtsChanged);
  }

  @override
  void dispose() {
    TtsService.instance.removeListener(_onTtsChanged);
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onTtsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _toggle() async {
    await TtsService.instance.speak(widget.text);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final inactiveColor = activeColor.withValues(alpha: 0.55);

    return Tooltip(
      message: _isActive ? 'Detener' : widget.tooltip,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _isActive ? _pulseAnim.value : 1.0,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: widget.size + 14,
            height: widget.size + 14,
            decoration: BoxDecoration(
              color: _isActive
                  ? activeColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isActive ? activeColor : inactiveColor,
                width: _isActive ? 1.8 : 1.2,
              ),
            ),
            child: Center(
              child: Icon(
                _isActive ? Icons.stop_rounded : Icons.volume_up_rounded,
                size: widget.size,
                color: _isActive ? activeColor : inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Variante compacta del TtsButton, ideal para colocarlo inline junto a un
/// texto corto.
class TtsIconButton extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;

  const TtsIconButton({
    super.key,
    required this.text,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TtsButton(text: text, size: size, color: color);
  }
}
