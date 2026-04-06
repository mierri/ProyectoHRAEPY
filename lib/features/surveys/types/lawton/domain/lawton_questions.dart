import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

class LawtonQuestions {
  static const List<SurveyQuestion> questions = [
    SurveyQuestion(
      number: 1,
      category: 'Capacidad para usar el telefono',
      options: [
        SurveyOption(score: 1, text: 'Si: Lo opera por iniciativa propia, lo marca sin problemas.'),
        SurveyOption(score: 1, text: 'Si: Marca solo unos cuantos numeros bien conocidos.'),
        SurveyOption(score: 1, text: 'Si: Contesta el telefono pero no llama.'),
        SurveyOption(score: 0, text: 'No: No usa el telefono.'),
      ],
    ),
    SurveyQuestion(
      number: 2,
      category: 'Transporte',
      options: [
        SurveyOption(score: 1, text: 'Si: Se transporta solo/a.'),
        SurveyOption(score: 1, text: 'Si: Se transporta solo/a, unicamente en taxi pero no puede usar otros recursos.'),
        SurveyOption(score: 1, text: 'Si: Viaja en transporte colectivo acompanado.'),
        SurveyOption(score: 0, text: 'No: Viaja en taxi o auto acompanado.'),
        SurveyOption(score: 0, text: 'No: No sale.'),
      ],
    ),
    SurveyQuestion(
      number: 3,
      category: 'Medicacion',
      options: [
        SurveyOption(score: 1, text: 'Si: Es capaz de tomarla a su hora y dosis correctas.'),
        SurveyOption(score: 0, text: 'No: Se hace responsable solo si le preparan por adelantado.'),
        SurveyOption(score: 0, text: 'No: Es incapaz de hacerse cargo.'),
      ],
    ),
    SurveyQuestion(
      number: 4,
      category: 'Finanzas',
      options: [
        SurveyOption(score: 1, text: 'Si: Maneja sus asuntos independientemente.'),
        SurveyOption(score: 0, text: 'No: Solo puede manejar lo necesario para pequenas compras.'),
        SurveyOption(score: 0, text: 'No: Es incapaz de manejar dinero.'),
      ],
    ),
    SurveyQuestion(
      number: 5,
      category: 'Compras',
      options: [
        SurveyOption(score: 1, text: 'Si: Vigila sus necesidades independientemente.'),
        SurveyOption(score: 0, text: 'No: Hace independientemente solo pequenas compras.'),
        SurveyOption(score: 0, text: 'No: Necesita compania para cualquier compra.'),
        SurveyOption(score: 0, text: 'No: Incapaz de cualquier compra.'),
      ],
    ),
    SurveyQuestion(
      number: 6,
      category: 'Cocina',
      options: [
        SurveyOption(score: 1, text: 'Si: Planea, prepara y sirve los alimentos correctamente.'),
        SurveyOption(score: 0, text: 'No: Prepara los alimentos solo si se le provee lo necesario.'),
        SurveyOption(score: 0, text: 'No: Calienta, sirve y prepara pero no lleva una dieta adecuada.'),
        SurveyOption(score: 0, text: 'No: Necesita que le preparen los alimentos.'),
      ],
    ),
    SurveyQuestion(
      number: 7,
      category: 'Cuidado del hogar',
      options: [
        SurveyOption(score: 1, text: 'Si: Mantiene la casa solo o con ayuda minima.'),
        SurveyOption(score: 1, text: 'Si: Efectua diariamente trabajo ligero eficientemente.'),
        SurveyOption(score: 1, text: 'Si: Efectua diariamente trabajo ligero sin eficiencia.'),
        SurveyOption(score: 0, text: 'No: Necesita ayuda en todas las actividades.'),
        SurveyOption(score: 0, text: 'No: No participa.'),
      ],
    ),
    SurveyQuestion(
      number: 8,
      category: 'Lavanderia',
      options: [
        SurveyOption(score: 1, text: 'Si: Se ocupa de su ropa independientemente.'),
        SurveyOption(score: 1, text: 'Si: Lava solo pequenas cosas.'),
        SurveyOption(score: 0, text: 'No: Todos se lo tienen que lavar.'),
      ],
    ),
  ];
}
