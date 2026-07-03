import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_fields.dart';

class MocaBlindScoring {
  static int totalScore(Map<int, int> answers) {
    final rawTotal =
        _bool(answers, MocaBlindFieldIds.digitosDirectos) +
        _bool(answers, MocaBlindFieldIds.digitosInversos) +
        _bool(answers, MocaBlindFieldIds.vigilanciaA) +
        _serial7(answers[MocaBlindFieldIds.sietesCorrectos] ?? 0) +
        _bool(answers, MocaBlindFieldIds.frase1) +
        _bool(answers, MocaBlindFieldIds.frase2) +
        _fluidez(answers[MocaBlindFieldIds.fluidezF] ?? 0) +
        _bool(answers, MocaBlindFieldIds.abstraccionTransporte) +
        _bool(answers, MocaBlindFieldIds.abstraccionMedicion) +
        _bool(answers, MocaBlindFieldIds.recuerdoRostro) +
        _bool(answers, MocaBlindFieldIds.recuerdoSeda) +
        _bool(answers, MocaBlindFieldIds.recuerdoTemplo) +
        _bool(answers, MocaBlindFieldIds.recuerdoClavel) +
        _bool(answers, MocaBlindFieldIds.recuerdoRojo) +
        _bool(answers, MocaBlindFieldIds.fechaCorrecta) +
        _bool(answers, MocaBlindFieldIds.mesCorrecto) +
        _bool(answers, MocaBlindFieldIds.anioCorrecto) +
        _bool(answers, MocaBlindFieldIds.diaSemanaCorrecto) +
        _bool(answers, MocaBlindFieldIds.lugarCorrecto) +
        _bool(answers, MocaBlindFieldIds.ciudadCorrecta);

    final correction = rawTotal < 22 && _isYes(answers, MocaBlindFieldIds.escolaridadMenor12) ? 1 : 0;
    return (rawTotal + correction).clamp(0, 22);
  }

  static int memoryIndexScore(Map<int, int> answers) {
    final freeRecall =
        _bool(answers, MocaBlindFieldIds.recuerdoRostro) +
        _bool(answers, MocaBlindFieldIds.recuerdoSeda) +
        _bool(answers, MocaBlindFieldIds.recuerdoTemplo) +
        _bool(answers, MocaBlindFieldIds.recuerdoClavel) +
        _bool(answers, MocaBlindFieldIds.recuerdoRojo);
    final categoryRecall = (answers[MocaBlindFieldIds.recuerdoCategoria] ?? 0).clamp(0, 5);
    final multipleChoiceRecall = (answers[MocaBlindFieldIds.recuerdoMultiple] ?? 0).clamp(0, 5);
    return ((freeRecall * 3) + (categoryRecall * 2) + multipleChoiceRecall).clamp(0, 15);
  }

  static String levelForScore(int score) => score >= 19 ? 'Normal' : 'Bajo esperado';

  static String interpretation(int score) {
    final base = 'MoCA Blind completado. Puntaje total ajustado: $score/22.';
    if (score >= 19) {
      return '$base Un puntaje de 19 o mas se considera dentro del rango normal para esta version.';
    }
    return '$base Un puntaje menor de 19 se considera por debajo del rango normal y amerita interpretacion clinica especializada.';
  }

  static int _bool(Map<int, int> answers, int fieldId) => _isYes(answers, fieldId) ? 1 : 0;
  static bool _isYes(Map<int, int> answers, int fieldId) => (answers[fieldId] ?? 0) == 1;
  static int _fluidez(int words) => words >= 11 ? 1 : 0;

  static int _serial7(int correctSubtractions) {
    if (correctSubtractions >= 4) return 3;
    if (correctSubtractions >= 2) return 2;
    if (correctSubtractions == 1) return 1;
    return 0;
  }
}
