import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

class SpecialtyConsultationAttendanceFieldIds {
  static const int nombreCompleto = 1;
  static const int numeroExpediente = 2;
  static const int fechaNacimiento = 3;
  static const int localidadResidencia = 4;
  static const int transportePrivado = 5;
  static const int especialidad = 6;
  static const int especialidadOtra = 7;
  static const int faltoCita = 8;
  static const int citasPerdidas = 9;
}

class SpecialtyConsultationAttendanceChoices {
  static const List<SurveyChoice> siNo = [
    SurveyChoice(value: 0, label: 'Sí'),
    SurveyChoice(value: 1, label: 'No'),
  ];

  static const List<SurveyChoice> especialidades = [
    SurveyChoice(value: 0, label: 'Cardiología'),
    SurveyChoice(value: 1, label: 'Urología'),
    SurveyChoice(value: 2, label: 'Cirugía General'),
    SurveyChoice(value: 3, label: 'Endocrinología'),
    SurveyChoice(value: 4, label: 'Gastroenterología'),
    SurveyChoice(value: 5, label: 'Geriatría'),
    SurveyChoice(value: 6, label: 'Hematología'),
    SurveyChoice(value: 7, label: 'Medicina Interna'),
    SurveyChoice(value: 8, label: 'Nefrología'),
    SurveyChoice(value: 9, label: 'Neumología'),
    SurveyChoice(value: 10, label: 'Neurología'),
    SurveyChoice(value: 11, label: 'Oncología'),
    SurveyChoice(value: 12, label: 'Psiquiatría'),
    SurveyChoice(value: 13, label: 'Reumatología'),
    SurveyChoice(value: 14, label: 'Infectología'),
    SurveyChoice(value: 15, label: 'Otra'),
  ];

  static const List<SurveyChoice> citasPerdidas = [
    SurveyChoice(value: 0, label: '1'),
    SurveyChoice(value: 1, label: '2'),
    SurveyChoice(value: 2, label: '3'),
    SurveyChoice(value: 3, label: '4 o más'),
  ];
}

class SpecialtyConsultationAttendanceRequiredFields {
  static const Map<int, String> labels = {
    SpecialtyConsultationAttendanceFieldIds.nombreCompleto: 'Nombre completo',
    SpecialtyConsultationAttendanceFieldIds.numeroExpediente: 'Número de expediente',
    SpecialtyConsultationAttendanceFieldIds.fechaNacimiento: 'Fecha de nacimiento',
    SpecialtyConsultationAttendanceFieldIds.localidadResidencia: 'Localidad de residencia',
    SpecialtyConsultationAttendanceFieldIds.transportePrivado: 'Medio de transporte privado',
    SpecialtyConsultationAttendanceFieldIds.especialidad: 'Especialidad médica',
    SpecialtyConsultationAttendanceFieldIds.faltoCita: 'Faltó a alguna cita',
  };
}
