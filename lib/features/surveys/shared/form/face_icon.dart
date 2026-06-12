import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Claves de los iconos de "carita" disponibles para que la doctora
/// asigne a cada opción de respuesta (mismos iconos usados en el resto de la app),
/// en escala de rojo (negativo) a verde a azul (positivo).
const List<String> faceIconKeys = [
  'sentiment_very_dissatisfied',
  'sentiment_dissatisfied',
  'sentiment_neutral',
  'sentiment_satisfied',
  'sentiment_very_satisfied',
  'sentiment_calm',
];

/// Resuelve la clave guardada en [CustomOptionDef.emoji]/[SurveyChoice.emoji]
/// al icono correspondiente.
IconData? faceIconForKey(String? key) {
  switch (key) {
    case 'sentiment_very_dissatisfied':
      return Symbols.sentiment_very_dissatisfied;
    case 'sentiment_dissatisfied':
      return Symbols.sentiment_dissatisfied;
    case 'sentiment_neutral':
      return Symbols.sentiment_neutral;
    case 'sentiment_satisfied':
      return Symbols.sentiment_satisfied;
    case 'sentiment_very_satisfied':
      return Symbols.sentiment_very_satisfied;
    case 'sentiment_calm':
      return Symbols.sentiment_calm;
    default:
      return null;
  }
}

/// Color asociado a cada "carita", en escala de rojo -> verde -> azul.
Color faceColorForKey(String? key) {
  switch (key) {
    case 'sentiment_very_dissatisfied':
      return const Color(0xFFDC2626);
    case 'sentiment_dissatisfied':
      return const Color(0xFFF97316);
    case 'sentiment_neutral':
      return const Color(0xFFEAB308);
    case 'sentiment_satisfied':
      return const Color(0xFF22C55E);
    case 'sentiment_very_satisfied':
      return const Color(0xFF14B8A6);
    case 'sentiment_calm':
      return const Color(0xFF3B82F6);
    default:
      return const Color(0xFF6B7280);
  }
}
