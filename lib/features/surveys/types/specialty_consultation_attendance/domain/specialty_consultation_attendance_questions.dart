import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_fields.dart';

class SpecialtyConsultationAttendanceQuestions {
  static const List<SurveyQuestion> questions = [];
}

const specialtyConsultationAttendanceQuestions = <FormQuestion>[
  FormQuestion(
    number: '1',
    label: 'Nombre completo',
    category: 'Datos generales del usuario',
    fields: [
      FormFieldDef(
        fieldId: SpecialtyConsultationAttendanceFieldIds.nombreCompleto,
        label: 'Nombre completo',
        type: FormFieldType.text,
      ),
    ],
  ),
  FormQuestion(
    number: '2',
    label: 'Número de expediente',
    category: 'Datos generales del usuario',
    fields: [
      FormFieldDef(
        fieldId: SpecialtyConsultationAttendanceFieldIds.numeroExpediente,
        label: 'Número de expediente',
        type: FormFieldType.text,
      ),
    ],
  ),
  FormQuestion(
    number: '3',
    label: 'Fecha de nacimiento',
    category: 'Datos generales del usuario',
    fields: [
      FormFieldDef(
        fieldId: SpecialtyConsultationAttendanceFieldIds.fechaNacimiento,
        label: 'Fecha de nacimiento (dd/mm/aaaa)',
        type: FormFieldType.text,
      ),
    ],
  ),
  FormQuestion(
    number: '4',
    label: 'Localidad de residencia',
    category: 'Datos generales del usuario',
    fields: [
      FormFieldDef(
        fieldId: SpecialtyConsultationAttendanceFieldIds.localidadResidencia,
        label: 'Localidad de residencia',
        type: FormFieldType.text,
      ),
    ],
  ),
  FormQuestion(
    number: '5',
    label: '¿Cuenta usted o algún familiar cercano con un medio de transporte privado disponible para acudir a sus consultas médicas?',
    category: 'Acceso a consulta',
    fields: [
      FormFieldDef(
        fieldId: SpecialtyConsultationAttendanceFieldIds.transportePrivado,
        label: 'Transporte privado disponible',
        type: FormFieldType.singleChoice,
        options: SpecialtyConsultationAttendanceChoices.siNo,
      ),
    ],
  ),
  FormQuestion(
    number: '6',
    label: 'Especialidad médica a la que acude hoy a consulta',
    category: 'Consulta actual',
    fields: [
      FormFieldDef(
        fieldId: SpecialtyConsultationAttendanceFieldIds.especialidad,
        label: 'Especialidad médica',
        type: FormFieldType.singleChoice,
        options: SpecialtyConsultationAttendanceChoices.especialidades,
      ),
      FormConditionalField(
        fieldId: SpecialtyConsultationAttendanceFieldIds.especialidadOtra,
        label: 'Especifique otra especialidad',
        type: FormFieldType.text,
        watchFieldId: SpecialtyConsultationAttendanceFieldIds.especialidad,
        showWhenEquals: 15,
      ),
    ],
  ),
  FormQuestion(
    number: '7',
    label: 'En relación con esta especialidad médica, ¿ha faltado a alguna cita programada durante los últimos tres meses?',
    category: 'Asistencia reciente',
    fields: [
      FormFieldDef(
        fieldId: SpecialtyConsultationAttendanceFieldIds.faltoCita,
        label: 'Faltó a alguna cita programada',
        type: FormFieldType.singleChoice,
        options: SpecialtyConsultationAttendanceChoices.siNo,
      ),
      FormConditionalField(
        fieldId: SpecialtyConsultationAttendanceFieldIds.citasPerdidas,
        label: 'En caso afirmativo, ¿cuántas citas programadas ha perdido durante los últimos tres meses?',
        type: FormFieldType.singleChoice,
        options: SpecialtyConsultationAttendanceChoices.citasPerdidas,
        watchFieldId: SpecialtyConsultationAttendanceFieldIds.faltoCita,
        showWhenEquals: 0,
      ),
    ],
  ),
];
