import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';

class FantasticMexaSurveyHandler extends SurveyTypeHandler {
  const FantasticMexaSurveyHandler();

  @override
  String get type => 'fantastic_mexa';

  @override
  int scoreFromStoredResponses(List<dynamic> responses) {
    return responses.fold<int>(0, (sum, response) {
      final item = response as Map<String, dynamic>;
      final questionId = item['question_id'] as int? ?? 0;
      final answerValue = item['answer_value'] as int? ?? 0;
      if (questionId < 1 || questionId > 46) return sum;
      return sum + answerValue;
    });
  }

  @override
  int totalScoreFromResponses(Map<int, int> responses) {
    return responses.entries
        .where((entry) => entry.key >= 1 && entry.key <= 46)
        .fold<int>(0, (sum, entry) => sum + entry.value);
  }

  @override
  String interpretation({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score >= 158) {
      return 'Estilo de vida EXCELENTE (${_pct(score)}%). Felicidades, tienes un estilo de vida fantastico. '
          'Si mantienes los buenos habitos podrias incrementar tu esperanza de vida.';
    }
    if (score >= 130) {
      return 'Estilo de vida BUENO (${_pct(score)}%). Vas por buen camino. Aun puedes mejorar. '
          'Observa que detalles puedes cambiar o mejorar para optimizar tu funcionamiento.';
    }
    if (score >= 111) {
      return 'Estilo de vida REGULAR (${_pct(score)}%). Es momento de actualizar tu estilo de vida. '
          'Implementa actividades novedosas para mejorar en las areas con menor puntaje.';
    }
    if (score >= 74) {
      return 'Estilo de vida DEFICIENTE (${_pct(score)}%). Es momento de tomar acciones contundentes para prevenir '
          'enfermedades cronicas y accidentes; si continuas asi puedes ponerte en riesgo. Enfocate en trabajar '
          'todos los dias en las areas con menor puntaje.';
    }
    return 'Estilo de vida MUY DEFICIENTE (${_pct(score)}%). Estas en zona de riesgo para padecer enfermedades '
        'cronicas o accidentes. Es momento de acudir con un profesional de la salud para recibir atencion y '
        'orientacion personalizada.';
  }

  @override
  String severityLevel({
    required int score,
    required Map<int, int> responses,
    required int questionsCount,
  }) {
    if (score >= 158) return 'Excelente';
    if (score >= 130) return 'Bueno';
    if (score >= 111) return 'Regular';
    if (score >= 74) return 'Deficiente';
    return 'Muy deficiente';
  }

  String _pct(int score) => (score / 186 * 100).toStringAsFixed(0);
}
