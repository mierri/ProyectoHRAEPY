import 'package:flutter/widgets.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/shared/utils/id_generator.dart';

/// Borrador editable de una opcion de respuesta (texto/emoji + puntaje).
class OptionDraft {
  final TextEditingController labelController;
  final TextEditingController valueController;
  String? emoji;

  OptionDraft({String label = '', int value = 0, this.emoji})
      : labelController = TextEditingController(text: label),
        valueController = TextEditingController(text: value.toString());

  void dispose() {
    labelController.dispose();
    valueController.dispose();
  }

  CustomOptionDef toDef() => CustomOptionDef(
        value: int.tryParse(valueController.text.trim()) ?? 0,
        label: labelController.text.trim(),
        emoji: emoji,
      );

  factory OptionDraft.fromDef(CustomOptionDef def) =>
      OptionDraft(label: def.label, value: def.value, emoji: def.emoji);
}

/// Borrador editable de una pregunta de la encuesta.
class QuestionDraft {
  final int fieldId;
  final TextEditingController labelController;
  final TextEditingController categoryController;
  FormFieldType type;
  List<OptionDraft> options;

  QuestionDraft({
    int? fieldId,
    String label = '',
    String category = '',
    this.type = FormFieldType.singleChoice,
    List<OptionDraft>? options,
  })  : fieldId = fieldId ?? generateId(),
        labelController = TextEditingController(text: label),
        categoryController = TextEditingController(text: category),
        options = options ?? [];

  void dispose() {
    labelController.dispose();
    categoryController.dispose();
    for (final o in options) {
      o.dispose();
    }
  }

  CustomQuestionDef toDef() => CustomQuestionDef(
        fieldId: fieldId,
        label: labelController.text.trim(),
        category: categoryController.text.trim(),
        type: type,
        options: options.map((o) => o.toDef()).toList(),
      );

  factory QuestionDraft.fromDef(CustomQuestionDef def) => QuestionDraft(
        fieldId: def.fieldId,
        label: def.label,
        category: def.category,
        type: def.type,
        options: def.options.map(OptionDraft.fromDef).toList(),
      );
}

/// Borrador editable de un rango de interpretacion (puntaje -> nivel).
class LevelDraft {
  final TextEditingController minController;
  final TextEditingController maxController;
  final TextEditingController labelController;
  final TextEditingController descController;

  LevelDraft({
    int min = 0,
    int max = 0,
    String label = '',
    String description = '',
  })  : minController = TextEditingController(text: min.toString()),
        maxController = TextEditingController(text: max.toString()),
        labelController = TextEditingController(text: label),
        descController = TextEditingController(text: description);

  void dispose() {
    minController.dispose();
    maxController.dispose();
    labelController.dispose();
    descController.dispose();
  }

  CustomLevelDef toDef() => CustomLevelDef(
        minScore: int.tryParse(minController.text.trim()) ?? 0,
        maxScore: int.tryParse(maxController.text.trim()) ?? 0,
        label: labelController.text.trim(),
        description: descController.text.trim(),
      );

  factory LevelDraft.fromDef(CustomLevelDef def) => LevelDraft(
        min: def.minScore,
        max: def.maxScore,
        label: def.label,
        description: def.description,
      );
}
