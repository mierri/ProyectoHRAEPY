import 'package:ssapp/models/osteoporosis_report_model.dart';

/// Service for calculating osteoporosis reports and statistics
class OsteoporosisReportService {
  /// Calculate complete report from survey data
  static OsteoporosisCompleteReport generateCompleteReport(List<Map<String, dynamic>> surveys) {
    final overview = _calculateOverview(surveys);
    final ageGroupData = _calculateAgeGroupData(surveys);
    final bmiCategoryData = _calculateBMICategoryData(surveys);
    final sexData = _calculateSexData(surveys);
    final riskFactors = _calculateRiskFactors(surveys);
    final naBreakdown = _calculateNABreakdown(surveys);
    final scoreDistribution = _calculateScoreDistribution(surveys);
    final timeEvolution = _calculateTimeEvolution(surveys);

    return OsteoporosisCompleteReport(
      overview: overview,
      ageGroupData: ageGroupData,
      bmiCategoryData: bmiCategoryData,
      sexData: sexData,
      riskFactors: riskFactors,
      naBreakdown: naBreakdown,
      scoreDistribution: scoreDistribution,
      timeEvolution: timeEvolution,
      generatedAt: DateTime.now(),
    );
  }

  /// Calculate overview metrics
  static OsteoporosisReportMetrics _calculateOverview(List<Map<String, dynamic>> surveys) {
    if (surveys.isEmpty) {
      return OsteoporosisReportMetrics(
        totalPatients: 0,
        lowRiskCount: 0,
        highRiskCount: 0,
        naCount: 0,
        averageBMI: 0,
        averageScore: 0,
        lowRiskPercentage: 0,
        highRiskPercentage: 0,
        naPercentage: 0,
      );
    }

    int lowRiskCount = 0;
    int highRiskCount = 0;
    int naCount = 0;
    double totalBMI = 0;
    double totalScore = 0;

    for (final survey in surveys) {
      final riskLevel = survey['risk_level'] as String?;

      if (riskLevel == 'high') {
        highRiskCount++;
      } else if (riskLevel == 'low') {
        lowRiskCount++;
      } else if (riskLevel == 'not_applicable' || riskLevel == null) {
        naCount++;
      }

      final bmi = survey['bmi'] as num?;
      if (bmi != null) {
        totalBMI += bmi.toDouble();
      }

      final score = survey['score'] as num?;
      if (score != null) {
        totalScore += score.toDouble();
      }
    }

    final totalCount = surveys.length;
    final respondentsCount = lowRiskCount + highRiskCount;

    return OsteoporosisReportMetrics(
      totalPatients: totalCount,
      lowRiskCount: lowRiskCount,
      highRiskCount: highRiskCount,
      naCount: naCount,
      averageBMI: totalCount > 0 ? totalBMI / totalCount : 0,
      averageScore: totalCount > 0 ? totalScore / totalCount : 0,
      lowRiskPercentage: respondentsCount > 0 ? (lowRiskCount / respondentsCount) * 100 : 0,
      highRiskPercentage: respondentsCount > 0 ? (highRiskCount / respondentsCount) * 100 : 0,
      naPercentage: totalCount > 0 ? (naCount / totalCount) * 100 : 0,
    );
  }

  /// Calculate risk data by age group
  static List<AgeGroupRiskData> _calculateAgeGroupData(List<Map<String, dynamic>> surveys) {
    const ageGroups = ['50-54', '55-59', '60-64', '65-69', '70-74', '75-79', '80-84', '85-89', '90+'];

    final result = <AgeGroupRiskData>[];

    for (final ageGroup in ageGroups) {
      final groupSurveys = surveys.where((s) => s['age_group'] == ageGroup).toList();

      if (groupSurveys.isEmpty) continue;

      int highRiskCount = 0;
      double totalScore = 0;

      for (final survey in groupSurveys) {
        if (survey['risk_level'] == 'high') {
          highRiskCount++;
        }

        final score = survey['score'] as num?;
        if (score != null) {
          totalScore += score.toDouble();
        }
      }

      result.add(AgeGroupRiskData(
        ageGroup: ageGroup,
        totalCount: groupSurveys.length,
        highRiskCount: highRiskCount,
        highRiskPercentage: (highRiskCount / groupSurveys.length) * 100,
        averageScore: totalScore / groupSurveys.length,
      ));
    }

    return result;
  }

  /// Calculate risk data by BMI category
  static List<BMICategoryRiskData> _calculateBMICategoryData(List<Map<String, dynamic>> surveys) {
    const bmiCategories = ['15-19', '20-24', '25-29', '30-34', '35-39', '40-44', '45+'];

    final result = <BMICategoryRiskData>[];

    for (final category in bmiCategories) {
      final categorySurveys = surveys.where((s) => s['bmi_category'] == category).toList();

      if (categorySurveys.isEmpty) continue;

      int lowRiskCount = 0;
      int highRiskCount = 0;
      int naCount = 0;

      for (final survey in categorySurveys) {
        final riskLevel = survey['risk_level'] as String?;

        if (riskLevel == 'high') {
          highRiskCount++;
        } else if (riskLevel == 'low') {
          lowRiskCount++;
        } else {
          naCount++;
        }
      }

      final totalCount = categorySurveys.length;

      result.add(BMICategoryRiskData(
        bmiCategory: category,
        totalCount: totalCount,
        lowRiskCount: lowRiskCount,
        highRiskCount: highRiskCount,
        naCount: naCount,
        lowRiskPercentage: (lowRiskCount / totalCount) * 100,
        highRiskPercentage: (highRiskCount / totalCount) * 100,
        naPercentage: (naCount / totalCount) * 100,
      ));
    }

    return result;
  }

  /// Calculate risk data by sex
  static List<SexRiskData> _calculateSexData(List<Map<String, dynamic>> surveys) {
    final sexGroups = {'M': 'Masculino', 'F': 'Femenino'};
    final result = <SexRiskData>[];

    for (final entry in sexGroups.entries) {
      final sexCode = entry.key;
      final sexLabel = entry.value;

      final sexSurveys = surveys.where((s) => s['sex'] == sexCode).toList();

      if (sexSurveys.isEmpty) continue;

      int lowRiskCount = 0;
      int highRiskCount = 0;
      int naCount = 0;

      for (final survey in sexSurveys) {
        final riskLevel = survey['risk_level'] as String?;

        if (riskLevel == 'high') {
          highRiskCount++;
        } else if (riskLevel == 'low') {
          lowRiskCount++;
        } else {
          naCount++;
        }
      }

      final totalCount = sexSurveys.length;

      result.add(SexRiskData(
        sex: sexLabel,
        totalCount: totalCount,
        highRiskCount: highRiskCount,
        lowRiskCount: lowRiskCount,
        naCount: naCount,
        highRiskPercentage: totalCount > 0 ? (highRiskCount / totalCount) * 100 : 0,
        lowRiskPercentage: totalCount > 0 ? (lowRiskCount / totalCount) * 100 : 0,
      ));
    }

    return result;
  }

  /// Calculate risk factors (% of yes answers per question)
  static List<RiskFactorData> _calculateRiskFactors(List<Map<String, dynamic>> surveys) {
    const questionCount = 7; // 7 questions in osteoporosis survey
    final result = <RiskFactorData>[];

    for (int q = 1; q <= questionCount; q++) {
      int yesCount = 0;
      int validResponses = 0;

      for (final survey in surveys) {
        // Responses stored as 'question_X' where 1 = yes, 0 = no
        final responseKey = 'question_$q';
        final response = survey[responseKey] as num?;

        if (response != null) {
          validResponses++;
          if (response == 1) {
            yesCount++;
          }
        }
      }

      if (validResponses > 0) {
        result.add(RiskFactorData(
          questionNumber: q,
          questionText: _getQuestionText(q),
          yesCount: yesCount,
          totalCount: validResponses,
          yesPercentage: (yesCount / validResponses) * 100,
        ));
      }
    }

    return result;
  }

  /// Calculate NA breakdown by age and BMI
  static List<NABreakdownData> _calculateNABreakdown(List<Map<String, dynamic>> surveys) {
    final naSurveys = surveys.where((s) =>
      s['risk_level'] == 'not_applicable' || s['risk_level'] == null
    ).toList();

    final result = <NABreakdownData>[];
    final naMap = <String, int>{};

    for (final survey in naSurveys) {
      final ageGroup = survey['age_group'] as String? ?? 'Unknown';
      final bmiCategory = survey['bmi_category'] as String? ?? 'Unknown';
      final sex = survey['sex'] as String? ?? 'Unknown';

      final key = '$ageGroup-$bmiCategory-$sex';
      naMap[key] = (naMap[key] ?? 0) + 1;
    }

    naMap.forEach((key, count) {
      final parts = key.split('-');
      result.add(NABreakdownData(
        ageGroup: parts[0],
        bmiCategory: parts[1],
        sex: parts[2] == 'M' ? 'Masculino' : 'Femenino',
        count: count,
      ));
    });

    return result;
  }

  /// Calculate score distribution (0-6)
  static List<ScoreDistributionData> _calculateScoreDistribution(List<Map<String, dynamic>> surveys) {
    final scoreCounts = <int, int>{};

    for (final survey in surveys) {
      final score = survey['score'] as num?;
      if (score != null) {
        final scoreInt = score.toInt().clamp(0, 6);
        scoreCounts[scoreInt] = (scoreCounts[scoreInt] ?? 0) + 1;
      }
    }

    final result = <ScoreDistributionData>[];

    for (int score = 0; score <= 6; score++) {
      final count = scoreCounts[score] ?? 0;
      result.add(ScoreDistributionData(
        score: score,
        count: count,
        percentage: surveys.isNotEmpty ? (count / surveys.length) * 100 : 0,
      ));
    }

    return result;
  }

  /// Calculate time evolution (monthly trend)
  static List<TimeEvolutionData> _calculateTimeEvolution(List<Map<String, dynamic>> surveys) {
    final monthlyData = <DateTime, Map<String, int>>{};

    for (final survey in surveys) {
      final createdAt = survey['created_at'] as String?;
      if (createdAt == null) continue;

      try {
        final date = DateTime.parse(createdAt);
        final monthKey = DateTime(date.year, date.month);

        if (!monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = {'low': 0, 'high': 0, 'na': 0};
        }

        final riskLevel = survey['risk_level'] as String?;
        if (riskLevel == 'high') {
          monthlyData[monthKey]!['high'] = (monthlyData[monthKey]!['high'] ?? 0) + 1;
        } else if (riskLevel == 'low') {
          monthlyData[monthKey]!['low'] = (monthlyData[monthKey]!['low'] ?? 0) + 1;
        } else {
          monthlyData[monthKey]!['na'] = (monthlyData[monthKey]!['na'] ?? 0) + 1;
        }
      } catch (e) {
        // Skip invalid dates
        continue;
      }
    }

    final result = monthlyData.entries
        .map((entry) => TimeEvolutionData(
          month: entry.key,
          highRiskCount: entry.value['high'] ?? 0,
          lowRiskCount: entry.value['low'] ?? 0,
          naCount: entry.value['na'] ?? 0,
        ))
        .toList();

    result.sort((a, b) => a.month.compareTo(b.month));
    return result;
  }

  /// Get question text by question number
  static String _getQuestionText(int questionNumber) {
    const questions = [
      'Fractura anterior',
      'Historial familiar de fractura',
      'Fumador actual',
      'Uso de glucocorticoides',
      'Artritis reumatoide',
      'Osteoporosis secundaria',
      'Consumo excesivo de alcohol',
    ];

    return questions.length >= questionNumber
        ? questions[questionNumber - 1]
        : 'Pregunta $questionNumber';
  }
}

