import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';
import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_fields.dart';

class MocaBasicQuestions {
  static const List<FormQuestion> questions = mocaBasicQuestions;
}

const _siNo = [
  SurveyChoice(value: 1, label: 'Correcto / Si'),
  SurveyChoice(value: 0, label: 'Incorrecto / No'),
];

const mocaBasicQuestions = <FormQuestion>[
  FormQuestion(
    number: '1',
    label: 'Habilidades visoespaciales y ejecutivas: trazado alternante, copia del cubo y dibujo del reloj.',
    category: 'Visoespacial / Ejecutivo',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.trailCorrect, label: 'Trazado alternante', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.cubeCorrect, label: 'Copia del cubo', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.clockContour, label: 'Reloj - contorno', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.clockNumbers, label: 'Reloj - numeros', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.clockHands, label: 'Reloj - manecillas', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '2',
    label: 'Denominacion de animales.',
    category: 'Denominacion',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.namingLion, label: 'Leon', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.namingRhino, label: 'Rinoceronte', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.namingCamel, label: 'Camello', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '3',
    label: 'Memoria inmediata: capture cuantas palabras repitio en cada ensayo. No suman al puntaje total.',
    category: 'Memoria inmediata',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.memoryTrial1, label: 'Ensayo 1 (0 a 5)', type: FormFieldType.numeric, isRequired: false),
      FormFieldDef(fieldId: MocaBasicFieldIds.memoryTrial2, label: 'Ensayo 2 (0 a 5)', type: FormFieldType.numeric, isRequired: false),
    ],
  ),
  FormQuestion(
    number: '4',
    label: 'Atencion: digitos, vigilancia y restas seriadas.',
    category: 'Atencion',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.digitsForward, label: 'Digitos hacia delante', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.digitsBackward, label: 'Digitos hacia atras', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.vigilance, label: 'Vigilancia con letra A', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.serialSevensCorrect, label: 'Restas correctas en serie del 7 (0 a 5)', type: FormFieldType.numeric),
    ],
  ),
  FormQuestion(
    number: '5',
    label: 'Lenguaje: repeticion de frases y fluidez verbal.',
    category: 'Lenguaje',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.sentence1, label: 'Frase 1 correcta', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.sentence2, label: 'Frase 2 correcta', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.fluencyWords, label: 'Palabras con F en 60 segundos', type: FormFieldType.numeric),
    ],
  ),
  FormQuestion(
    number: '6',
    label: 'Abstraccion.',
    category: 'Abstraccion',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.abstractionTrainBicycle, label: 'Tren y bicicleta', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.abstractionWatchRuler, label: 'Reloj y regla', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '7',
    label: 'Recuerdo diferido de las cinco palabras.',
    category: 'Memoria diferida',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.delayedRostro, label: 'ROSTRO', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.delayedSeda, label: 'SEDA', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.delayedTemplo, label: 'TEMPLO', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.delayedClavel, label: 'CLAVEL', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.delayedRojo, label: 'ROJO', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '8',
    label: 'Orientacion.',
    category: 'Orientacion',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.orientationDate, label: 'Fecha', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.orientationMonth, label: 'Mes', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.orientationYear, label: 'Anio', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.orientationDay, label: 'Dia de la semana', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.orientationPlace, label: 'Lugar', type: FormFieldType.singleChoice, options: _siNo),
      FormFieldDef(fieldId: MocaBasicFieldIds.orientationCity, label: 'Ciudad', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
  FormQuestion(
    number: '9',
    label: 'Correccion educativa oficial.',
    category: 'Ajuste',
    fields: [
      FormFieldDef(fieldId: MocaBasicFieldIds.education12OrLess, label: '12 anios o menos de estudios', type: FormFieldType.singleChoice, options: _siNo),
    ],
  ),
];
