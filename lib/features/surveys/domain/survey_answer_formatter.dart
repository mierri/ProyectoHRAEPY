import 'package:ssapp/features/surveys/domain/survey_catalog.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_questions.dart';
import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_questions.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_questions.dart';
import 'package:ssapp/features/surveys/types/sf36/domain/sf36_questions.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_questions.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_questions.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_questions.dart';
import 'package:ssapp/features/surveys/types/whoqol/domain/whoqol_questions.dart';

/// Pregunta de una encuesta ya emparejada con la respuesta que dio el paciente.
class AnsweredQuestion {
  final String question;
  final String answer;

  const AnsweredQuestion({required this.question, required this.answer});
}

/// Reconstruye, para una encuesta ya contestada, el texto de cada pregunta
/// junto con la opción que eligió el paciente.
///
/// Cada tipo de encuesta persiste sus respuestas con una forma distinta
/// (catálogo `SurveyQuestion`/`SurveyOption`, formularios `FormQuestion`/
/// `FormFieldDef`, o modelos propios como WHOQOL/SF-36), así que hay una
/// rama por tipo en vez de una lectura genérica.
class SurveyAnswerFormatter {
  static List<AnsweredQuestion> format(int surveyType, List responses) {
    final byQuestionId = <int, Map<String, dynamic>>{};
    for (final r in responses) {
      final map = Map<String, dynamic>.from(r as Map);
      final qId = map['question_id'] as int?;
      if (qId != null) byQuestionId[qId] = map;
    }

    switch (surveyType) {
      case SurveyCatalog.whoqol:
        return _formatWhoqol(byQuestionId);
      case SurveyCatalog.sf36:
        return _formatSf36(byQuestionId);
      case SurveyCatalog.mocaBasic:
        return _formatForm(MocaBasicQuestions.questions, byQuestionId);
      case SurveyCatalog.mocaBlind:
        return _formatForm(MocaBlindQuestions.questions, byQuestionId);
      case SurveyCatalog.sociodemographic:
        return _formatForm(sociodemographicQuestions, byQuestionId);
      case SurveyCatalog.socialDeterminants:
        return _formatForm(socialDeterminantsQuestions, byQuestionId);
      case SurveyCatalog.specialtyConsultationAttendance:
        return _formatForm(specialtyConsultationAttendanceQuestions, byQuestionId);
      case SurveyCatalog.perceivedAttendanceBarriers:
        // Superconjunto de preguntas: si el paciente no pasó por la sección
        // de antecedentes, esos campos simplemente no tendrán respuesta y
        // se omiten más abajo.
        return _formatForm(
          buildPerceivedAttendanceBarriersQuestions(includeAntecedentsSection: true),
          byQuestionId,
        );
      default:
        return _formatCatalog(SurveyCatalog.questionsForId(surveyType), byQuestionId);
    }
  }

  static List<AnsweredQuestion> _formatCatalog(
    List<SurveyQuestion> questions,
    Map<int, Map<String, dynamic>> byQuestionId,
  ) {
    final result = <AnsweredQuestion>[];
    for (final q in questions) {
      final r = byQuestionId[q.number];
      final value = r?['answer_value'] as int?;
      final match = q.options.where((o) => o.score == value);
      final answer = match.isNotEmpty
          ? match.first.text
          : (r?['answer_text'] as String? ?? 'Sin respuesta');
      result.add(AnsweredQuestion(question: q.category, answer: answer));
    }
    return result;
  }

  static List<AnsweredQuestion> _formatForm(
    List<FormQuestion> questions,
    Map<int, Map<String, dynamic>> byQuestionId,
  ) {
    final result = <AnsweredQuestion>[];
    for (final q in questions) {
      for (final field in q.fields) {
        final r = byQuestionId[field.fieldId];
        if (r == null) continue; // campo condicional que no aplicó al paciente

        final value = r['answer_value'] as int?;
        final match = field.options.where((o) => o.value == value);
        final answer = match.isNotEmpty
            ? match.first.label
            : (r['answer_text'] as String? ?? value?.toString() ?? 'Sin respuesta');
        result.add(AnsweredQuestion(question: field.label, answer: answer));
      }
    }
    return result;
  }

  static List<AnsweredQuestion> _formatWhoqol(Map<int, Map<String, dynamic>> byQuestionId) {
    final result = <AnsweredQuestion>[];
    for (final q in WhoqolQuestions.questions) {
      final value = byQuestionId[q.number]?['answer_value'] as int?;
      final labels = WhoqolQuestions.labelsFor(q.scaleType);
      final index = value == null ? -1 : value - 1;
      final answer = (index >= 0 && index < labels.length) ? labels[index] : 'Sin respuesta';
      result.add(AnsweredQuestion(question: q.text, answer: answer));
    }
    return result;
  }

  static List<AnsweredQuestion> _formatSf36(Map<int, Map<String, dynamic>> byQuestionId) {
    final result = <AnsweredQuestion>[];
    for (final q in SF36Questions.questions) {
      final value = byQuestionId[q.number]?['answer_value'] as int?;
      result.add(AnsweredQuestion(question: q.text, answer: _sf36AnswerLabel(q, value)));
    }
    return result;
  }

  // SF-36 no guarda el índice de opción crudo sino el score ya transformado
  // (ver SF36Controller.selectOption), así que hay que reconstruir el índice
  // según el tipo de transformación de cada pregunta.
  static String _sf36AnswerLabel(SF36Question q, int? answerValue) {
    if (answerValue == null) return 'Sin respuesta';

    int? index;
    if (q.customScoring != null) {
      for (var i = 0; i < q.customScoring!.length; i++) {
        if (q.customScoring![i].toInt() == answerValue) {
          index = i;
          break;
        }
      }
    } else if (q.inverted) {
      index = q.options.length - answerValue;
    } else {
      index = answerValue - 1;
    }

    if (index == null || index < 0 || index >= q.options.length) {
      return 'Valor $answerValue';
    }
    return q.options[index];
  }
}
