import 'package:ssapp/models/bdi_questions.dart';

class GDSQuestions {
  static const Set<int> yesScores = {2, 3, 4, 6, 8, 9, 10, 12, 14, 15};
  static const Set<int> noScores = {1, 5, 7, 11, 13};

  static List<SurveyQuestion> get questions {
    return List.generate(_questionTexts.length, (index) {
      final questionNumber = index + 1;
      final yesScore = yesScores.contains(questionNumber) ? 1 : 0;
      final noScore = noScores.contains(questionNumber) ? 1 : 0;

      return SurveyQuestion(
        number: questionNumber,
        category: _questionTexts[index],
        options: [
          SurveyOption(score: yesScore, text: 'Sí'),
          SurveyOption(score: noScore, text: 'No'),
        ],
      );
    });
  }

  static const List<String> _questionTexts = [
    '¿En general, está satisfecho(a) con su vida?',
    '¿Ha abandonado muchas de sus tareas habituales y aficiones?',
    '¿Siente que su vida está vacía?',
    '¿Se siente con frecuencia aburrido(a)?',
    '¿Se encuentra de buen humor la mayor parte del tiempo?',
    '¿Teme que algo malo pueda ocurrirle?',
    '¿Se siente feliz la mayor parte del tiempo?',
    '¿Con frecuencia se siente desamparado(a), desprotegido(a)?',
    '¿Prefiere usted quedarse en casa, más que salir y hacer cosas nuevas?',
    '¿Cree que tiene más problemas de memoria que la mayoría de la gente?',
    '¿En estos momentos, piensa que es estupendo estar vivo(a)?',
    '¿Actualmente se siente un(a) inútil?',
    '¿Se siente lleno(a) de energía?',
    '¿Se siente sin esperanza en este momento?',
    '¿Piensa que la mayoría de la gente está en mejor situación que usted?',
  ];
}
