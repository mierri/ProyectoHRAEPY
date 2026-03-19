class AssistSubstance {
  final int id;
  final String key;
  final String label;
  final bool appliesP5;

  const AssistSubstance({
    required this.id,
    required this.key,
    required this.label,
    required this.appliesP5,
  });
}

class AssistSubstanceResult {
  final AssistSubstance substance;
  final int score;
  final String riskLevel;
  final String recommendation;

  const AssistSubstanceResult({
    required this.substance,
    required this.score,
    required this.riskLevel,
    required this.recommendation,
  });
}

class AssistComputedResults {
  final Map<int, AssistSubstanceResult> resultsBySubstance;
  final int? injectionScore;

  const AssistComputedResults({
    required this.resultsBySubstance,
    required this.injectionScore,
  });

  bool get hasInjectedInLast3Months => injectionScore == 2;
  bool get hasAnyLifetimeUse => resultsBySubstance.isNotEmpty;
}

class AssistQuestions {
  static const List<AssistSubstance> substances = [
    AssistSubstance(id: 1, key: 'tabaco', label: 'Tabaco', appliesP5: false),
    AssistSubstance(id: 2, key: 'alcohol', label: 'Alcohol', appliesP5: true),
    AssistSubstance(id: 3, key: 'cannabis', label: 'Cannabis', appliesP5: true),
    AssistSubstance(id: 4, key: 'cocaina', label: 'Cocaína', appliesP5: true),
    AssistSubstance(id: 5, key: 'anfetaminas', label: 'Anfetaminas', appliesP5: true),
    AssistSubstance(id: 6, key: 'inhalantes', label: 'Inhalantes', appliesP5: true),
    AssistSubstance(id: 7, key: 'sedantes', label: 'Sedantes', appliesP5: true),
    AssistSubstance(id: 8, key: 'alucinogenos', label: 'Alucinógenos', appliesP5: true),
    AssistSubstance(id: 9, key: 'opiaceos', label: 'Opiáceos', appliesP5: true),
    AssistSubstance(id: 10, key: 'otras', label: 'Otras', appliesP5: true),
  ];

  static const List<String> frequencyOptions = [
    'Nunca',
    '1-2 veces',
    'Cada mes',
    'Cada semana',
    'A diario',
  ];

  static const List<int> p2Scores = [0, 2, 3, 4, 6];
  static const List<int> p3Scores = [0, 3, 4, 5, 6];
  static const List<int> p4Scores = [0, 4, 5, 6, 7];
  static const List<int> p5Scores = [0, 5, 6, 7, 8];

  static const List<String> p67Options = [
    'No, nunca',
    'Sí, en los últimos 3 meses',
    'Sí, pero no en los últimos 3 meses',
  ];

  static const List<int> p67Scores = [0, 6, 3];

  static const List<String> p8Options = [
    'No',
    'Sí, en los últimos 3 meses',
    'Sí, pero no en los últimos 3 meses',
  ];

  static const List<int> p8Scores = [0, 2, 1];

  static AssistSubstance? getSubstanceById(int id) {
    for (final item in substances) {
      if (item.id == id) return item;
    }
    return null;
  }

  static String riskLevelFor(AssistSubstance substance, int score) {
    if (substance.key == 'alcohol') {
      if (score <= 10) return 'Bajo';
      if (score <= 26) return 'Moderado';
      return 'Alto';
    }

    if (score <= 3) return 'Bajo';
    if (score <= 26) return 'Moderado';
    return 'Alto';
  }

  static String recommendationFor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'bajo':
        return 'Sin intervención';
      case 'moderado':
        return 'Intervención Breve';
      case 'alto':
        return 'Tratamiento intensivo';
      default:
        return 'Sin intervención';
    }
  }

  static int encodedQuestionId({required int questionNumber, required int substanceId}) {
    return (questionNumber * 100) + substanceId;
  }

  static int questionNumberFromId(int questionId) {
    return questionId ~/ 100;
  }

  static int substanceIdFromId(int questionId) {
    return questionId % 100;
  }

  static AssistComputedResults computeFromMatrix({
    required Set<int> selectedSubstanceIds,
    required Map<int, Map<int, int>> answersByQuestion,
    required int? injectionScore,
  }) {
    final results = <int, AssistSubstanceResult>{};

    for (final substanceId in selectedSubstanceIds) {
      final substance = getSubstanceById(substanceId);
      if (substance == null) continue;

      final p2 = answersByQuestion[2]?[substanceId] ?? 0;
      final p3 = answersByQuestion[3]?[substanceId] ?? 0;
      final p4 = answersByQuestion[4]?[substanceId] ?? 0;
      final p5 = substance.appliesP5 ? (answersByQuestion[5]?[substanceId] ?? 0) : 0;
      final p6 = answersByQuestion[6]?[substanceId] ?? 0;
      final p7 = answersByQuestion[7]?[substanceId] ?? 0;

      final total = p2 + p3 + p4 + p5 + p6 + p7;
      final riskLevel = riskLevelFor(substance, total);

      results[substanceId] = AssistSubstanceResult(
        substance: substance,
        score: total,
        riskLevel: riskLevel,
        recommendation: recommendationFor(riskLevel),
      );
    }

    return AssistComputedResults(
      resultsBySubstance: results,
      injectionScore: injectionScore,
    );
  }

  static AssistComputedResults computeFromPersistedResponses(List responses) {
    final selected = <int>{};
    final answersByQuestion = <int, Map<int, int>>{};
    int? injectionScore;

    for (final item in responses) {
      final questionId = item['question_id'] as int?;
      final answerValue = item['answer_value'] as int?;
      if (questionId == null || answerValue == null) continue;

      final question = questionNumberFromId(questionId);
      final substanceId = substanceIdFromId(questionId);

      if (question == 1) {
        if (answerValue > 0) selected.add(substanceId);
        continue;
      }

      if (question == 8 && substanceId == 0) {
        injectionScore = answerValue;
        continue;
      }

      answersByQuestion.putIfAbsent(question, () => {});
      answersByQuestion[question]![substanceId] = answerValue;
    }

    return computeFromMatrix(
      selectedSubstanceIds: selected,
      answersByQuestion: answersByQuestion,
      injectionScore: injectionScore,
    );
  }
}