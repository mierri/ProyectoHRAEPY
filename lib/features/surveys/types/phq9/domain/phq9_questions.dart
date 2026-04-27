import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

class Phq9Questions {
  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: 'Poco interes o placer en hacer las cosas',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Se ha sentido decaido(a), deprimido(a) o sin esperanzas',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Dificultad para dormir o permanecer dormido(a), o ha dormido demasiado',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Se ha sentido cansado(a) o con poca energia',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: 'Con poco apetito o ha comido en exceso',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 6,
      category: 'Se ha sentido mal con usted mismo(a), o que es un fracaso o que ha quedado mal con usted mismo(a) o con su familia',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 7,
      category: 'Ha tenido dificultad para concentrarse en cosas tales como leer el periodico o ver television',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 8,
      category: 'Se ha estado moviendo o hablando tan lento que otras personas podrian notarlo, o por el contrario ha estado tan inquieto(a) que se ha estado moviendo mucho mas de lo normal',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
    SurveyQuestion(
      number: 9,
      category: 'Ha pensado que estaria mejor muerto(a) o se le ha ocurrido lastimarse de alguna manera',
      options: [
        SurveyOption(score: 0, text: 'Para nada'),
        SurveyOption(score: 1, text: 'Varios dias'),
        SurveyOption(score: 2, text: 'Mas de la mitad de los dias'),
        SurveyOption(score: 3, text: 'Casi todos los dias'),
      ],
    ),
  ];
}

