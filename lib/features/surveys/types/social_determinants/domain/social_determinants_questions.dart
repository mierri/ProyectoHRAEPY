import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_fields.dart';

class SocialDeterminantsQuestions {
  static const List<SurveyQuestion> questions = [];
}

const _siNo = [
  SurveyChoice(value: 0, label: 'Sí'),
  SurveyChoice(value: 1, label: 'No'),
];

const socialDeterminantsQuestions = <FormQuestion>[
  FormQuestion(
    number: '1',
    label: '¿Cuál es su nivel de escolaridad?',
    category: 'Escolaridad y ocupación',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.escolaridad,
        label: 'Escolaridad',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.escolaridad,
      ),
    ],
  ),
  FormQuestion(
    number: '2',
    label: '¿Cuál es su ocupación principal actual?',
    category: 'Escolaridad y ocupación',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.ocupacionPrincipal,
        label: 'Ocupación principal',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.ocupacionPrincipal,
      ),
    ],
  ),
  FormQuestion(
    number: '3',
    label: '¿Cuál es el ingreso económico aproximado de su hogar al mes?',
    category: 'Escolaridad y ocupación',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.ingresoMensual,
        label: 'Ingreso mensual',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.ingresoMensual,
      ),
    ],
  ),
  FormQuestion(
    number: '4',
    label: '¿En qué tipo de vivienda reside?',
    category: 'Vivienda',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.tipoVivienda,
        label: 'Tipo de vivienda',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.tipoVivienda,
      ),
      FormConditionalField(
        fieldId: SocialDeterminantsFieldIds.tipoViviendaOtro,
        label: 'Especifique',
        type: FormFieldType.text,
        watchFieldId: SocialDeterminantsFieldIds.tipoVivienda,
        showWhenEquals: 4,
      ),
    ],
  ),
  FormQuestion(
    number: '5',
    label: '¿Cuál es el material predominante de los muros de su vivienda?',
    category: 'Vivienda',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.materialMuros,
        label: 'Material de los muros',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.materialMuros,
      ),
      FormConditionalField(
        fieldId: SocialDeterminantsFieldIds.materialMurosOtro,
        label: 'Especifique',
        type: FormFieldType.text,
        watchFieldId: SocialDeterminantsFieldIds.materialMuros,
        showWhenEquals: 4,
      ),
    ],
  ),
  FormQuestion(
    number: '6',
    label: '¿Cuántos cuartos están destinados exclusivamente para dormir?',
    category: 'Vivienda',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.cuartosDormir,
        label: 'Número de cuartos',
        type: FormFieldType.numeric,
      ),
    ],
  ),
  FormQuestion(
    number: '7',
    label: '¿Quién aporta más al ingreso del hogar?',
    category: 'Ingreso y seguridad social',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.aporteIngreso,
        label: 'Aporte de ingreso',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.aporteIngreso,
      ),
    ],
  ),
  FormQuestion(
    number: '8',
    label: '¿A qué seguridad social está afiliado?',
    category: 'Ingreso y seguridad social',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.seguridadSocial,
        label: 'Seguridad social',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.seguridadSocial,
      ),
    ],
  ),
  FormQuestion(
    number: '9',
    label: '¿En qué programas sociales participa su hogar? (marque todos los que apliquen)',
    category: 'Programas sociales',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.programasSociales,
        label: 'Programas sociales',
        type: FormFieldType.multiChoice,
        options: SocialDeterminantsChoices.programasSociales,
        exclusiveValue: 0,
      ),
      FormConditionalField(
        fieldId: SocialDeterminantsFieldIds.programasSocialesOtro,
        label: 'Especifique el otro programa',
        type: FormFieldType.text,
        watchFieldId: SocialDeterminantsFieldIds.programasSociales,
        showWhenContains: 5,
      ),
    ],
  ),
  FormQuestion(
    number: '10',
    label: '¿Su vivienda cuenta con los siguientes servicios básicos?',
    category: 'Servicios básicos',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.aguaPotable,
        label: 'Agua potable dentro de la vivienda',
        type: FormFieldType.singleChoice,
        options: _siNo,
      ),
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.drenaje,
        label: 'Drenaje conectado a red pública',
        type: FormFieldType.singleChoice,
        options: _siNo,
      ),
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.energiaElectrica,
        label: 'Energía eléctrica',
        type: FormFieldType.singleChoice,
        options: _siNo,
      ),
    ],
  ),
  FormQuestion(
    number: '11',
    label: 'Media de personas que viven en el hogar',
    category: 'Composición del hogar',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.personasTotal,
        label: 'Número total de personas',
        type: FormFieldType.numeric,
      ),
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.menores18,
        label: 'Número de menores de 18 años',
        type: FormFieldType.numeric,
      ),
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.ninosMenores5,
        label: 'Número de niños menores de 5 años',
        type: FormFieldType.numeric,
      ),
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.mayores65,
        label: 'Número de personas mayores de 65 años',
        type: FormFieldType.numeric,
      ),
    ],
  ),
  FormQuestion(
    number: '12',
    label: '¿Con cuáles de los siguientes bienes cuenta su hogar? (marque todos los que tenga)',
    category: 'Bienes y satisfacciones',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.bienesDurables,
        label: 'Bienes durables',
        type: FormFieldType.multiChoice,
        options: SocialDeterminantsChoices.bienesDurables,
        exclusiveValue: 7,
      ),
    ],
  ),
  FormQuestion(
    number: '13',
    label: '¿Qué tan satisfecho(a) está con las condiciones de su vivienda?',
    category: 'Bienes y satisfacciones',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.satisfaccionVivienda,
        label: '1 = Muy insatisfecho(a)  ·  5 = Muy satisfecho(a)',
        type: FormFieldType.scale,
      ),
    ],
  ),
  FormQuestion(
    number: '14',
    label: '¿Qué tan satisfecho(a) está con el ingreso de su hogar?',
    category: 'Bienes y satisfacciones',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.satisfaccionIngreso,
        label: '1 = Muy insatisfecho(a)  ·  5 = Muy satisfecho(a)',
        type: FormFieldType.scale,
      ),
    ],
  ),
  FormQuestion(
    number: '15',
    label: '¿Cómo percibe el apoyo social con el que cuenta?',
    category: 'Bienes y satisfacciones',
    fields: [
      FormFieldDef(
        fieldId: SocialDeterminantsFieldIds.apoyoSocial,
        label: 'Apoyo social',
        type: FormFieldType.singleChoice,
        options: SocialDeterminantsChoices.apoyoSocial,
      ),
    ],
  ),
];
