import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_fields.dart';

class MocaBasicScoring {
  static int totalScore(Map<int, int> answers) {
    final rawTotal =
        _bool(answers, MocaBasicFieldIds.trailCorrect) +
        _bool(answers, MocaBasicFieldIds.cubeCorrect) +
        _bool(answers, MocaBasicFieldIds.clockContour) +
        _bool(answers, MocaBasicFieldIds.clockNumbers) +
        _bool(answers, MocaBasicFieldIds.clockHands) +
        _bool(answers, MocaBasicFieldIds.namingLion) +
        _bool(answers, MocaBasicFieldIds.namingRhino) +
        _bool(answers, MocaBasicFieldIds.namingCamel) +
        _bool(answers, MocaBasicFieldIds.digitsForward) +
        _bool(answers, MocaBasicFieldIds.digitsBackward) +
        _bool(answers, MocaBasicFieldIds.vigilance) +
        _serialSevens(answers[MocaBasicFieldIds.serialSevensCorrect] ?? 0) +
        _bool(answers, MocaBasicFieldIds.sentence1) +
        _bool(answers, MocaBasicFieldIds.sentence2) +
        _fluency(answers[MocaBasicFieldIds.fluencyWords] ?? 0) +
        _bool(answers, MocaBasicFieldIds.abstractionTrainBicycle) +
        _bool(answers, MocaBasicFieldIds.abstractionWatchRuler) +
        _bool(answers, MocaBasicFieldIds.delayedRostro) +
        _bool(answers, MocaBasicFieldIds.delayedSeda) +
        _bool(answers, MocaBasicFieldIds.delayedTemplo) +
        _bool(answers, MocaBasicFieldIds.delayedClavel) +
        _bool(answers, MocaBasicFieldIds.delayedRojo) +
        _bool(answers, MocaBasicFieldIds.orientationDate) +
        _bool(answers, MocaBasicFieldIds.orientationMonth) +
        _bool(answers, MocaBasicFieldIds.orientationYear) +
        _bool(answers, MocaBasicFieldIds.orientationDay) +
        _bool(answers, MocaBasicFieldIds.orientationPlace) +
        _bool(answers, MocaBasicFieldIds.orientationCity);

    final educationCorrection =
        rawTotal < 30 && _isYes(answers, MocaBasicFieldIds.education12OrLess)
        ? 1
        : 0;
    return (rawTotal + educationCorrection).clamp(0, 30);
  }

  static String levelForScore(int score) => score >= 26 ? 'Normal' : 'Interpretacion clinica';

  static String interpretation(int score) {
    return 'MoCA 8.1 completado. Puntaje total ajustado: $score/30. La app aplica la correccion oficial de +1 por escolaridad de 12 anos o menos cuando corresponde. El resultado debe interpretarse junto con la observacion clinica y el desempeno por dominios.';
  }

  static int _bool(Map<int, int> answers, int fieldId) =>
      _isYes(answers, fieldId) ? 1 : 0;

  static bool _isYes(Map<int, int> answers, int fieldId) =>
      (answers[fieldId] ?? 0) == 1;

  static int _fluency(int words) => words >= 11 ? 1 : 0;

  static int _serialSevens(int correctSubtractions) {
    if (correctSubtractions >= 4) return 3;
    if (correctSubtractions >= 2) return 2;
    if (correctSubtractions == 1) return 1;
    return 0;
  }
}
