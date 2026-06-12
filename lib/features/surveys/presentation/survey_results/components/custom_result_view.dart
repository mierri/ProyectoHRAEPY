import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/patient_info_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/recommendations_card.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/widgets/lumi/lumi_widget.dart';

Color _parseDefinitionColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

/// Results layout for custom surveys created by the doctor: shows the
/// stored score/risk level plus each question with its given answer.
class CustomSurveyResultView extends StatelessWidget {
  final String patientName;
  final DateTime createdAt;
  final int score;
  final CustomSurveyDefinition definition;
  final List responses;
  final VoidCallback onBack;
  final VoidCallback onHome;

  const CustomSurveyResultView({
    super.key,
    required this.patientName,
    required this.createdAt,
    required this.score,
    required this.definition,
    required this.responses,
    required this.onBack,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseDefinitionColor(definition.colorHex);
    final level = definition.levelForScore(score);
    final levelLabel = level?.label ?? 'Resultado';
    final levelDescription = level != null && level.description.isNotEmpty
        ? level.description
        : 'No hay una interpretación configurada para este puntaje.';

    final responseByQuestion = <int, dynamic>{};
    for (final r in responses) {
      final qId = r['question_id'] as int?;
      if (qId != null) responseByQuestion[qId] = r;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: LumiWidget(
            variant: LumiVariant.cheering,
            size: 130,
            message: '¡Listo! Revisa los resultados.',
            bubbleColor: const Color(0xFFEDE9FF),
          ),
        ),
        const Gap(20),
        PatientInfoCard(patientName: patientName, createdAt: createdAt),
        const Gap(24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(children: [
            const Icon(material.Icons.assignment_turned_in_outlined, size: 80, color: Colors.white),
            const Gap(16),
            const Text('Puntaje Total', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500)),
            const Gap(8),
            Text('$score', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
            const Gap(16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(24)),
              child: Text(levelLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
            ),
            const Gap(12),
            Text(definition.title, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
          ]),
        ),
        const Gap(32),
        RecommendationsCard(level: levelLabel, recommendation: levelDescription),
        const Gap(24),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(material.Icons.assignment_outlined, color: LightModeColors.lightPrimary),
                const Gap(12),
                const Expanded(child: Text('Detalle de Respuestas')),
              ]),
              const Gap(16),
              const Divider(),
              const Gap(16),
              ...definition.questions.map((q) {
                final r = responseByQuestion[q.fieldId];
                final answerValue = r?['answer_value'] as int?;
                final matchingOptions = q.options.where((o) => o.value == answerValue);
                final answerLabel = matchingOptions.isNotEmpty
                    ? matchingOptions.first.label
                    : (r?['answer_text'] as String? ?? 'Sin respuesta');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(q.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const Gap(4),
                    Text(answerLabel, style: const TextStyle(fontSize: 14)),
                  ]),
                );
              }),
            ]),
          ),
        ),
        const Gap(24),
        Row(children: [
          Expanded(child: OutlineButton(
            onPressed: onBack,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(material.Icons.arrow_back, size: 20), Gap(8), Text('Volver'),
            ]),
          )),
          const Gap(12),
          Expanded(child: PrimaryButton(
            onPressed: onHome,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(material.Icons.home, size: 20), Gap(8), Text('Inicio'),
            ]),
          )),
        ]),
      ]),
    );
  }
}
