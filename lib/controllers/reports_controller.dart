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

class SF36DimensionStats {
  final String label;
  final double mean;
  final double median;
  final double stdDev;
  final double min;
  final double max;
  final int count;
  final List<double> timeline;

  int get maxPossible => 100;

  const SF36DimensionStats({
    required this.label,
    required this.mean,
    required this.median,
    required this.stdDev,
    required this.min,
    required this.max,
    required this.count,
    required this.timeline,
  });
}

class SF36ReportData {
  final BasicStats globalStats;
  final SF36DimensionStats physicalFunctioning;
  final SF36DimensionStats rolePhysical;
  final SF36DimensionStats bodilyPain;
  final SF36DimensionStats generalHealth;
  final SF36DimensionStats vitality;
  final SF36DimensionStats socialFunctioning;
  final SF36DimensionStats roleEmotional;
  final SF36DimensionStats mentalHealth;
  final List<double> globalTimeline;
  final int surveyCount;

  const SF36ReportData({
    required this.globalStats,
    required this.physicalFunctioning,
    required this.rolePhysical,
    required this.bodilyPain,
    required this.generalHealth,
    required this.vitality,
    required this.socialFunctioning,
    required this.roleEmotional,
    required this.mentalHealth,
    required this.globalTimeline,
    required this.surveyCount,
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
  static String gdsLevel(int score) => _gdsLevel(score);
  static String lawtonLevel(int score) => _lawtonLevel(score);
  static String assistLevel(int score) => _assistLevel(score);

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

  static String _gdsLevel(int score) {
    if (score <= 4) return 'Normal';
    return 'Síntomas depresivos';
  }

  static String _assistLevel(int score) {
    if (score <= 3) return 'Bajo';
    if (score <= 26) return 'Moderado';
    return 'Alto';
  }

  static String _lawtonLevel(int score) {
    if (score == 8) return 'Independencia total';
    return 'Deterioro funcional';
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

  static String gdsInterpretation(double mean) {
    if (mean <= 4) {
      return 'La media indica un resultado NORMAL en GDS-15. '
          'No se observan síntomas depresivos clínicamente relevantes en la muestra.';
    }
    return 'La media indica presencia de SÍNTOMAS DEPRESIVOS en GDS-15. '
        'Se recomienda valoración clínica y seguimiento por salud mental.';
  }

  static String assistInterpretation(double mean) {
    if (mean <= 3) {
      return 'La media indica RIESGO BAJO en ASSIST. '
          'Generalmente no se requiere intervención especializada.';
    } else if (mean <= 26) {
      return 'La media indica RIESGO MODERADO en ASSIST. '
          'Se recomienda intervención breve y seguimiento clínico.';
    }
    return 'La media indica RIESGO ALTO en ASSIST. '
        'Se sugiere evaluación y tratamiento especializado.';
  }

  static String lawtonInterpretation(double mean) {
    if (mean >= 8) {
      return 'La media indica INDEPENDENCIA TOTAL en actividades instrumentales de la vida diaria.';
    }
    return 'La media sugiere DETERIORO FUNCIONAL en una o más actividades instrumentales. '
        'Se recomienda valoración funcional y seguimiento.';
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

  static String sf36DimensionInterpretation(SF36DimensionStats dim) {
    final pct = dim.mean;
    if (pct >= 75) {
      return 'Puntuación ALTA (${pct.toStringAsFixed(1)}%). Excelente estado en esta dimensión.';
    } else if (pct >= 50) {
      return 'Puntuación MEDIA (${pct.toStringAsFixed(1)}%). Estado aceptable, con aspectos a mejorar.';
    } else if (pct >= 25) {
      return 'Puntuación BAJA (${pct.toStringAsFixed(1)}%). Se recomienda atención en esta área.';
    } else {
      return 'Puntuación MUY BAJA (${pct.toStringAsFixed(1)}%). Se requiere evaluación y atención profesional.';
    }
  }

  static SF36ReportData computeSF36Report(List<Map<String, dynamic>> surveys) {
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) =>
          DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));

    final globalScores = <double>[];
    final pfScores = <double>[];
    final rpScores = <double>[];
    final bpScores = <double>[];
    final ghScores = <double>[];
    final vtScores = <double>[];
    final sfScores = <double>[];
    final reScores = <double>[];
    final mhScores = <double>[];

    for (final survey in sorted) {
      final responses = survey['responses'] as List? ?? [];
      if (responses.isEmpty) continue;

      // Crear mapa de question_id -> answer_value
      final responseMap = <int, int>{};
      for (final r in responses) {
        final qId = r['question_id'] as int?;
        final val = r['answer_value'] as int?;
        if (qId != null && val != null) {
          responseMap[qId] = val;
        }
      }

      // Función Física (3-12): suma min=10, max=30, rango=20, INVERTIDAS
      final pf = _sumSF36ItemsInverted(responseMap, [3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 3);
      final pfScore = (pf - 10) / 20 * 100;
      if (pfScore >= 0 && pfScore <= 100) pfScores.add(pfScore);

      // Rol Físico (13-16): suma min=4, max=8, rango=4, INVERTIDAS
      final rp = _sumSF36ItemsInverted(responseMap, [13, 14, 15, 16], 2);
      final rpScore = (rp - 4) / 4 * 100;
      if (rpScore >= 0 && rpScore <= 100) rpScores.add(rpScore);

      // Dolor Corporal (21+22): suma min=2, max=12, rango=10, item 21 INVERTIDO, item 22 especial
      int bp = responseMap[21] ?? 0;
      // Invertir item 21 (máximo es 6, entonces 7 - valor)
      bp = 7 - bp;
      // Item 22 depende de item 21
      if ((responseMap[21] ?? 0) == 1) {
        bp += 6; // Sin dolor
      } else {
        bp += (6 - (responseMap[22] ?? 1)).clamp(1, 6).toInt();
      }
      final bpScore = (bp - 2) / 10 * 100;
      if (bpScore >= 0 && bpScore <= 100) bpScores.add(bpScore);

      // Salud General (1, 25-28): suma min=5, max=25, rango=20
      // Item 1 NO se invierte, items 25-28 SÍ se invierten (escala 1-5)
      int gh = responseMap[1] ?? 0; // item 1, sin invertir
      gh += _invertScore(responseMap[25] ?? 0, 5);
      gh += _invertScore(responseMap[26] ?? 0, 5);
      gh += _invertScore(responseMap[27] ?? 0, 5);
      gh += _invertScore(responseMap[28] ?? 0, 5);
      final ghScore = (gh - 5) / 20 * 100;
      if (ghScore >= 0 && ghScore <= 100) ghScores.add(ghScore);

      // Vitalidad (23, 27, 29, 31): suma min=4, max=24, rango=20
      // Items 23 y 27 se invierten (escala 1-6), items 29 y 31 NO se invierten
      int vt = _invertScore(responseMap[23] ?? 0, 6);
      vt += _invertScore(responseMap[27] ?? 0, 6);
      vt += responseMap[29] ?? 0;
      vt += responseMap[31] ?? 0;
      final vtScore = (vt - 4) / 20 * 100;
      if (vtScore >= 0 && vtScore <= 100) vtScores.add(vtScore);

      // Función Social (20, 32): suma min=2, max=10, rango=8
      // Item 20 se invierte (escala 1-5), item 32 NO se invierte (escala 1-5)
      int sf = _invertScore(responseMap[20] ?? 0, 5);
      sf += responseMap[32] ?? 0;
      final sfScore = (sf - 2) / 8 * 100;
      if (sfScore >= 0 && sfScore <= 100) sfScores.add(sfScore);

      // Rol Emocional (17-19): suma min=3, max=6, rango=3
      // Items 17-19 se invierten (escala 1-2)
      int re = _invertScore(responseMap[17] ?? 0, 2);
      re += _invertScore(responseMap[18] ?? 0, 2);
      re += _invertScore(responseMap[19] ?? 0, 2);
      final reScore = (re - 3) / 3 * 100;
      if (reScore >= 0 && reScore <= 100) reScores.add(reScore);

      // Salud Mental (24, 25, 26, 28, 30): suma min=5, max=30, rango=25
      // Items 24, 25, 26, 28 se invierten (escala 1-6), item 30 NO se invierte
      int mh = _invertScore(responseMap[24] ?? 0, 6);
      mh += _invertScore(responseMap[25] ?? 0, 6);
      mh += _invertScore(responseMap[26] ?? 0, 6);
      mh += _invertScore(responseMap[28] ?? 0, 6);
      mh += responseMap[30] ?? 0;
      final mhScore = (mh - 5) / 25 * 100;
      if (mhScore >= 0 && mhScore <= 100) mhScores.add(mhScore);

      // Promedio global de dimensiones
      final allDimensions = [pfScore, rpScore, bpScore, ghScore, vtScore, sfScore, reScore, mhScore];
      final avgGlobal = allDimensions.fold(0.0, (a, b) => a + b) / allDimensions.length;
      globalScores.add(avgGlobal);
    }

    return SF36ReportData(
      globalStats: computeBasicStats(globalScores.map((s) => s.toInt()).toList()),
      physicalFunctioning: _sf36DimensionStats('Función Física', pfScores),
      rolePhysical: _sf36DimensionStats('Rol Físico', rpScores),
      bodilyPain: _sf36DimensionStats('Dolor Corporal', bpScores),
      generalHealth: _sf36DimensionStats('Salud General', ghScores),
      vitality: _sf36DimensionStats('Vitalidad', vtScores),
      socialFunctioning: _sf36DimensionStats('Función Social', sfScores),
      roleEmotional: _sf36DimensionStats('Rol Emocional', reScores),
      mentalHealth: _sf36DimensionStats('Salud Mental', mhScores),
      globalTimeline: globalScores,
      surveyCount: sorted.length,
    );
  }

  static int _invertScore(int rawScore, int maxScore) {
    // Invertir puntuación: si máximo es 5, entonces 6 - valor, si máximo es 6, entonces 7 - valor
    return (maxScore + 1 - rawScore).clamp(1, maxScore);
  }

  static int _sumSF36ItemsInverted(Map<int, int> responseMap, List<int> questionIds, int maxScore) {
    int sum = 0;
    for (final qId in questionIds) {
      final val = responseMap[qId] ?? 0;
      sum += _invertScore(val, maxScore);
    }
    return sum;
  }

  static SF36DimensionStats _sf36DimensionStats(
    String label,
    List<double> scores,
  ) {
    if (scores.isEmpty) {
      return SF36DimensionStats(
        label: label,
        mean: 0,
        median: 0,
        stdDev: 0,
        min: 0,
        max: 0,
        count: 0,
        timeline: [],
      );
    }

    final sorted = List<double>.from(scores)..sort();
    final n = sorted.length;
    final mean = sorted.reduce((a, b) => a + b) / n;
    final median =
        n.isOdd ? sorted[n ~/ 2] : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
    final variance =
        sorted.map((s) => math.pow(s - mean, 2)).reduce((a, b) => a + b) / n;
    final stdDev = math.sqrt(variance);

    return SF36DimensionStats(
      label: label,
      mean: mean,
      median: median,
      stdDev: stdDev,
      min: sorted.first,
      max: sorted.last,
      count: n,
      timeline: scores,
    );
  }
}

