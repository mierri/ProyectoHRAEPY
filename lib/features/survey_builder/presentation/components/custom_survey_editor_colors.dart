import 'package:shadcn_flutter/shadcn_flutter.dart';

const customSurveyColorPresets = [
  '#0D9488',
  '#0891B2',
  '#7C3AED',
  '#DB2777',
  '#EA580C',
  '#16A34A',
];

Color parseCustomSurveyColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

String customSurveyColorToHex(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

String? normalizeCustomSurveyHexInput(String raw) {
  final sanitized = raw.trim().replaceFirst('#', '').toUpperCase();
  final hexPattern = RegExp(r'^[0-9A-F]{6}$');
  if (!hexPattern.hasMatch(sanitized)) {
    return null;
  }
  return '#$sanitized';
}
