import 'package:ssapp/models/osteoporosis_risk_model.dart';

/// Service for calculating osteoporosis fracture risk scores
/// Based on clinical lookup table with age, BMI, sex, and questionnaire score
class OsteoporosisRiskService {
  /// The risk lookup table structure:
  /// Map&lt;AgeGroup, Map&lt;BMICategory, Map&lt;Sex, RiskRange&gt;&gt;&gt;
  static final Map<String, Map<String, Map<String, RiskRange>>> riskTable = {
    "50-54": {
      "15-19": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
      "25-29": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "30-34": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "35-39": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "40-44": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "45+": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
    },
    "55-59": {
      "15-19": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
      "25-29": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "30-34": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "35-39": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "40-44": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "45+": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
    },
    "60-64": {
      "15-19": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "25-29": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
      "30-34": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "35-39": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "40-44": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "45+": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
    },
    "65-69": {
      "15-19": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "25-29": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
      "30-34": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "35-39": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "40-44": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "45+": {
        "M": RiskRange(br: "0-6", ar: null),
        "H": RiskRange(br: "0-6", ar: null)
      },
    },
    "70-74": {
      "15-19": {
        "M": RiskRange(br: "0-1", ar: "2-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "25-29": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "30-34": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
      "35-39": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
      "40-44": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
      "45+": {
        "M": RiskRange(br: "0-5", ar: "6"),
        "H": RiskRange(br: "0-6", ar: null)
      },
    },
    "75-79": {
      "15-19": {
        "M": RiskRange(br: "0-1", ar: "2-6"),
        "H": RiskRange(br: "0-2", ar: "3-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-1", ar: "2-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "25-29": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "30-34": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "35-39": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "40-44": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
      "45+": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
    },
    "80-84": {
      "15-19": {
        "M": RiskRange(br: "0", ar: "1-6"),
        "H": RiskRange(br: "0-2", ar: "3-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-1", ar: "2-6"),
        "H": RiskRange(br: "0-2", ar: "3-6")
      },
      "25-29": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "30-34": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "35-39": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "40-44": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "45+": {
        "M": RiskRange(br: "0-4", ar: "5-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
    },
    "85-89": {
      "15-19": {
        "M": RiskRange(br: "0", ar: "1-6"),
        "H": RiskRange(br: "0-2", ar: "3-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-1", ar: "2-6"),
        "H": RiskRange(br: "0-2", ar: "3-6")
      },
      "25-29": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "30-34": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "35-39": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "40-44": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "45+": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
    },
    "90+": {
      "15-19": {
        "M": RiskRange(br: "0", ar: "1-6"),
        "H": RiskRange(br: "0-2", ar: "3-6")
      },
      "20-24": {
        "M": RiskRange(br: "0-1", ar: "2-6"),
        "H": RiskRange(br: "0-2", ar: "3-6")
      },
      "25-29": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "30-34": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-3", ar: "4-6")
      },
      "35-39": {
        "M": RiskRange(br: "0-2", ar: "3-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "40-44": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-4", ar: "5-6")
      },
      "45+": {
        "M": RiskRange(br: "0-3", ar: "4-6"),
        "H": RiskRange(br: "0-5", ar: "6")
      },
    },
  };

  /// Calculate BMI from weight and height
  /// 
  /// BMI = weight (kg) / (height (m))^2
  static double calculateBMI(double weightKg, double heightMeters) {
    if (heightMeters <= 0) throw ArgumentError('Height must be positive');
    if (weightKg <= 0) throw ArgumentError('Weight must be positive');
    return weightKg / (heightMeters * heightMeters);
  }

  /// Calculate total score from questionnaire answers
  /// 
  /// Each "true" (yes) = 1 point, "false" (no) = 0 points
  /// Max score = 7
  static int calculateScore(List<bool> answers) {
    if (answers.length != 7) throw ArgumentError('Must have exactly 7 answers');
    return answers.where((answer) => answer).length;
  }

  /// Normalize score to maximum of 6 (if total = 7, normalize to 6)
  static int normalizeScore(int score) {
    if (score < 0 || score > 7) throw ArgumentError('Score must be between 0 and 7');
    return score == 7 ? 6 : score;
  }

  /// Get age group string from patient age
  /// 
  /// Returns age group like "50-54", "55-59", ..., "90+"
  static String getAgeGroup(int age) {
    if (age < 50) throw ArgumentError('Patient must be 50 years or older');
    
    if (age <= 54) return "50-54";
    if (age <= 59) return "55-59";
    if (age <= 64) return "60-64";
    if (age <= 69) return "65-69";
    if (age <= 74) return "70-74";
    if (age <= 79) return "75-79";
    if (age <= 84) return "80-84";
    if (age <= 89) return "85-89";
    return "90+";
  }

  /// Get BMI category string from BMI value
  /// 
  /// Returns BMI category like "15-19", "20-24", ..., "45+"
  static String getBMICategory(double bmi) {
    if (bmi <= 0) throw ArgumentError('BMI must be positive');
    
    if (bmi < 15) throw ArgumentError('BMI too low for osteoporosis risk calculation');
    if (bmi < 20) return "15-19";
    if (bmi < 25) return "20-24";
    if (bmi < 30) return "25-29";
    if (bmi < 35) return "30-34";
    if (bmi < 40) return "35-39";
    if (bmi < 45) return "40-44";
    return "45+";
  }

  /// Check if a score falls within a range string like "0-3", "4-6", or "0" (single value)
  static bool isScoreInRange(int score, String rangeStr) {
    final parts = rangeStr.split('-');
    
    if (parts.length == 1) {
      // Single value like "0"
      return score == int.parse(parts[0]);
    } else if (parts.length == 2) {
      // Range like "0-3" or "4-6"
      final min = int.parse(parts[0]);
      final max = int.parse(parts[1]);
      return score >= min && score <= max;
    }
    
    return false;
  }

  /// Get sex code ("M" or "H") from Sex enum
  static String _getSexCode(Sex sex) {
    return sex == Sex.male ? "M" : "H";
  }

  /// Calculate osteoporosis fracture risk
  /// 
  /// Returns [RiskResult] with:
  /// - BMI calculation
  /// - Normalized score (0-6)
  /// - Risk level based on lookup table
  /// - Whether result is applicable
  static RiskResult calculateRisk(PatientData patient) {
    // Calculate BMI
    final bmi = calculateBMI(patient.weightKg, patient.heightMeters);

    // Calculate and normalize score
    final rawScore = calculateScore(patient.answers);
    final normalizedScore = normalizeScore(rawScore);

    // Get age group and BMI category
    final ageGroup = getAgeGroup(patient.age);
    final bmiCategory = getBMICategory(bmi);
    final sexCode = _getSexCode(patient.sex);

    // Look up in risk table
    final ageData = riskTable[ageGroup];
    if (ageData == null) {
      throw StateError('Age group $ageGroup not found in risk table');
    }

    final bmiData = ageData[bmiCategory];
    if (bmiData == null) {
      throw StateError('BMI category $bmiCategory not found for age $ageGroup');
    }

    final riskRange = bmiData[sexCode];
    if (riskRange == null) {
      throw StateError('Sex $sexCode not found for age $ageGroup, BMI $bmiCategory');
    }

    // Evaluate risk
    RiskLevel riskLevel = RiskLevel.notApplicable;
    bool isApplicable = true;

    if (riskRange.ar == null) {
      // AR is null means NA (Not Applicable)
      isApplicable = false;
      riskLevel = RiskLevel.notApplicable;
    } else if (riskRange.br != null && isScoreInRange(normalizedScore, riskRange.br!)) {
      // Score matches BR (Low Risk)
      riskLevel = RiskLevel.low;
      isApplicable = true;
    } else if (isScoreInRange(normalizedScore, riskRange.ar!)) {
      // Score matches AR (High Risk)
      riskLevel = RiskLevel.high;
      isApplicable = true;
    } else {
      // Score doesn't match any range (shouldn't happen with valid data)
      isApplicable = false;
      riskLevel = RiskLevel.notApplicable;
    }

    return RiskResult(
      bmi: bmi,
      score: normalizedScore,
      riskLevel: riskLevel,
      isHighRisk: riskLevel == RiskLevel.high,
      isApplicable: isApplicable,
      ageGroup: ageGroup,
      bmiCategory: bmiCategory,
    );
  }
}



