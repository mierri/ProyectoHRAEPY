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
    mean: 0,
    median: 0,
    mode: 0,
    stdDev: 0,
    min: 0,
    max: 0,
    count: 0,
  );
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
