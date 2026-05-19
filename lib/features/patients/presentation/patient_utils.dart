import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

// ── Gender helpers ─────────────────────────────────────────────────────────────

String genderLabel(String gender) => switch (gender) {
      'M' => 'Masculino',
      'F' => 'Femenino',
      'O' => 'Otro',
      _ => gender,
    };

IconData genderIcon(String gender) => switch (gender) {
      'M' => material.Icons.male,
      'F' => material.Icons.female,
      'O' => material.Icons.transgender,
      _ => material.Icons.person,
    };

Color genderColor(String gender) => switch (gender) {
      'M' => LightModeColors.lightPrimary,
      'F' => const Color(0xFFEC4899),
      'O' => LightModeColors.lightSecondary,
      _ => LightModeColors.lightPrimary,
    };

// ── Score helpers ──────────────────────────────────────────────────────────────

String scoreLevel(int score, int surveyType) => switch (surveyType) {
      1 => score <= 13
          ? 'Mínima'
          : score <= 19
              ? 'Leve'
              : score <= 28
                  ? 'Moderada'
                  : 'Severa',
      2 => score <= 7
          ? 'Mínima'
          : score <= 15
              ? 'Leve'
              : score <= 25
                  ? 'Moderada'
                  : 'Severa',
      12 => score <= 11
          ? 'Bajo'
          : score <= 20
              ? 'Leve'
              : score <= 27
                  ? 'Moderado'
                  : 'Alto',
      13 => score <= 4
          ? 'Mínima'
          : score <= 9
              ? 'Leve'
              : score <= 14
                  ? 'Moderada'
                  : score <= 19
                      ? 'Mod. grave'
                      : 'Grave',
      _ => '',
    };

Color scoreLevelColor(int score, int surveyType) => switch (surveyType) {
      1 => score <= 13
          ? LightModeColors.lightTertiary
          : score <= 19
              ? const Color(0xFFFBBF24)
              : score <= 28
                  ? const Color(0xFFF97316)
                  : LightModeColors.lightError,
      2 => score <= 7
          ? LightModeColors.lightTertiary
          : score <= 15
              ? const Color(0xFFFBBF24)
              : score <= 25
                  ? const Color(0xFFF97316)
                  : LightModeColors.lightError,
      3 => const Color(0xFF7C3AED),
      5 => const Color(0xFF06B6D4),
      12 => score <= 11
          ? LightModeColors.lightTertiary
          : score <= 20
              ? const Color(0xFFFBBF24)
              : score <= 27
                  ? const Color(0xFFF97316)
                  : LightModeColors.lightError,
      13 => score <= 4
          ? LightModeColors.lightTertiary
          : score <= 9
              ? const Color(0xFFFBBF24)
              : score <= 14
                  ? const Color(0xFFF97316)
                  : score <= 19
                      ? const Color(0xFFDC2626)
                      : const Color(0xFFB91C1C),
      _ => LightModeColors.lightPrimary,
    };

// ── Average-score widgets for WHOQOL / SF-36 ──────────────────────────────────

String avgScoreLevel(double score) {
  if (score >= 4.0) return 'Excelente';
  if (score >= 3.5) return 'Muy bueno';
  if (score >= 3.0) return 'Bueno';
  if (score >= 2.5) return 'Regular';
  return 'Bajo';
}

Widget buildAvgScoreText(Map<String, dynamic> survey, Color color) {
  final responses = survey['responses'] as List? ?? [];
  if (responses.isEmpty) {
    return Text('Sin puntaje',
        style: TextStyle(fontSize: 12, color: LightModeColors.lightOnSurfaceVariant));
  }
  final total = responses.fold<int>(0, (s, r) => s + (r['answer_value'] as int? ?? 0));
  final avg = total / responses.length;
  return Text(
    'Promedio: ${avg.toStringAsFixed(1)}/5 — ${avgScoreLevel(avg)}',
    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
  );
}
