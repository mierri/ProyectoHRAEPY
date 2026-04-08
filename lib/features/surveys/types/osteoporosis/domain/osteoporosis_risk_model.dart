/// Enum for biological sex (M = Male, H = Female in Spanish context)
enum Sex { male, female }

/// Enum for risk levels
enum RiskLevel { low, high, notApplicable }

/// Class representing a single risk range entry (BR = Bajo Riesgo, AR = Alto Riesgo)
class RiskRange {
  /// Bajo Riesgo (Low Risk) score range, e.g., "0-3"
  final String? br;

  /// Alto Riesgo (High Risk) score range, e.g., "4-6"
  /// If null, it means not applicable (NA)
  final String? ar;

  RiskRange({this.br, this.ar});
}

/// Patient data for osteoporosis risk calculation
class PatientData {
  /// Patient age in years (must be >= 50)
  final int age;

  /// Weight in kilograms
  final double weightKg;

  /// Height in meters
  final double heightMeters;

  /// Biological sex
  final Sex sex;

  /// List of 7 yes/no answers (true = yes = 1 point, false = no = 0 points)
  final List<bool> answers;

  PatientData({
    required this.age,
    required this.weightKg,
    required this.heightMeters,
    required this.sex,
    required this.answers,
  }) : assert(answers.length == 7, 'Must have exactly 7 answers');
}

/// Result of osteoporosis risk calculation
class RiskResult {
  /// Calculated BMI
  final double bmi;

  /// Total score (0-6, normalized)
  final int score;

  /// Risk level classification
  final RiskLevel riskLevel;

  /// Whether the patient is at high risk
  final bool isHighRisk;

  /// Whether the result is applicable (false if NA)
  final bool isApplicable;

  /// Age group used for lookup (e.g., "50-54")
  final String ageGroup;

  /// BMI category used for lookup (e.g., "20-24")
  final String bmiCategory;

  RiskResult({
    required this.bmi,
    required this.score,
    required this.riskLevel,
    required this.isHighRisk,
    required this.isApplicable,
    required this.ageGroup,
    required this.bmiCategory,
  });

  /// Convert result to JSON for API transmission
  Map<String, dynamic> toJson() => {
        'bmi': bmi.toStringAsFixed(2),
        'score': score,
        'risk_level': riskLevel.name,
        'is_high_risk': isHighRisk,
        'is_applicable': isApplicable,
        'age_group': ageGroup,
        'bmi_category': bmiCategory,
      };
}
