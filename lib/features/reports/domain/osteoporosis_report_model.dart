/// Models for Osteoporosis Reports
library;

class OsteoporosisReportMetrics {
  final int totalPatients;
  final int lowRiskCount;
  final int highRiskCount;
  final int naCount;
  final double averageBMI;
  final double averageScore;
  final double lowRiskPercentage;
  final double highRiskPercentage;
  final double naPercentage;

  OsteoporosisReportMetrics({
    required this.totalPatients,
    required this.lowRiskCount,
    required this.highRiskCount,
    required this.naCount,
    required this.averageBMI,
    required this.averageScore,
    required this.lowRiskPercentage,
    required this.highRiskPercentage,
    required this.naPercentage,
  });

  int get respondentsCount => lowRiskCount + highRiskCount;
}

class AgeGroupRiskData {
  final String ageGroup;
  final int totalCount;
  final int lowRiskCount;
  final int highRiskCount;
  final double highRiskPercentage;
  final double averageScore;

  AgeGroupRiskData({
    required this.ageGroup,
    required this.totalCount,
    required this.lowRiskCount,
    required this.highRiskCount,
    required this.highRiskPercentage,
    required this.averageScore,
  });
}

class BMICategoryRiskData {
  final String bmiCategory;
  final int totalCount;
  final int lowRiskCount;
  final int highRiskCount;
  final int naCount;
  final double lowRiskPercentage;
  final double highRiskPercentage;
  final double naPercentage;

  BMICategoryRiskData({
    required this.bmiCategory,
    required this.totalCount,
    required this.lowRiskCount,
    required this.highRiskCount,
    required this.naCount,
    required this.lowRiskPercentage,
    required this.highRiskPercentage,
    required this.naPercentage,
  });
}

class SexRiskData {
  final String sex;
  final int totalCount;
  final int highRiskCount;
  final int lowRiskCount;
  final int naCount;
  final double highRiskPercentage;
  final double lowRiskPercentage;

  SexRiskData({
    required this.sex,
    required this.totalCount,
    required this.highRiskCount,
    required this.lowRiskCount,
    required this.naCount,
    required this.highRiskPercentage,
    required this.lowRiskPercentage,
  });
}

class RiskFactorData {
  final int questionNumber;
  final String questionText;
  final int yesCount;
  final int totalCount;
  final double yesPercentage;

  RiskFactorData({
    required this.questionNumber,
    required this.questionText,
    required this.yesCount,
    required this.totalCount,
    required this.yesPercentage,
  });
}

class NABreakdownData {
  final String ageGroup;
  final String bmiCategory;
  final String sex;
  final int count;

  NABreakdownData({
    required this.ageGroup,
    required this.bmiCategory,
    required this.sex,
    required this.count,
  });
}

class ScoreDistributionData {
  final int score;
  final int count;
  final double percentage;

  ScoreDistributionData({
    required this.score,
    required this.count,
    required this.percentage,
  });
}

class TimeEvolutionData {
  final DateTime month;
  final int highRiskCount;
  final int lowRiskCount;
  final int naCount;

  TimeEvolutionData({
    required this.month,
    required this.highRiskCount,
    required this.lowRiskCount,
    required this.naCount,
  });
}

class OsteoporosisCompleteReport {
  final OsteoporosisReportMetrics overview;
  final List<AgeGroupRiskData> ageGroupData;
  final List<BMICategoryRiskData> bmiCategoryData;
  final List<SexRiskData> sexData;
  final List<RiskFactorData> riskFactors;
  final List<NABreakdownData> naBreakdown;
  final List<ScoreDistributionData> scoreDistribution;
  final List<TimeEvolutionData> timeEvolution;
  final DateTime generatedAt;

  OsteoporosisCompleteReport({
    required this.overview,
    required this.ageGroupData,
    required this.bmiCategoryData,
    required this.sexData,
    required this.riskFactors,
    required this.naBreakdown,
    required this.scoreDistribution,
    required this.timeEvolution,
    required this.generatedAt,
  });
}
