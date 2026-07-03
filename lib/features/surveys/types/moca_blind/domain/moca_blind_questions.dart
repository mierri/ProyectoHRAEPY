import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';
import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_fields.dart';

class MocaBlindQuestions {
  static const List<FormQuestion> questions = mocaBlindQuestions;
}

const _siNo = [
  SurveyChoice(value: 1, label: 'Correcto / Si'),
  SurveyChoice(value: 0, label: 'Incorrecto / No'),
];

const mocaBlindQuestions = <FormQuestion>[
  FormQuestion(
    number: '1',
    label: 'Memoria inmediata: diga en voz alta las palabras ROSTRO, SEDA, TEMPLO, CLAVEL y ROJO. Registre cuantas repitio el paciente en cada uno de los dos ensayos. Estos campos no suman al puntaje total.',
    category: 'Memoria inmediata',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.memoriaEnsayo1, label: 'Palabras recordadas en ensayo 1 (0 a 5)', type: FormFieldType.numeric, isRequired: false),
      FormFieldDef(fieldId: MocaBlindFieldIds.memoriaEnsayo2, label: 'Palabras recordadas en ensayo 2 (0 a 5)', type: FormFieldType.numeric, isRequired: false),
    ],
  ),
  FormQuestion(
    number: '2',
    label: 'Atencion: marque si las series de digitos fueron correctas y capture cuantas restas correctas realizo en la serie del 7.',
    category: 'Atencion',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.digitosDirectos, label: 'Digitos hacia delante', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.digitosInversos, label: 'Digitos hacia atras', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.vigilanciaA, label: 'Vigilancia con la letra A (0 o 1 error)', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.sietesCorrectos, label: 'Restas correctas en serie del 7 (0 a 5)', type: FormFieldType.numeric),
    ],
  ),
  FormQuestion(
    number: '3',
    label: 'Repeticion de frases: puntue cada frase solo si fue repetida exactamente.',
    category: 'Lenguaje',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.frase1, label: 'Frase 1 correcta', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.frase2, label: 'Frase 2 correcta', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '4',
    label: 'Fluidez verbal: registre cuantas palabras validas con la letra F dijo en 60 segundos.',
    category: 'Lenguaje',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.fluidezF, label: 'Numero total de palabras con F', type: FormFieldType.numeric),
    ],
  ),
  FormQuestion(
    number: '5',
    label: 'Abstraccion: marque cada par correctamente categorizado.',
    category: 'Abstraccion',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.abstraccionTransporte, label: 'Tren y bicicleta', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.abstraccionMedicion, label: 'Regla y reloj', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '6',
    label: 'Recuerdo diferido: marque cada palabra recordada espontaneamente. Si desea documentar el MIS, registre ademas cuantas palabras surgieron con pista semantica y con opcion multiple.',
    category: 'Memoria diferida',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.recuerdoRostro, label: 'ROSTRO', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.recuerdoSeda, label: 'SEDA', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.recuerdoTemplo, label: 'TEMPLO', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.recuerdoClavel, label: 'CLAVEL', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.recuerdoRojo, label: 'ROJO', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.recuerdoCategoria, label: 'Palabras recuperadas con pista de categoria (0 a 5)', type: FormFieldType.numeric, isRequired: false),
      FormFieldDef(fieldId: MocaBlindFieldIds.recuerdoMultiple, label: 'Palabras recuperadas con opcion multiple (0 a 5)', type: FormFieldType.numeric, isRequired: false),
    ],
  ),
  FormQuestion(
    number: '7',
    label: 'Orientacion: fecha, dia, lugar y ciudad deben ser exactos.',
    category: 'Orientacion',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.fechaCorrecta, label: 'Fecha exacta del mes', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.mesCorrecto, label: 'Mes', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.anioCorrecto, label: 'Anio', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.diaSemanaCorrecto, label: 'Dia de la semana', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.lugarCorrecto, label: 'Lugar', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBlindFieldIds.ciudadCorrecta, label: 'Ciudad', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '8',
    label: 'Correccion oficial: la app suma +1 si tiene 12 anos o menos de estudios y el total aun es menor al maximo.',
    category: 'Ajuste educativo',
    fields: [
      FormFieldDef(fieldId: MocaBlindFieldIds.escolaridadMenor12, label: '12 anos o menos de estudios', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
];
