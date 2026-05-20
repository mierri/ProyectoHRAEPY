class WhoqolQuestion {
  final int number;
  final String text;
  final WhoqolScaleType scaleType;
  final bool reversed;

  const WhoqolQuestion({
    required this.number,
    required this.text,
    required this.scaleType,
    this.reversed = false,
  });
}

enum WhoqolScaleType {
  qualityOfLife,
  intensity,
  capacity,
  satisfaction,
  frequency,
}

class WhoqolQuestions {
  static const List<WhoqolQuestion> questions = [
    // 1 y 2 son preguntas que no entran en la calificación de dimensiones
    WhoqolQuestion(
      number: 1,
      text: '¿Cómo puntuaría su calidad de vida?',
      scaleType: WhoqolScaleType.qualityOfLife,
    ),
    WhoqolQuestion(
      number: 2,
      text: '¿Cuán satisfecho/a está con su salud?',
      scaleType: WhoqolScaleType.qualityOfLife,
    ),

    WhoqolQuestion(
      number: 3,
      text: '¿En qué medida piensa que el dolor (físico) le impide hacer lo que necesita?',
      scaleType: WhoqolScaleType.intensity,
      reversed: true,
    ),
    WhoqolQuestion(
      number: 4,
      text: '¿Cuánto necesita de cualquier tratamiento médico para funcionar en su vida diaria?',
      scaleType: WhoqolScaleType.intensity,
      reversed: true,
    ),
    WhoqolQuestion(
      number: 5,
      text: '¿Cuánto disfruta de la vida?',
      scaleType: WhoqolScaleType.intensity,
    ),
    WhoqolQuestion(
      number: 6,
      text: '¿En qué medida siente que su vida tiene sentido?',
      scaleType: WhoqolScaleType.intensity,
    ),
    WhoqolQuestion(
      number: 7,
      text: '¿Cuál es su capacidad de concentración?',
      scaleType: WhoqolScaleType.intensity,
    ),
    WhoqolQuestion(
      number: 8,
      text: '¿Cuánta seguridad siente en su vida diaria?',
      scaleType: WhoqolScaleType.intensity,
    ),
    WhoqolQuestion(
      number: 9,
      text: '¿Cuán saludable es el ambiente físico de su alrededor?',
      scaleType: WhoqolScaleType.intensity,
    ),

    WhoqolQuestion(
      number: 10,
      text: '¿Tiene energía suficiente para la vida diaria?',
      scaleType: WhoqolScaleType.capacity,
    ),
    WhoqolQuestion(
      number: 11,
      text: '¿Es capaz de aceptar su apariencia física?',
      scaleType: WhoqolScaleType.capacity,
    ),
    WhoqolQuestion(
      number: 12,
      text: '¿Tiene suficiente dinero para cubrir sus necesidades?',
      scaleType: WhoqolScaleType.capacity,
    ),
    WhoqolQuestion(
      number: 13,
      text: '¿Qué tan disponible tiene la información que necesita en su vida diaria?',
      scaleType: WhoqolScaleType.capacity,
    ),
    WhoqolQuestion(
      number: 14,
      text: '¿Hasta qué punto tiene oportunidad para realizar actividades de ocio?',
      scaleType: WhoqolScaleType.capacity,
    ),
    WhoqolQuestion(
      number: 15,
      text: '¿Es capaz de desplazarse de un lugar a otro?',
      scaleType: WhoqolScaleType.capacity,
    ),

    WhoqolQuestion(
      number: 16,
      text: '¿Cuán satisfecho/a está con su sueño?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 17,
      text: '¿Cuán satisfecho/a está con su habilidad para realizar sus actividades de la vida diaria?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 18,
      text: '¿Cuán satisfecho/a está con su capacidad de trabajo?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 19,
      text: '¿Cuán satisfecho/a está de sí mismo?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 20,
      text: '¿Cuán satisfecho/a está con sus relaciones personales?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 21,
      text: '¿Cuán satisfecho/a está con su vida sexual?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 22,
      text: '¿Cuán satisfecho/a está con el apoyo que obtiene de sus amigos?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 23,
      text: '¿Cuán satisfecho/a está de las condiciones del lugar donde vive?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 24,
      text: '¿Cuán satisfecho/a está con el acceso que tiene a los servicios sanitarios?',
      scaleType: WhoqolScaleType.satisfaction,
    ),
    WhoqolQuestion(
      number: 25,
      text: '¿Cuán satisfecho/a está con su transporte?',
      scaleType: WhoqolScaleType.satisfaction,
    ),

    WhoqolQuestion(
      number: 26,
      text: '¿Con qué frecuencia tiene sentimientos negativos, tales como tristeza, desesperanza, ansiedad, depresión?',
      scaleType: WhoqolScaleType.frequency,
      reversed: true,
    ),
  ];

  static const List<String> qualityOfLifeLabels = [
    'Muy insatisfecho/a',
    'Insatisfecho/a',
    'Lo normal',
    'Bastante satisfecho/a',
    'Muy satisfecho/a',
  ];

  static const List<String> intensityLabels = [
    'Nada',
    'Un poco',
    'Lo normal',
    'Bastante',
    'Extremadamente',
  ];

  static const List<String> capacityLabels = [
    'Nada',
    'Un poco',
    'Moderado',
    'Bastante',
    'Totalmente',
  ];

  static const List<String> satisfactionLabels = [
    'Muy insatisfecho/a',
    'Insatisfecho/a',
    'Lo normal',
    'Bastante satisfecho/a',
    'Muy satisfecho/a',
  ];

  static const List<String> frequencyLabels = [
    'Nunca',
    'Raramente',
    'Medianamente',
    'Frecuentemente',
    'Siempre',
  ];

  /// Returns the label list for a given scale type.
  static List<String> labelsFor(WhoqolScaleType type) {
    switch (type) {
      case WhoqolScaleType.qualityOfLife:
        return qualityOfLifeLabels;
      case WhoqolScaleType.intensity:
        return intensityLabels;
      case WhoqolScaleType.capacity:
        return capacityLabels;
      case WhoqolScaleType.satisfaction:
        return satisfactionLabels;
      case WhoqolScaleType.frequency:
        return frequencyLabels;
    }
  }

  static int adjustedScore({required int rawScore, required bool reversed}) {
    if (!reversed) return rawScore;
    // invertir: 1-5, 2-4, 3-3, 4-2, 5-1
    return 6 - rawScore;
  }

  // dimensión 1 — salud física (Q3, Q4, Q10, Q15, Q16, Q17, Q18)
  static const List<int> domain1Questions = [3, 4, 10, 15, 16, 17, 18];

  // dimensión 2 — piscológica (Q5, Q6, Q7, Q11, Q19, Q26)
  static const List<int> domain2Questions = [5, 6, 7, 11, 19, 26];

  // dimensión 3 — relaciones sociales (Q20, Q21, Q22)
  static const List<int> domain3Questions = [20, 21, 22];

  // dimensión 4 — ambiente (Q8, Q9, Q12, Q13, Q14, Q23, Q24, Q25)
  static const List<int> domain4Questions = [8, 9, 12, 13, 14, 23, 24, 25];

  static int? domainScore({
    required List<int> domainQuestions,
    required Map<int, int> responses,
  }) {
    int total = 0;
    for (final qNum in domainQuestions) {
      final raw = responses[qNum];
      if (raw == null) return null;
      final q = questions.firstWhere((q) => q.number == qNum);
      total += adjustedScore(rawScore: raw, reversed: q.reversed);
    }
    return total;
  }

  static String interpretQ1(int score) {
    switch (score) {
      case 1: return 'Muy mala';
      case 2: return 'Poco';
      case 3: return 'Lo normal';
      case 4: return 'Bastante buena';
      case 5: return 'Muy buena';
      default: return '-';
    }
  }
}

