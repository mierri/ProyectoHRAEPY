import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

/// Opcion de respuesta definida por la doctora (texto u emoji + puntaje).
class CustomOptionDef {
  final int value;
  final String label;
  final String? emoji;

  const CustomOptionDef({required this.value, required this.label, this.emoji});

  Map<String, dynamic> toJson() => {'value': value, 'label': label, 'emoji': emoji};

  factory CustomOptionDef.fromJson(Map<String, dynamic> json) => CustomOptionDef(
        value: json['value'] as int,
        label: json['label'] as String,
        emoji: json['emoji'] as String?,
      );
}

/// Pregunta definida por la doctora.
class CustomQuestionDef {
  final int fieldId;
  final String label;
  final String category;
  final FormFieldType type;
  final List<CustomOptionDef> options;

  const CustomQuestionDef({
    required this.fieldId,
    required this.label,
    this.category = '',
    required this.type,
    this.options = const [],
  });

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        'label': label,
        'category': category,
        'type': type.name,
        'options': options.map((o) => o.toJson()).toList(),
      };

  factory CustomQuestionDef.fromJson(Map<String, dynamic> json) => CustomQuestionDef(
        fieldId: json['fieldId'] as int,
        label: json['label'] as String? ?? '',
        category: json['category'] as String? ?? '',
        type: FormFieldType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => FormFieldType.singleChoice,
        ),
        options: (json['options'] as List? ?? const [])
            .map((o) => CustomOptionDef.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}

/// Rango de puntaje -> interpretacion de resultado, definido por la doctora.
class CustomLevelDef {
  final int minScore;
  final int maxScore;
  final String label;
  final String description;

  const CustomLevelDef({
    required this.minScore,
    required this.maxScore,
    required this.label,
    this.description = '',
  });

  bool contains(int score) => score >= minScore && score <= maxScore;

  Map<String, dynamic> toJson() => {
        'minScore': minScore,
        'maxScore': maxScore,
        'label': label,
        'description': description,
      };

  factory CustomLevelDef.fromJson(Map<String, dynamic> json) => CustomLevelDef(
        minScore: json['minScore'] as int? ?? 0,
        maxScore: json['maxScore'] as int? ?? 0,
        label: json['label'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}

/// Definicion completa de una encuesta personalizada creada por la doctora.
class CustomSurveyDefinition {
  final int id;
  final String title;
  final String description;
  final String colorHex;
  final List<CustomQuestionDef> questions;
  final List<CustomLevelDef> levels;
  final bool active;

  const CustomSurveyDefinition({
    required this.id,
    required this.title,
    this.description = '',
    this.colorHex = '#0D9488',
    this.questions = const [],
    this.levels = const [],
    this.active = true,
  });

  CustomSurveyDefinition copyWith({
    String? title,
    String? description,
    String? colorHex,
    List<CustomQuestionDef>? questions,
    List<CustomLevelDef>? levels,
    bool? active,
  }) {
    return CustomSurveyDefinition(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      questions: questions ?? this.questions,
      levels: levels ?? this.levels,
      active: active ?? this.active,
    );
  }

  /// Nivel de riesgo/interpretacion correspondiente a un puntaje dado.
  CustomLevelDef? levelForScore(int score) {
    for (final level in levels) {
      if (level.contains(score)) return level;
    }
    return null;
  }

  /// Convierte las preguntas a [FormQuestion] para reutilizar FormSurveyScreen.
  List<FormQuestion> toFormQuestions() {
    final total = questions.length;
    return questions.asMap().entries.map((entry) {
      final index = entry.key;
      final q = entry.value;
      return FormQuestion(
        number: '${index + 1}',
        label: q.label,
        category: q.category.isNotEmpty ? q.category : 'Pregunta ${index + 1} de $total',
        fields: [
          FormFieldDef(
            fieldId: q.fieldId,
            label: q.label,
            type: q.type,
            options: q.options.map((o) => SurveyChoice(value: o.value, label: o.label, emoji: o.emoji)).toList(),
          ),
        ],
      );
    }).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'colorHex': colorHex,
        'active': active,
        'questions': questions.map((q) => q.toJson()).toList(),
        'levels': levels.map((l) => l.toJson()).toList(),
      };

  factory CustomSurveyDefinition.fromJson(Map<String, dynamic> json) => CustomSurveyDefinition(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        colorHex: json['colorHex'] as String? ?? '#0D9488',
        active: json['active'] as bool? ?? true,
        questions: (json['questions'] as List? ?? const [])
            .map((q) => CustomQuestionDef.fromJson(q as Map<String, dynamic>))
            .toList(),
        levels: (json['levels'] as List? ?? const [])
            .map((l) => CustomLevelDef.fromJson(l as Map<String, dynamic>))
            .toList(),
      );
}
