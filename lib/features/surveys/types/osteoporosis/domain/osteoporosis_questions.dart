import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

class OsteoporosisQuestions {
  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: '¿Has tenido alguna fractura? (fractura de vértebra o de fémur severo)',
      options: [
        SurveyOption(score: 1, text: 'Sí'),
        SurveyOption(score: 0, text: 'No'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: '¿Alguno de sus padres ha tenido o tuvo fractura de cadera?',
      options: [
        SurveyOption(score: 1, text: 'Sí'),
        SurveyOption(score: 0, text: 'No'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: '¿Fuma actualmente?',
      options: [
        SurveyOption(score: 1, text: 'Sí'),
        SurveyOption(score: 0, text: 'No'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: '¿Utiliza glucocorticoides (medicamentos antiinflamatorios esteroideos, por ejemplo prednisona, dexametasona o hidrocortisona) o los ha tomado por m¿s de 3 meses?',
      options: [
        SurveyOption(score: 1, text: 'Sí'),
        SurveyOption(score: 0, text: 'No'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: '¿Le han diagnosticado artritis reumatoide?',
      options: [
        SurveyOption(score: 1, text: 'Sí'),
        SurveyOption(score: 0, text: 'No'),
      ],
    ),
    SurveyQuestion(
      number: 6,
      category: '¿Presenta osteoporosis secundaria? (Incluye diabetes tipo 1, osteogénesis imperfecta del adulto, hipertiroidismo no tratado, hipogonadismo o menopausia prematura (<45 años), malnutrición o malabsorción crónicas o hepatopatía crónica)',
      options: [
        SurveyOption(score: 1, text: 'Sí'),
        SurveyOption(score: 0, text: 'No'),
      ],
    ),
    SurveyQuestion(
      number: 7,
      category: '¿Toma 3 o más copas diarias de alcohol? (más de 60 ml de bebidas alcohólicas)',
      options: [
        SurveyOption(score: 1, text: 'Sí'),
        SurveyOption(score: 0, text: 'No'),
      ],
    ),
  ];
}
