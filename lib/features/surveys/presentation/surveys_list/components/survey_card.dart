import 'package:flutter/material.dart' as material show Icons;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

class SurveyListCard extends StatelessWidget {
  final Map<String, dynamic> survey;
  const SurveyListCard({super.key, required this.survey});

  Color get _surveyColor {
    switch (survey['survey_type'] as int? ?? 1) {
      case 1:  return LightModeColors.lightPrimary;
      case 2:  return LightModeColors.lightTertiary;
      case 3:  return const Color(0xFF7C3AED);
      case 5:  return const Color(0xFF06B6D4);
      case 6:  return LightModeColors.lightSecondary;
      case 7:  return const Color(0xFF0EA5E9);
      case 8:  return const Color(0xFF14B8A6);
      case 9:  return const Color(0xFF145374);
      case 10: return const Color(0xFF0D9488);
      case 11: return const Color(0xFF2563EB);
      case 12: return const Color(0xFF0284C7);
      case 13: return const Color(0xFF9333EA);
      case 14: return const Color(0xFF4F46E5);
      case 15: return const Color(0xFF0F766E);
      default: return LightModeColors.lightPrimary;
    }
  }

  String get _typeName {
    switch (survey['survey_type'] as int? ?? 1) {
      case 1:  return 'BDI-II';
      case 2:  return 'BAI';
      case 3:  return 'WHOQOL-BREF';
      case 5:  return 'SF-36';
      case 6:  return 'ASSIST';
      case 7:  return 'GDS-15';
      case 8:  return 'Lawton AIVD';
      case 9:  return 'Osteoporosis';
      case 10: return 'Katz ABVD';
      case 11: return 'ICIQ-SF';
      case 12: return 'GHQ-12';
      case 13: return 'PHQ-9';
      case 14: return 'Sociodemografico';
      case 15: return 'Determinantes Sociales';
      default: return 'Encuesta';
    }
  }

  bool get _hasScore {
    final type = survey['survey_type'] as int? ?? 1;
    return type != 14 && type != 15;
  }

  int get _expectedResponses {
    switch (survey['survey_type'] as int? ?? 1) {
      case 3:  return 26;
      case 5:  return 36;
      case 7:  return 15;
      case 8:  return 8;
      case 9:  return 7;
      case 10: return 6;
      case 11: return 4;
      case 12: return 12;
      case 13: return 9;
      case 14: return 15;
      case 15: return 15;
      default: return 21;
    }
  }

  int get _score {
    final responses = survey['responses'] as List?;
    if (responses == null || responses.isEmpty) return 0;
    if ((survey['survey_type'] as int? ?? 1) == 11) {
      return responses.fold<int>(0, (s, r) {
        final qId = r['question_id'] as int? ?? 0;
        return qId == 4 ? s : s + (r['answer_value'] as int? ?? 0);
      });
    }
    return responses.fold<int>(0, (s, r) => s + (r['answer_value'] as int? ?? 0));
  }

  String _level(int score, int type) {
    if (type == 1)  { if (score <= 13) return 'Mínima'; if (score <= 19) return 'Leve'; if (score <= 28) return 'Moderada'; return 'Grave'; }
    if (type == 2)  { if (score <= 7)  return 'Mínima'; if (score <= 15) return 'Leve'; if (score <= 25) return 'Moderada'; return 'Severa'; }
    if (type == 3)  return 'WHOQOL';
    if (type == 5)  return 'SF-36';
    if (type == 7)  return score <= 4 ? 'Normal' : 'Síntomas depresivos';
    if (type == 8)  return score == 8 ? 'Independencia total' : 'Deterioro funcional';
    if (type == 9)  return 'Puntaje: $score';
    if (type == 10) return score == 6 ? 'Independencia total' : 'Dependencia en algun grado';
    if (type == 11) { if (score == 0) return 'Sin incontinencia'; if (score <= 5) return 'Leve'; if (score <= 12) return 'Moderada'; return 'Severa'; }
    if (type == 12) { if (score <= 11) return 'Bajo'; if (score <= 20) return 'Leve'; if (score <= 27) return 'Moderado'; return 'Alto'; }
    if (type == 13) { if (score <= 4) return 'Minima'; if (score <= 9) return 'Leve'; if (score <= 14) return 'Moderada'; if (score <= 19) return 'Moderadamente grave'; return 'Grave'; }
    return '';
  }

  Color _levelColor(int score, int type) {
    if (type == 1) { if (score <= 13) return LightModeColors.lightTertiary; if (score <= 19) return const Color(0xFFFFA726); if (score <= 28) return const Color(0xFFFF7043); return LightModeColors.lightError; }
    if (type == 2) { if (score <= 7) return LightModeColors.lightTertiary; if (score <= 15) return const Color(0xFFFFA726); if (score <= 25) return const Color(0xFFFF7043); return LightModeColors.lightError; }
    if (type == 3) return const Color(0xFF7C3AED);
    if (type == 5) return const Color(0xFF06B6D4);
    if (type == 7) return score <= 4 ? LightModeColors.lightTertiary : LightModeColors.lightError;
    if (type == 8) return score == 8 ? LightModeColors.lightTertiary : const Color(0xFFF59E0B);
    if (type == 9) return const Color(0xFF145374);
    if (type == 10) return score == 6 ? LightModeColors.lightTertiary : const Color(0xFFF59E0B);
    if (type == 11) { if (score == 0) return LightModeColors.lightTertiary; if (score <= 5) return const Color(0xFFFBBF24); if (score <= 12) return const Color(0xFFF97316); return LightModeColors.lightError; }
    if (type == 12) { if (score <= 11) return LightModeColors.lightTertiary; if (score <= 20) return const Color(0xFFFBBF24); if (score <= 27) return const Color(0xFFF97316); return LightModeColors.lightError; }
    if (type == 13) { if (score <= 4) return LightModeColors.lightTertiary; if (score <= 9) return const Color(0xFFFBBF24); if (score <= 14) return const Color(0xFFF97316); if (score <= 19) return const Color(0xFFDC2626); return const Color(0xFFB91C1C); }
    if (type == 14) return const Color(0xFF4F46E5);
    if (type == 15) return const Color(0xFF0F766E);
    return LightModeColors.lightPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final patientService = context.watch<PatientService>();
    final patientId = survey['patient_id'] as int?;
    final patientName = patientId == null ? 'Sin paciente' : () {
      try { return patientService.patients.firstWhere((p) => p.patientId == patientId).name; }
      catch (_) { return 'Paciente no encontrado'; }
    }();

    final createdAt  = DateTime.parse(survey['created_at'] as String);
    final isSynced   = survey['synced'] == true;
    final responses  = survey['responses'] as List?;
    final totalResp  = responses?.length ?? 0;
    final surveyType = survey['survey_type'] as int? ?? 1;
    final expected   = _expectedResponses;
    final isComplete = expected == 0 ? true : totalResp >= expected;
    final score      = _score;
    final level      = _level(score, surveyType);
    final levelColor = _levelColor(score, surveyType);
    final color      = _surveyColor;
    final respLabel  = isComplete ? 'Completa' : '$totalResp/$expected respuestas';

    return GestureDetector(
      onTap: isComplete && _hasScore
          ? () => showCenteredToast(context,
              title: 'Resultados', subtitle: 'Score: $score - $level',
              icon: material.Icons.analytics, iconColor: levelColor,
              location: ToastLocation.bottomCenter)
          : null,
      child: OutlinedContainer(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        borderColor: color.withValues(alpha: 0.3),
        borderWidth: 1.5,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(material.Icons.assignment, color: color, size: 22),
            ),
            const Gap(12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(_typeName).semiBold(),
                const Gap(8),
                SurveySyncBadge(isSynced: isSynced),
              ]),
              const Gap(2),
              Text(patientName).small().muted(),
            ])),
            if (isComplete && _hasScore) SurveyScoreBadge(score: score, level: level, color: levelColor),
          ]),
          const Gap(10),
          const Divider(height: 1),
          const Gap(10),
          Row(children: [
            Icon(material.Icons.calendar_today, size: 13, color: LightModeColors.lightOnSurfaceVariant),
            const Gap(5),
            Text(DateFormat('dd/MMM/yyyy HH:mm').format(createdAt)).small().muted(),
            const Spacer(),
            Icon(
              isComplete ? material.Icons.check_circle : material.Icons.hourglass_empty,
              size: 13,
              color: isComplete ? LightModeColors.lightTertiary : LightModeColors.lightOnSurfaceVariant,
            ),
            const Gap(5),
            Text(respLabel).small().muted(),
          ]),
        ]),
      ),
    );
  }
}

class SurveySyncBadge extends StatelessWidget {
  final bool isSynced;
  const SurveySyncBadge({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    final color = isSynced ? LightModeColors.lightTertiary : LightModeColors.lightSecondary;
    final icon  = isSynced ? material.Icons.cloud_done : material.Icons.cloud_upload;
    final label = isSynced ? 'Sincronizada' : 'Pendiente';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const Gap(3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

class SurveyScoreBadge extends StatelessWidget {
  final int score;
  final String level;
  final Color color;
  const SurveyScoreBadge({super.key, required this.score, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('$score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
