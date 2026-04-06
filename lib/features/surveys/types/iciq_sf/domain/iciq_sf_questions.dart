import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

enum IciqSfLeakSituation {
  nuncaPierdeOrina,
  antesDeLlegarAlBano,
  alToserOEstornudar,
  mientrasDuerme,
  alHacerEjercicio,
  alTerminarDeOrinar,
  sinMotivoEvidente,
  continua,
}

class IciqSfResult {
  const IciqSfResult({
    required this.score,
    required this.interpretacion,
    required this.severidad,
    required this.tieneIncontinencia,
    required this.orientacionTipo,
    required this.respuestas,
  });

  final int score;
  final String interpretacion;
  final String severidad;
  final bool tieneIncontinencia;
  final List<String> orientacionTipo;
  final Map<String, dynamic> respuestas;

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'interpretacion': interpretacion,
      'severidad': severidad,
      'tiene_incontinencia': tieneIncontinencia,
      'orientacion_tipo': orientacionTipo,
      'respuestas': respuestas,
    };
  }
}

class IciqSfQuestions {
  static const int totalPossible = 21;

  static const Map<IciqSfLeakSituation, String> situationLabels = {
    IciqSfLeakSituation.nuncaPierdeOrina: 'Nunca pierde orina',
    IciqSfLeakSituation.antesDeLlegarAlBano: 'Antes de llegar al baño',
    IciqSfLeakSituation.alToserOEstornudar: 'Al toser o estornudar',
    IciqSfLeakSituation.mientrasDuerme: 'Mientras duerme',
    IciqSfLeakSituation.alHacerEjercicio: 'Al hacer ejercicio',
    IciqSfLeakSituation.alTerminarDeOrinar: 'Al terminar de orinar',
    IciqSfLeakSituation.sinMotivoEvidente: 'Sin motivo evidente',
    IciqSfLeakSituation.continua: 'Continua',
  };

  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: 'Frecuencia de pérdida de orina',
      options: [
        SurveyOption(score: 0, text: 'Nunca'),
        SurveyOption(score: 1, text: 'Una vez a la semana'),
        SurveyOption(score: 2, text: '2-3 veces por semana'),
        SurveyOption(score: 3, text: 'Una vez al día'),
        SurveyOption(score: 4, text: 'Varias veces al día'),
        SurveyOption(score: 5, text: 'Continuamente'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Cantidad de orina perdida',
      options: [
        SurveyOption(score: 0, text: 'Nada'),
        SurveyOption(score: 2, text: 'Muy poca'),
        SurveyOption(score: 4, text: 'Moderada'),
        SurveyOption(score: 6, text: 'Mucha'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Impacto en la vida diaria',
      options: [
        SurveyOption(score: 0, text: '0'),
        SurveyOption(score: 1, text: '1'),
        SurveyOption(score: 2, text: '2'),
        SurveyOption(score: 3, text: '3'),
        SurveyOption(score: 4, text: '4'),
        SurveyOption(score: 5, text: '5'),
        SurveyOption(score: 6, text: '6'),
        SurveyOption(score: 7, text: '7'),
        SurveyOption(score: 8, text: '8'),
        SurveyOption(score: 9, text: '9'),
        SurveyOption(score: 10, text: '10'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Situaciones en las que ocurre la pérdida',
      options: [
        SurveyOption(score: 0, text: 'Nunca pierde orina'),
        SurveyOption(score: 0, text: 'Antes de llegar al baño'),
        SurveyOption(score: 0, text: 'Al toser o estornudar'),
        SurveyOption(score: 0, text: 'Mientras duerme'),
        SurveyOption(score: 0, text: 'Al hacer ejercicio'),
        SurveyOption(score: 0, text: 'Al terminar de orinar'),
        SurveyOption(score: 0, text: 'Sin motivo evidente'),
        SurveyOption(score: 0, text: 'Continua'),
      ],
    ),
  ];

  /// Ejemplo de uso:
  /// final output = IciqSfQuestions.evaluate({1: 0, 2: 0, 3: 0, 4: 1}).toMap();
  /// output => {score: 0, interpretacion: 'Sin evidencia de incontinencia urinaria segun ICIQ-SF.', ...}
  static IciqSfResult evaluate(Map<int, int> responses) {
    _validateResponses(responses);

    final score = calculateScore(responses);
    final situations = decodeSituationsFromMask(responses[4] ?? 0);
    final orientacion = inferIncontinenceType(situations);
    final severidad = _severityFromScore(score);
    final interpretacion = getInterpretation(score);

    return IciqSfResult(
      score: score,
      interpretacion: interpretacion,
      severidad: severidad,
      tieneIncontinencia: score > 0,
      orientacionTipo: orientacion,
      respuestas: {
        'p1_frecuencia': responses[1],
        'p2_cantidad': responses[2],
        'p3_impacto': responses[3],
        'p4_situaciones': situations.map((s) => situationLabels[s]!).toList(),
      },
    );
  }

  static int calculateScore(Map<int, int> responses) {
    _validateResponses(responses);
    return calculate_score(
      p1: responses[1]!,
      p2: responses[2]!,
      p3: responses[3]!,
    );
  }

  static int calculate_score({
    required int p1,
    required int p2,
    required int p3,
  }) {
    _validateP1(p1);
    _validateP2(p2);
    _validateP3(p3);
    return p1 + p2 + p3;
  }

  static String getInterpretation(int score) {
    if (score == 0) {
      return 'Sin evidencia de incontinencia urinaria segun ICIQ-SF.';
    }

    final severity = _severityFromScore(score);
    return 'Se detecta presencia de incontinencia urinaria con impacto $severity en la calidad de vida.';
  }

  static String get_interpretation(int score) => getInterpretation(score);

  static List<String> inferIncontinenceType(Set<IciqSfLeakSituation> situations) {
    return infer_incontinence_type(situations);
  }

  static List<String> infer_incontinence_type(Set<IciqSfLeakSituation> situations) {
    if (situations.isEmpty || situations.contains(IciqSfLeakSituation.nuncaPierdeOrina)) {
      return ['Sin orientacion especifica'];
    }

    final hasStress = situations.contains(IciqSfLeakSituation.alToserOEstornudar) ||
        situations.contains(IciqSfLeakSituation.alHacerEjercicio);
    final hasUrgency = situations.contains(IciqSfLeakSituation.antesDeLlegarAlBano);
    final hasContinuous = situations.contains(IciqSfLeakSituation.continua);

    final result = <String>[];

    if (hasStress && hasUrgency) {
      result.add('Mixta');
    } else if (hasStress) {
      result.add('Esfuerzo');
    } else if (hasUrgency) {
      result.add('Urgencia');
    }

    if (hasContinuous) {
      result.add('Continua');
    }

    if (result.isEmpty) {
      result.add('No clasificada');
    }

    return result;
  }

  static int encodeSituationsToMask(Set<IciqSfLeakSituation> situations) {
    var mask = 0;
    for (final s in situations) {
      mask |= (1 << s.index);
    }
    return mask;
  }

  static Set<IciqSfLeakSituation> decodeSituationsFromMask(int mask) {
    final out = <IciqSfLeakSituation>{};
    for (final s in IciqSfLeakSituation.values) {
      if ((mask & (1 << s.index)) != 0) {
        out.add(s);
      }
    }
    return out;
  }

  static Map<String, dynamic> exampleOutput() {
    return evaluate({
      1: 3,
      2: 2,
      3: 5,
      4: encodeSituationsToMask({
        IciqSfLeakSituation.antesDeLlegarAlBano,
        IciqSfLeakSituation.alToserOEstornudar,
      }),
    }).toMap();
  }

  static void _validateResponses(Map<int, int> responses) {
    const requiredQuestions = [1, 2, 3, 4];

    for (final q in requiredQuestions) {
      if (!responses.containsKey(q)) {
        throw ArgumentError('Falta respuesta para la pregunta $q en ICIQ-SF.');
      }
    }

    _validateP1(responses[1]!);
    _validateP2(responses[2]!);
    _validateP3(responses[3]!);

    final mask = responses[4]!;
    if (mask < 0) {
      throw ArgumentError('La pregunta 4 de ICIQ-SF no puede tener un valor negativo.');
    }
  }

  static void _validateP1(int value) {
    if (value < 0 || value > 5) {
      throw ArgumentError('P1 en ICIQ-SF debe estar entre 0 y 5.');
    }
  }

  static void _validateP2(int value) {
    const allowed = {0, 2, 4, 6};
    if (!allowed.contains(value)) {
      throw ArgumentError('P2 en ICIQ-SF solo permite valores 0, 2, 4 o 6.');
    }
  }

  static void _validateP3(int value) {
    if (value < 0 || value > 10) {
      throw ArgumentError('P3 en ICIQ-SF debe estar entre 0 y 10.');
    }
  }

  static String _severityFromScore(int score) {
    if (score == 0) return 'sin incontinencia';
    if (score <= 5) return 'leve';
    if (score <= 12) return 'moderado';
    return 'severo';
  }
}
