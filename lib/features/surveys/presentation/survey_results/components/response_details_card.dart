import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_answer_formatter.dart';
import 'package:ssapp/shared/utils/theme.dart';

/// Muestra, pregunta por pregunta, la opción que eligió el paciente.
class ResponseDetailsCard extends StatelessWidget {
  final List responses;
  final int surveyType;

  const ResponseDetailsCard({super.key, required this.responses, required this.surveyType});

  @override
  Widget build(BuildContext context) {
    final answers = SurveyAnswerFormatter.format(surveyType, responses);

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(material.Icons.assignment_outlined, color: LightModeColors.lightPrimary),
            const Gap(12),
            Expanded(child: Text('Detalle de Respuestas').semiBold().large()),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${answers.length} preg.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LightModeColors.lightPrimary),
              ),
            ),
          ]),
          const Gap(16),
          const Divider(),
          if (answers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                'No hay detalle de respuestas disponible para esta encuesta.',
                style: TextStyle(fontSize: 14),
              ).muted(),
            )
          else
            for (var i = 0; i < answers.length; i++) ...[
              _AnsweredQuestionTile(index: i + 1, item: answers[i]),
              if (i != answers.length - 1) const Divider(height: 1),
            ],
        ]),
      ),
    );
  }
}

class _AnsweredQuestionTile extends StatelessWidget {
  final int index;
  final AnsweredQuestion item;

  const _AnsweredQuestionTile({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final primary = LightModeColors.lightPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: primary.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Text(
            '$index',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Gap(8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.muted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(item.answer, style: const TextStyle(fontSize: 14)),
            ),
          ]),
        ),
      ]),
    );
  }
}
