import 'package:flutter/material.dart';

enum LumiVariant {
  /// lumi 1.0 — morado, saludando con la mano (bienvenida)
  waving,

  /// lumi 2.0 — verde, con burbujas de interrogación (pensando)
  thinking,

  /// lumi 3.0 — morado, con gafas, portapapeles y lápiz (consentimiento)
  consent,

  /// lumi 4.0 — rosa, con corazón y ondas (cariño)
  caring,

  /// lumi_5.0 — verde brillante, ojos estrella, brazos arriba (celebración)
  celebrating,

  /// lumi 6.0 — morado, brazos arriba con corazón (logro)
  cheering,

  /// lumi 7.0 — morado, pensativo con nubes ¿Acepto? / ¿No acepto?
  deciding,
}

extension _LumiAsset on LumiVariant {
  String get assetPath {
    switch (this) {
      case LumiVariant.waving:
        return 'assets/lumi 1.0.png';
      case LumiVariant.thinking:
        return 'assets/lumi 2.0.png';
      case LumiVariant.consent:
        return 'assets/lumi 3.0 consentimiento.png';
      case LumiVariant.caring:
        return 'assets/lumi 4.0.png';
      case LumiVariant.celebrating:
        return 'assets/lumi_5.0.png';
      case LumiVariant.cheering:
        return 'assets/lumi 6.0.png';
      case LumiVariant.deciding:
        return 'assets/lumi 7.0.png';
    }
  }
}

/// Muestra a Lumi con un mensaje opcional en burbuja de diálogo.
class LumiWidget extends StatelessWidget {
  final LumiVariant variant;
  final double size;
  final String? message;
  final Color? bubbleColor;

  const LumiWidget({
    super.key,
    required this.variant,
    this.size = 120,
    this.message,
    this.bubbleColor,
  });

  @override
  Widget build(BuildContext context) {
    final lumiImage = Image.asset(
      variant.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (message == null) return lumiImage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SpeechBubble(
          message: message!,
          bubbleColor: bubbleColor ?? const Color(0xFFEDE9FF),
        ),
        const SizedBox(height: 4),
        lumiImage,
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String message;
  final Color bubbleColor;

  const _SpeechBubble({required this.message, required this.bubbleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: Color(0xFF3D2B8F),
        ),
      ),
    );
  }
}

/// Fila horizontal: Lumi a la izquierda, texto a la derecha.
/// Útil para encabezados de pantalla.
class LumiHeaderRow extends StatelessWidget {
  final LumiVariant variant;
  final double lumiSize;
  final Widget child;

  const LumiHeaderRow({
    super.key,
    required this.variant,
    required this.child,
    this.lumiSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LumiWidget(variant: variant, size: lumiSize),
        const SizedBox(width: 16),
        Expanded(child: child),
      ],
    );
  }
}
