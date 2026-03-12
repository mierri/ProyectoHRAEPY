import 'dart:math' as math;
import 'package:ssapp/models/whoqol_questions.dart';

class BasicStats {
  final double mean;
  final double median;
  final double mode;
  final double stdDev;
  final double min;
  final double max;
  final int count;

  double get range => max - min;

  const BasicStats({
    required this.mean,
    required this.median,
    required this.mode,
    required this.stdDev,
    required this.min,
    required this.max,
    required this.count,
  });

  static BasicStats empty() => const BasicStats(
        mean: 0, median: 0, mode: 0, stdDev: 0, min: 0, max: 0, count: 0);
}

class LevelDistribution {
  final Map<String, int> counts;
  final Map<String, String> ranges;
  final Map<String, String> colors;

  const LevelDistribution({
    required this.counts,
    required this.ranges,
    required this.colors,
  });

  int get total => counts.values.fold(0, (a, b) => a + b);
  double pct(String key) => total == 0 ? 0.0 : (counts[key] ?? 0) / total * 100;
}

class WhoqolDomainStats {
  final String label;
  final int questionCount;
  final double mean;
  final double median;
  final double stdDev;
  final double min;
  final double max;
  final int count;

  int get maxPossible => questionCount * 5;

  const WhoqolDomainStats({
    required this.label,
    required this.questionCount,
    required this.mean,
    required this.median,
    required this.stdDev,
    required this.min,
    required this.max,
    required this.count,
  });
}

class WhoqolGlobalItemStats {
  final Map<String, int> q1Distribution;
  final Map<String, int> q2Distribution;

  const WhoqolGlobalItemStats({
    required this.q1Distribution,
    required this.q2Distribution,
  });
}

class WhoqolReportData {
  final BasicStats globalStats;
  final WhoqolDomainStats dom1;
  final WhoqolDomainStats dom2;
  final WhoqolDomainStats dom3;
  final WhoqolDomainStats dom4;
  final WhoqolGlobalItemStats globalItems;
  final List<double> globalTimeline;
  final List<double> dom1Timeline;
  final List<double> dom2Timeline;
  final List<double> dom3Timeline;
  final List<double> dom4Timeline;
  final int surveyCount;

  const WhoqolReportData({
    required this.globalStats,
    required this.dom1,
    required this.dom2,
    required this.dom3,
    required this.dom4,
    required this.globalItems,
    required this.globalTimeline,
    required this.dom1Timeline,
    required this.dom2Timeline,
    required this.dom3Timeline,
    required this.dom4Timeline,
    required this.surveyCount,
  });
}

class ReportsController {

  // bdi / bai

  static int calculateSurveyScore(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List?;
    if (responses == null || responses.isEmpty) return 0;
    return responses.fold<int>(0, (s, r) => s + (r['answer_value'] as int? ?? 0));
  }

  static BasicStats computeBasicStats(List<int> scores) {
    if (scores.isEmpty) return BasicStats.empty();
    final sorted = List<int>.from(scores)..sort();
    final n = sorted.length;

    final mean = sorted.reduce((a, b) => a + b) / n;
    final median = n.isOdd
        ? sorted[n ~/ 2].toDouble()
        : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;

    final freqMap = <int, int>{};
    for (final s in sorted) freqMap[s] = (freqMap[s] ?? 0) + 1;
    final mode = freqMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final variance =
        sorted.map((s) => math.pow(s - mean, 2)).reduce((a, b) => a + b) / n;
    final stdDev = math.sqrt(variance);

    return BasicStats(
      mean: mean,
      median: median,
      mode: mode.toDouble(),
      stdDev: stdDev,
      min: sorted.first.toDouble(),
      max: sorted.last.toDouble(),
      count: n,
    );
  }

  static LevelDistribution bdiDistribution(List<Map<String, dynamic>> surveys) {
    final counts = <String, int>{
      'Mínima': 0, 'Leve': 0, 'Moderada': 0, 'Severa': 0
    };
    for (final s in surveys) {
      final score = calculateSurveyScore(s);
      final level = _bdiLevel(score);
      counts[level] = counts[level]! + 1;
    }
    return LevelDistribution(
      counts: counts,
      ranges: {'Mínima': '0–13', 'Leve': '14–19', 'Moderada': '20–28', 'Severa': '29–63'},
      colors: {
        'Mínima': '#10B981', 'Leve': '#FBBF24', 'Moderada': '#F97316', 'Severa': '#EF4444'
      },
    );
  }

  static LevelDistribution baiDistribution(List<Map<String, dynamic>> surveys) {
    final counts = <String, int>{
      'Mínima': 0, 'Leve': 0, 'Moderada': 0, 'Severa': 0
    };
    for (final s in surveys) {
      final score = calculateSurveyScore(s);
      final level = _baiLevel(score);
      counts[level] = counts[level]! + 1;
    }
    return LevelDistribution(
      counts: counts,
      ranges: {'Mínima': '0–7', 'Leve': '8–15', 'Moderada': '16–25', 'Severa': '26–63'},
      colors: {
        'Mínima': '#10B981', 'Leve': '#FBBF24', 'Moderada': '#F97316', 'Severa': '#EF4444'
      },
    );
  }

  static String bdiLevel(int score) => _bdiLevel(score);
  static String baiLevel(int score) => _baiLevel(score);

  static String _bdiLevel(int score) {
    if (score <= 13) return 'Mínima';
    if (score <= 19) return 'Leve';
    if (score <= 28) return 'Moderada';
    return 'Severa';
  }

  static String _baiLevel(int score) {
    if (score <= 7) return 'Mínima';
    if (score <= 15) return 'Leve';
    if (score <= 25) return 'Moderada';
    return 'Severa';
  }

  // Whoqol

  static Map<int, int> _extractWhoqolResponses(Map<String, dynamic> survey) {
    final responses = survey['responses'] as List?;
    if (responses == null) return {};
    final map = <int, int>{};
    for (final r in responses) {
      final qId = r['question_id'] as int?;
      final val = r['answer_value'] as int?;
      if (qId != null && val != null) map[qId] = val;
    }
    return map;
  }

  static int? _whoqolGlobalScore(Map<int, int> responses) {
    int total = 0;
    for (final q in WhoqolQuestions.questions) {
      final raw = responses[q.number];
      if (raw == null) return null;
      total += WhoqolQuestions.adjustedScore(rawScore: raw, reversed: q.reversed);
    }
    return total;
  }

  static int? _whoqolDomainScore(List<int> domainQs, Map<int, int> responses) {
    return WhoqolQuestions.domainScore(
      domainQuestions: domainQs,
      responses: responses,
    );
  }

  static WhoqolDomainStats _domainStats(
    String label,
    List<int> domainQs,
    List<Map<int, int>> allResponses,
  ) {
    final scores = <int>[];
    for (final resp in allResponses) {
      final s = _whoqolDomainScore(domainQs, resp);
      if (s != null) scores.add(s);
    }
    final basic = computeBasicStats(scores);
    return WhoqolDomainStats(
      label: label,
      questionCount: domainQs.length,
      mean: basic.mean,
      median: basic.median,
      stdDev: basic.stdDev,
      min: basic.min,
      max: basic.max,
      count: scores.length,
    );
  }

  static WhoqolReportData computeWhoqolReport(List<Map<String, dynamic>> surveys) {
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) =>
          DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));

    final allResponses = sorted.map(_extractWhoqolResponses).toList();

    final globalScores = <int>[];
    for (final resp in allResponses) {
      final s = _whoqolGlobalScore(resp);
      if (s != null) globalScores.add(s);
    }

    final q1Dist = {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};
    final q2Dist = {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0};
    for (final resp in allResponses) {
      final q1 = resp[1];
      final q2 = resp[2];
      if (q1 != null && q1 >= 1 && q1 <= 5) q1Dist['$q1'] = q1Dist['$q1']! + 1;
      if (q2 != null && q2 >= 1 && q2 <= 5) q2Dist['$q2'] = q2Dist['$q2']! + 1;
    }

    List<double> domainTimeline(List<int> domQs) => allResponses
        .map((r) => _whoqolDomainScore(domQs, r)?.toDouble())
        .whereType<double>()
        .toList();

    return WhoqolReportData(
      globalStats: computeBasicStats(globalScores),
      dom1: _domainStats('Salud Física', WhoqolQuestions.domain1Questions, allResponses),
      dom2: _domainStats('Salud Psicológica', WhoqolQuestions.domain2Questions, allResponses),
      dom3: _domainStats('Relaciones Sociales', WhoqolQuestions.domain3Questions, allResponses),
      dom4: _domainStats('Ambiente', WhoqolQuestions.domain4Questions, allResponses),
      globalItems: WhoqolGlobalItemStats(q1Distribution: q1Dist, q2Distribution: q2Dist),
      globalTimeline: globalScores.map((s) => s.toDouble()).toList(),
      dom1Timeline: domainTimeline(WhoqolQuestions.domain1Questions),
      dom2Timeline: domainTimeline(WhoqolQuestions.domain2Questions),
      dom3Timeline: domainTimeline(WhoqolQuestions.domain3Questions),
      dom4Timeline: domainTimeline(WhoqolQuestions.domain4Questions),
      surveyCount: sorted.length,
    );
  }

  static String bdiInterpretation(double mean) {
    if (mean <= 13) {
      return 'La media indica un nivel MÍNIMO de depresión. '
          'Los participantes presentan síntomas mínimos o ausentes. '
          'Se recomienda continuar con el monitoreo preventivo.';
    } else if (mean <= 19) {
      return 'La media indica un nivel LEVE de depresión. '
          'Se recomienda seguimiento y posible intervención psicoterapéutica.';
    } else if (mean <= 28) {
      return 'La media indica un nivel MODERADO de depresión. '
          'Se recomienda evaluación clínica y tratamiento psicoterapéutico.';
    } else {
      return 'La media indica un nivel SEVERO de depresión. '
          'Se recomienda evaluación clínica urgente y tratamiento especializado.';
    }
  }

  static String baiInterpretation(double mean) {
    if (mean <= 7) {
      return 'La media indica un nivel MÍNIMO de ansiedad. '
          'Se recomienda continuar con el monitoreo preventivo.';
    } else if (mean <= 15) {
      return 'La media indica un nivel LEVE de ansiedad. '
          'Se recomienda seguimiento y posible intervención.';
    } else if (mean <= 25) {
      return 'La media indica un nivel MODERADO de ansiedad. '
          'Se recomienda evaluación clínica y tratamiento.';
    } else {
      return 'La media indica un nivel SEVERO de ansiedad. '
          'Se recomienda evaluación clínica urgente y tratamiento especializado.';
    }
  }

  static String whoqolDomainInterpretation(WhoqolDomainStats dom) {
    final pct = dom.mean / dom.maxPossible * 100;
    if (pct >= 75) {
      return 'Puntuación ALTA (${pct.toStringAsFixed(1)}%). Buena calidad de vida en esta dimensión.';
    } else if (pct >= 50) {
      return 'Puntuación MEDIA (${pct.toStringAsFixed(1)}%). Calidad de vida aceptable, con aspectos a mejorar.';
    } else {
      return 'Puntuación BAJA (${pct.toStringAsFixed(1)}%). Se recomienda atención profesional en esta área.';
    }
  }
}

