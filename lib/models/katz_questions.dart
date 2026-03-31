import 'package:ssapp/models/bdi_questions.dart';

enum KatzActivity {
  bano,
  vestido,
  sanitario,
  transferencias,
  continencia,
  alimentacion,
}

class KatzResult {
  const KatzResult({
    required this.score,
    required this.total,
    required this.interpretacion,
    required this.clasificacionKatz,
  });

  final int score;
  final int total;
  final String interpretacion;
  final String clasificacionKatz;

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'total': total,
      'interpretacion': interpretacion,
      'clasificacion_katz': clasificacionKatz,
    };
  }
}

class KatzQuestions {
  static const int totalPossible = 6;

  /// Ejemplo de uso:
  /// final output = KatzQuestions.evaluate({1:1,2:1,3:1,4:1,5:1,6:1}).toMap();
  /// output => {score: 6, total: 6, interpretacion: 'Independencia total', clasificacion_katz: 'A'}

  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: 'Baño',
      options: [
        SurveyOption(score: 1, text: 'Independiente: Se baña completamente solo/a.'),
        SurveyOption(score: 1, text: 'Independiente con mínima ayuda en una parte del cuerpo.'),
        SurveyOption(score: 0, text: 'Dependiente: Requiere ayuda para bañarse total o parcialmente.'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Vestido',
      options: [
        SurveyOption(score: 1, text: 'Independiente: Se viste y desviste solo/a.'),
        SurveyOption(score: 1, text: 'Independiente con mínima ayuda para abrochar o ajustar.'),
        SurveyOption(score: 0, text: 'Dependiente: Requiere ayuda para vestirse.'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Uso del sanitario',
      options: [
        SurveyOption(score: 1, text: 'Independiente: Usa sanitario, se limpia y arregla solo/a.'),
        SurveyOption(score: 1, text: 'Independiente con mínima ayuda ocasional.'),
        SurveyOption(score: 0, text: 'Dependiente: Necesita ayuda para usar sanitario o higiene.'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Transferencias',
      options: [
        SurveyOption(score: 1, text: 'Independiente: Se mueve cama/silla sin ayuda.'),
        SurveyOption(score: 1, text: 'Independiente con mínima ayuda o supervisión.'),
        SurveyOption(score: 0, text: 'Dependiente: Requiere ayuda para transferirse.'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: 'Continencia',
      options: [
        SurveyOption(score: 1, text: 'Independiente: Control completo de esfínteres.'),
        SurveyOption(score: 1, text: 'Independiente con mínimos episodios ocasionales.'),
        SurveyOption(score: 0, text: 'Dependiente: Incontinencia o requiere manejo asistido.'),
      ],
    ),
    SurveyQuestion(
      number: 6,
      category: 'Alimentación',
      options: [
        SurveyOption(score: 1, text: 'Independiente: Come solo/a sin ayuda.'),
        SurveyOption(score: 1, text: 'Independiente con mínima ayuda para cortar/preparar.'),
        SurveyOption(score: 0, text: 'Dependiente: Requiere ayuda para alimentarse.'),
      ],
    ),
  ];

  static KatzResult evaluate(Map<int, int> responses) {
    _validateResponses(responses);

    final score = responses.values.fold<int>(0, (sum, value) => sum + value);
    final dependentActivities = _dependentActivities(responses);

    return KatzResult(
      score: score,
      total: totalPossible,
      interpretacion: score == totalPossible
          ? 'Independencia total'
          : 'Dependencia en algun grado',
      clasificacionKatz: _classify(dependentActivities),
    );
  }

  static Map<String, dynamic> exampleOutput() {
    return evaluate({1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1}).toMap();
  }

  static void _validateResponses(Map<int, int> responses) {
    if (responses.length != totalPossible) {
      throw ArgumentError('Katz requiere 6 respuestas (una por actividad).');
    }

    for (var i = 1; i <= totalPossible; i++) {
      if (!responses.containsKey(i)) {
        throw ArgumentError('Falta respuesta para el item $i en Katz.');
      }
      final value = responses[i];
      if (value != 0 && value != 1) {
        throw ArgumentError('El item $i en Katz solo permite valores 0 o 1.');
      }
    }
  }

  static Set<KatzActivity> _dependentActivities(Map<int, int> responses) {
    final dependent = <KatzActivity>{};

    if (responses[1] == 0) dependent.add(KatzActivity.bano);
    if (responses[2] == 0) dependent.add(KatzActivity.vestido);
    if (responses[3] == 0) dependent.add(KatzActivity.sanitario);
    if (responses[4] == 0) dependent.add(KatzActivity.transferencias);
    if (responses[5] == 0) dependent.add(KatzActivity.continencia);
    if (responses[6] == 0) dependent.add(KatzActivity.alimentacion);

    return dependent;
  }

  static String _classify(Set<KatzActivity> dependent) {
    if (dependent.isEmpty) return 'A';
    if (dependent.length == 1) return 'B';
    if (dependent.length == 6) return 'G';

    final hasBano = dependent.contains(KatzActivity.bano);
    final hasVestido = dependent.contains(KatzActivity.vestido);
    final hasSanitario = dependent.contains(KatzActivity.sanitario);
    final hasTransferencias = dependent.contains(KatzActivity.transferencias);

    if (hasBano && hasVestido && hasSanitario && hasTransferencias && dependent.length >= 5) {
      return 'F';
    }

    if (hasBano && hasVestido && hasSanitario && dependent.length >= 4) {
      return 'E';
    }

    if (hasBano && hasVestido && dependent.length >= 3) {
      return 'D';
    }

    if (hasBano && dependent.length >= 2) {
      return 'C';
    }

    if (dependent.length >= 2) {
      return 'H';
    }

    return 'H';
  }
}
