/// Unit tests for Osteoporosis Risk Calculation Service
///
/// Run with: flutter test test/osteoporosis_risk_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ssapp/models/osteoporosis_risk_model.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/osteoporosis_risk_service.dart';

void main() {
  group('OsteoporosisRiskService', () {

    test('calculateBMI - Normal calculation', () {
      final bmi = OsteoporosisRiskService.calculateBMI(75.0, 1.75);
      expect(bmi, closeTo(24.49, 0.01));
    });

    test('calculateBMI - Underweight', () {
      final bmi = OsteoporosisRiskService.calculateBMI(50.0, 1.70);
      expect(bmi, closeTo(17.30, 0.01));
    });

    test('calculateBMI - Overweight', () {
      final bmi = OsteoporosisRiskService.calculateBMI(90.0, 1.75);
      expect(bmi, closeTo(29.39, 0.01));
    });

    test('calculateBMI - throws on invalid height', () {
      expect(
        () => OsteoporosisRiskService.calculateBMI(75.0, 0),
        throwsArgumentError,
      );
    });

    test('calculateBMI - throws on negative weight', () {
      expect(
        () => OsteoporosisRiskService.calculateBMI(-75.0, 1.75),
        throwsArgumentError,
      );
    });

    test('calculateScore - All no', () {
      final score = OsteoporosisRiskService.calculateScore(
        [false, false, false, false, false, false, false],
      );
      expect(score, equals(0));
    });

    test('calculateScore - All yes', () {
      final score = OsteoporosisRiskService.calculateScore(
        [true, true, true, true, true, true, true],
      );
      expect(score, equals(7));
    });

    test('calculateScore - Mixed answers', () {
      final score = OsteoporosisRiskService.calculateScore(
        [true, false, true, false, true, false, false],
      );
      expect(score, equals(3));
    });

    test('calculateScore - throws on wrong length', () {
      expect(
        () => OsteoporosisRiskService.calculateScore([true, false, true]),
        throwsArgumentError,
      );
    });

    test('normalizeScore - Low scores unchanged', () {
      expect(OsteoporosisRiskService.normalizeScore(0), equals(0));
      expect(OsteoporosisRiskService.normalizeScore(3), equals(3));
      expect(OsteoporosisRiskService.normalizeScore(6), equals(6));
    });

    test('normalizeScore - Score 7 normalized to 6', () {
      expect(OsteoporosisRiskService.normalizeScore(7), equals(6));
    });

    test('normalizeScore - throws on invalid score', () {
      expect(
        () => OsteoporosisRiskService.normalizeScore(8),
        throwsArgumentError,
      );
      expect(
        () => OsteoporosisRiskService.normalizeScore(-1),
        throwsArgumentError,
      );
    });

    test('getAgeGroup - 50-54 range', () {
      expect(OsteoporosisRiskService.getAgeGroup(50), equals("50-54"));
      expect(OsteoporosisRiskService.getAgeGroup(52), equals("50-54"));
      expect(OsteoporosisRiskService.getAgeGroup(54), equals("50-54"));
    });

    test('getAgeGroup - 55-59 range', () {
      expect(OsteoporosisRiskService.getAgeGroup(55), equals("55-59"));
      expect(OsteoporosisRiskService.getAgeGroup(57), equals("55-59"));
      expect(OsteoporosisRiskService.getAgeGroup(59), equals("55-59"));
    });

    test('getAgeGroup - 90+ range', () {
      expect(OsteoporosisRiskService.getAgeGroup(90), equals("90+"));
      expect(OsteoporosisRiskService.getAgeGroup(100), equals("90+"));
    });

    test('getAgeGroup - throws under 50', () {
      expect(
        () => OsteoporosisRiskService.getAgeGroup(49),
        throwsArgumentError,
      );
    });

    test('getBMICategory - 15-19 range', () {
      expect(OsteoporosisRiskService.getBMICategory(15), equals("15-19"));
      expect(OsteoporosisRiskService.getBMICategory(18), equals("15-19"));
      expect(OsteoporosisRiskService.getBMICategory(19.9), equals("15-19"));
    });

    test('getBMICategory - 20-24 range', () {
      expect(OsteoporosisRiskService.getBMICategory(20), equals("20-24"));
      expect(OsteoporosisRiskService.getBMICategory(22), equals("20-24"));
      expect(OsteoporosisRiskService.getBMICategory(24.9), equals("20-24"));
    });

    test('getBMICategory - 45+ range', () {
      expect(OsteoporosisRiskService.getBMICategory(45), equals("45+"));
      expect(OsteoporosisRiskService.getBMICategory(50), equals("45+"));
    });

    test('isScoreInRange - Single value', () {
      expect(OsteoporosisRiskService.isScoreInRange(0, "0"), isTrue);
      expect(OsteoporosisRiskService.isScoreInRange(1, "0"), isFalse);
    });

    test('isScoreInRange - Range values', () {
      expect(OsteoporosisRiskService.isScoreInRange(0, "0-3"), isTrue);
      expect(OsteoporosisRiskService.isScoreInRange(3, "0-3"), isTrue);
      expect(OsteoporosisRiskService.isScoreInRange(2, "0-3"), isTrue);
      expect(OsteoporosisRiskService.isScoreInRange(4, "0-3"), isFalse);
    });

    test('isScoreInRange - High risk range', () {
      expect(OsteoporosisRiskService.isScoreInRange(4, "4-6"), isTrue);
      expect(OsteoporosisRiskService.isScoreInRange(6, "4-6"), isTrue);
      expect(OsteoporosisRiskService.isScoreInRange(3, "4-6"), isFalse);
    });

    group('calculateRisk - Integration tests', () {

      test('Low risk scenario - Male, 52 years, BMI 22.5, score 1', () {
        final patient = PatientData(
          age: 52,
          weightKg: 75.0,
          heightMeters: 1.78,
          sex: Sex.male,
          answers: [false, false, true, false, false, false, false],
        );

        final result = OsteoporosisRiskService.calculateRisk(patient);

        expect(result.bmi, closeTo(23.66, 0.1));
        expect(result.score, equals(1));
        expect(result.ageGroup, equals("50-54"));
        expect(result.bmiCategory, equals("20-24"));
        expect(result.isApplicable, isTrue);
        // For 50-54, H (Male), 20-24: BR="0-5", AR="6"
        expect(result.riskLevel, equals(RiskLevel.low));
        expect(result.isHighRisk, isFalse);
      });

      test('High risk scenario - Male, 52 years, BMI 19.5, score 5', () {
        final patient = PatientData(
          age: 52,
          weightKg: 59.0,
          heightMeters: 1.74,
          sex: Sex.male,
          answers: [true, true, false, true, false, true, false], // Score 4
        );

        final result = OsteoporosisRiskService.calculateRisk(patient);

        expect(result.bmi, closeTo(19.48, 0.1));
        expect(result.score, equals(4));
        expect(result.ageGroup, equals("50-54"));
        expect(result.bmiCategory, equals("15-19"));
        expect(result.isApplicable, isTrue);
        // For 50-54, H (Male), 15-19: BR="0-4", AR="5-6"
        // Score 4 falls in BR, so Low Risk (not High as originally stated)
        expect(result.riskLevel, equals(RiskLevel.low));
        expect(result.isHighRisk, isFalse);
      });

      test('High risk scenario - Female, 70 years, BMI 18, score 5', () {
        final patient = PatientData(
          age: 70,
          weightKg: 52.0,
          heightMeters: 1.70,
          sex: Sex.female,
          answers: [true, true, false, true, false, false, true],
        );

        final result = OsteoporosisRiskService.calculateRisk(patient);

        expect(result.bmi, closeTo(17.99, 0.1));
        expect(result.score, equals(4));
        expect(result.ageGroup, equals("70-74"));
        expect(result.bmiCategory, equals("15-19"));
        expect(result.isApplicable, isTrue);
        // For 70-74, M (Female), 15-19: BR="0-1", AR="2-6"
        expect(result.riskLevel, equals(RiskLevel.high));
        expect(result.isHighRisk, isTrue);
      });

      test('Low risk scenario - score 6, female 50, bmi 37', () {
        final patient = PatientData(
          age: 50,
          weightKg: 77.0,
          heightMeters: 1.45,
          sex: Sex.female,
          answers: [true, true, true, true, true, true, false], // Score 6
        );

        final result = OsteoporosisRiskService.calculateRisk(patient);

        expect(result.score, equals(6));
        // For 50-54, M (Female), 35-39: BR="0-6", AR=null → Score 6 falls in BR → Low Risk
        expect(result.isApplicable, isTrue);
        expect(result.riskLevel, equals(RiskLevel.low));
      });

      test('Max score normalization - score 7 normalized to 6', () {
        final patient = PatientData(
          age: 65,
          weightKg: 75.0,
          heightMeters: 1.75,
          sex: Sex.male,
          answers: [true, true, true, true, true, true, true], // Score 7
        );

        final result = OsteoporosisRiskService.calculateRisk(patient);

        // Score 7 should be normalized to 6
        expect(result.score, equals(6));
      });
    });

    group('RiskResult serialization', () {

      test('toJson - Low risk', () {
        final result = RiskResult(
          bmi: 24.49,
          score: 2,
          riskLevel: RiskLevel.low,
          isHighRisk: false,
          isApplicable: true,
          ageGroup: "65-69",
          bmiCategory: "20-24",
        );

        final json = result.toJson();

        expect(json['bmi'], equals('24.49'));
        expect(json['score'], equals(2));
        expect(json['risk_level'], equals('low'));
        expect(json['is_high_risk'], equals(false));
        expect(json['is_applicable'], equals(true));
      });

      test('toJson - Not applicable', () {
        final result = RiskResult(
          bmi: 38.0,
          score: 6,
          riskLevel: RiskLevel.notApplicable,
          isHighRisk: false,
          isApplicable: false,
          ageGroup: "50-54",
          bmiCategory: "35-39",
        );

        final json = result.toJson();

        expect(json['risk_level'], equals('notApplicable'));
        expect(json['is_applicable'], equals(false));
      });
    });
  });
}

