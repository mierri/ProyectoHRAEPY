import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_fields.dart';

class SociodemographicQuestions {
  static const List<SurveyQuestion> questions = [];
}

const sociodemographicQuestions = <FormQuestion>[
  FormQuestion(
    number: '1',
    label: '¿Cuál es su sexo?',
    category: 'Identificación básica',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.sexo,
        label: 'Sexo',
        type: FormFieldType.singleChoice,
        options: SociodemographicChoices.sexo,
      ),
      FormConditionalField(
        fieldId: SociodemographicFieldIds.sexoOtro,
        label: 'Especifique',
        type: FormFieldType.text,
        watchFieldId: SociodemographicFieldIds.sexo,
        showWhenEquals: 2,
      ),
    ],
  ),
  FormQuestion(
    number: '2',
    label: '¿Cuántos años cumplidos tiene?',
    category: 'Identificación básica',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.edad,
        label: 'Edad (años cumplidos)',
        type: FormFieldType.numeric,
      ),
    ],
  ),
  FormQuestion(
    number: '3',
    label: '¿Cuál es su estado civil?',
    category: 'Estado civil y origen',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.estadoCivil,
        label: 'Estado civil',
        type: FormFieldType.singleChoice,
        options: SociodemographicChoices.estadoCivil,
      ),
    ],
  ),
  FormQuestion(
    number: '4',
    label: '¿Cuál es su lugar de nacimiento?',
    category: 'Estado civil y origen',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.lugarNacimientoEstado,
        label: 'Estado',
        type: FormFieldType.text,
      ),
      FormFieldDef(
        fieldId: SociodemographicFieldIds.lugarNacimientoMunicipio,
        label: 'Municipio',
        type: FormFieldType.text,
      ),
    ],
  ),
  FormQuestion(
    number: '5',
    label: '¿Cuál es su lugar de residencia actual?',
    category: 'Residencia actual',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.residenciaCiudad,
        label: 'Ciudad o localidad',
        type: FormFieldType.text,
      ),
      FormFieldDef(
        fieldId: SociodemographicFieldIds.residenciaEstado,
        label: 'Estado',
        type: FormFieldType.text,
      ),
      FormFieldDef(
        fieldId: SociodemographicFieldIds.residenciaTipoLocalidad,
        label: 'Tipo de localidad',
        type: FormFieldType.singleChoice,
        options: SociodemographicChoices.tipoLocalidad,
      ),
    ],
  ),
  FormQuestion(
    number: '6',
    label: '¿Cuál es su situación laboral actual?',
    category: 'Educación y trabajo',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.situacionLaboral,
        label: 'Situación laboral (si aplica)',
        type: FormFieldType.singleChoice,
        options: SociodemographicChoices.situacionLaboral,
      ),
    ],
  ),
  FormQuestion(
    number: '7',
    label: '¿Quién es el jefe o jefa del hogar?',
    category: 'Hogar',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.jefaturaHogar,
        label: 'Jefatura del hogar',
        type: FormFieldType.singleChoice,
        options: SociodemographicChoices.jefaturaHogar,
      ),
    ],
  ),
  FormQuestion(
    number: '8',
    label: '¿Cuál es su nivel socioeconómico? (opcional)',
    category: 'Seguridad social e ingreso',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.nivelSocioeconomico,
        label: 'Nivel socioeconómico',
        type: FormFieldType.singleChoice,
        options: SociodemographicChoices.nivelSocioeconomico,
        isRequired: false,
      ),
    ],
  ),
  FormQuestion(
    number: '9',
    label: '¿Pertenece a algún grupo étnico o indígena?',
    category: 'Identidad cultural',
    fields: [
      FormFieldDef(
        fieldId: SociodemographicFieldIds.grupoEtnico,
        label: 'Grupo étnico',
        type: FormFieldType.singleChoice,
        options: SociodemographicChoices.grupoEtnico,
      ),
      FormConditionalField(
        fieldId: SociodemographicFieldIds.grupoEtnicoNombre,
        label: 'Nombre del grupo',
        type: FormFieldType.text,
        watchFieldId: SociodemographicFieldIds.grupoEtnico,
        showWhenEquals: 1,
      ),
    ],
  ),
];
