import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

class LawtonQuestions {
  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: 'Capacidad para usar el teléfono',
      options: [
        SurveyOption(score: 1, text: 'Uso el teléfono por iniciativa propia.'),
        SurveyOption(score: 1, text: 'Soy capaz de marcar correctamente algunos números familiares.'),
        SurveyOption(score: 1, text: 'Soy capaz de contestar el teléfono, pero no de marcar.'),
        SurveyOption(score: 0, text: 'No soy capaz de usar el teléfono.'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Hacer compras',
      options: [
        SurveyOption(score: 1, text: 'Realizo todas las compras necesarias de manera independiente.'),
        SurveyOption(score: 0, text: 'Realizo pequeñas compras de manera independiente.'),
        SurveyOption(score: 0, text: 'Necesito ir acompañado para hacer cualquier compra.'),
        SurveyOption(score: 0, text: 'Soy totalmente incapaz de hacer compras.'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Preparación de la comida',
      options: [
        SurveyOption(score: 1, text: 'Organizo, preparo y sirvo mis comidas por mí mismo adecuadamente.'),
        SurveyOption(score: 0, text: 'Preparo adecuadamente las comidas si me proporcionan los ingredientes.'),
        SurveyOption(score: 0, text: 'Preparo, caliento y sirvo las comidas, pero no sigo una dieta adecuada.'),
        SurveyOption(score: 0, text: 'Necesito que me preparen y sirvan las comidas.'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Cuidado del hogar',
      options: [
        SurveyOption(score: 1, text: 'Mantengo la casa por mí mismo o con ayuda ocasional (para trabajos pesados).'),
        SurveyOption(score: 1, text: 'Realizo tareas ligeras, como lavar los platos o tender la cama.'),
        SurveyOption(score: 1, text: 'Realizo tareas ligeras, pero no puedo mantener un nivel adecuado de limpieza.'),
        SurveyOption(score: 0, text: 'Necesito ayuda en todas las labores del hogar.'),
        SurveyOption(score: 0, text: 'No participo en ninguna labor del hogar.'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: 'Uso de medios de transporte',
      options: [
        SurveyOption(score: 1, text: 'Viajo solo en transporte público o conduzco mi propio automóvil.'),
        SurveyOption(score: 1, text: 'Soy capaz de tomar un taxi, pero no uso otro medio de transporte.'),
        SurveyOption(score: 1, text: 'Viajo en transporte público cuando voy acompañado por otra persona.'),
        SurveyOption(score: 0, text: 'Solo utilizo el taxi o el automóvil con ayuda de otras personas.'),
        SurveyOption(score: 0, text: 'No viajo.'),
      ],
    ),
    SurveyQuestion(
      number: 6,
      category: 'Lavado de la ropa',
      options: [
        SurveyOption(score: 1, text: 'Lavo toda mi ropa por mí mismo.'),
        SurveyOption(score: 1, text: 'Lavo pequeñas prendas por mí mismo.'),
        SurveyOption(score: 0, text: 'Otra persona debe encargarse de todo el lavado de mi ropa.'),
      ],
    ),
    SurveyQuestion(
      number: 7,
      category: 'Responsabilidad respecto a mi medicación',
      options: [
        SurveyOption(score: 1, text: 'Soy capaz de tomar mi medicación a la hora y con la dosis correcta.'),
        SurveyOption(score: 0, text: 'Tomo mi medicación si la dosis me es preparada previamente.'),
        SurveyOption(score: 0, text: 'No soy capaz de administrarme mi medicación.'),
      ],
    ),
    SurveyQuestion(
      number: 8,
      category: 'Manejo de mis asuntos económicos',
      options: [
        SurveyOption(score: 1, text: 'Me encargo de mis asuntos económicos por mí mismo.'),
        SurveyOption(score: 0, text: 'Realizo las compras diarias, pero necesito ayuda para compras grandes o trámites bancarios.'),
        SurveyOption(score: 0, text: 'Soy incapaz de manejar dinero.'),
      ],
    ),
  ];
}
