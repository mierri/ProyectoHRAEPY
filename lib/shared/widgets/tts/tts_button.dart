import 'package:flutter/material.dart' as material show Icons;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/services/tts/tts_provider.dart';

/// Requiere que [TtsProvider] esté disponible en el árbol de widgets.
class TtsButton extends StatelessWidget {
  final String text;

  /// Tamaño del icono (default 20).
  final double iconSize;

  /// Si es true, muestra el botón con fondo (estilo outlined).
  final bool outlined;

  const TtsButton({
    super.key,
    required this.text,
    this.iconSize = 20,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TtsProvider>(
      builder: (context, tts, _) {
        final isActive = tts.currentText == text.trim() &&
            (tts.isPlaying || tts.isLoading);

        if (outlined) {
          return _OutlinedTtsButton(
            text: text,
            isActive: isActive,
            isLoading: tts.isLoading && tts.currentText == text.trim(),
            iconSize: iconSize,
            onTap: () => tts.speak(text),
          );
        }

        return _IconTtsButton(
          text: text,
          isActive: isActive,
          isLoading: tts.isLoading && tts.currentText == text.trim(),
          iconSize: iconSize,
          onTap: () => tts.speak(text),
        );
      },
    );
  }
}

/// Versión solo icono
class _IconTtsButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isLoading;
  final double iconSize;
  final VoidCallback onTap;

  const _IconTtsButton({
    required this.text,
    required this.isActive,
    required this.isLoading,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? SizedBox(
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        )
            : Icon(
          isActive
              ? material.Icons.stop_circle_outlined
              : material.Icons.volume_up_outlined,
          size: iconSize,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.mutedForeground,
        ),
      ),
    );
  }
}

/// Versión con borde y texto
class _OutlinedTtsButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isLoading;
  final double iconSize;
  final VoidCallback onTap;

  const _OutlinedTtsButton({
    required this.text,
    required this.isActive,
    required this.isLoading,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color : Theme.of(context).colorScheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color),
            )
                : Icon(
              isActive
                  ? material.Icons.stop_circle_outlined
                  : material.Icons.volume_up_outlined,
              size: iconSize,
              color: isActive
                  ? color
                  : Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(6),
            Text(
              isActive ? 'Detener' : 'Escuchar',
              style: TextStyle(
                fontSize: 13,
                color: isActive
                    ? color
                    : Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}