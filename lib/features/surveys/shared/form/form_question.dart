import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

enum FormFieldType { singleChoice, multiChoice, text, numeric, scale, emojiScale }

class FormFieldDef {
  final int fieldId;
  final String label;
  final FormFieldType type;
  final List<SurveyChoice> options;
  final int? exclusiveValue;
  final bool isRequired;

  const FormFieldDef({
    required this.fieldId,
    required this.label,
    required this.type,
    this.options = const [],
    this.exclusiveValue,
    this.isRequired = true,
  });
}

class FormConditionalField extends FormFieldDef {
  final int watchFieldId;
  final int? showWhenEquals;
  final int? showWhenContains;

  const FormConditionalField({
    required super.fieldId,
    required super.label,
    required super.type,
    super.options = const [],
    super.exclusiveValue,
    super.isRequired = true,
    required this.watchFieldId,
    this.showWhenEquals,
    this.showWhenContains,
  });
}

class FormQuestion {
  final String number;
  final String label;
  final String category;
  final List<FormFieldDef> fields;

  const FormQuestion({
    required this.number,
    required this.label,
    required this.category,
    required this.fields,
  });
}
