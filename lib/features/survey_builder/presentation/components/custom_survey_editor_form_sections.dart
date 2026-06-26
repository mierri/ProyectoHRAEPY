import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_colors.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_common.dart';
import 'package:ssapp/features/survey_builder/presentation/components/level_editor_card.dart';
import 'package:ssapp/features/survey_builder/presentation/components/question_editor_card.dart';
import 'package:ssapp/features/survey_builder/presentation/components/survey_draft_models.dart';

class CustomSurveyQuestionsSection extends StatelessWidget {
  final List<QuestionDraft> questions;
  final String colorHex;
  final VoidCallback onAddQuestion;
  final ValueChanged<int> onRemoveQuestion;

  const CustomSurveyQuestionsSection({
    super.key,
    required this.questions,
    required this.colorHex,
    required this.onAddQuestion,
    required this.onRemoveQuestion,
  });

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return CustomSurveySectionEmptyState(
        icon: material.Icons.quiz_outlined,
        title: 'Aun no has agregado preguntas',
        subtitle: 'Empieza con una pregunta base y luego ajusta tipo, opciones y puntajes.',
        actionLabel: 'Agregar primera pregunta',
        onPressed: onAddQuestion,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...questions.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: QuestionEditorCard(
              key: ValueKey(entry.value.fieldId),
              draft: entry.value,
              index: entry.key,
              color: parseCustomSurveyColor(colorHex),
              onRemove: () => onRemoveQuestion(entry.key),
            ),
          );
        }),
        OutlineButton(
          onPressed: onAddQuestion,
          child: const Text('+ Agregar pregunta'),
        ),
      ],
    );
  }
}

class CustomSurveyLevelsSection extends StatelessWidget {
  final List<LevelDraft> levels;
  final VoidCallback onAddLevel;
  final ValueChanged<int> onRemoveLevel;

  const CustomSurveyLevelsSection({
    super.key,
    required this.levels,
    required this.onAddLevel,
    required this.onRemoveLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Puedes dejar esta parte vacia si solo necesitas capturar respuestas, pero agregar niveles ayuda a leer resultados sin calcular manualmente.',
          style: TextStyle(fontSize: 13),
        ).muted(),
        const Gap(12),
        if (levels.isEmpty)
          CustomSurveySectionEmptyState(
            icon: material.Icons.insights_outlined,
            title: 'Sin niveles de interpretacion',
            subtitle: 'Ejemplo: 0 a 4 = bajo, 5 a 8 = moderado, 9 a 12 = alto.',
            actionLabel: 'Agregar nivel',
            onPressed: onAddLevel,
          )
        else ...[
          ...levels.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LevelEditorCard(
                draft: entry.value,
                index: entry.key,
                onRemove: () => onRemoveLevel(entry.key),
              ),
            );
          }),
          OutlineButton(
            onPressed: onAddLevel,
            child: const Text('+ Agregar nivel'),
          ),
        ],
      ],
    );
  }
}
