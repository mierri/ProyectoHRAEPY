import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_fields.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class SpecialtyConsultationAttendanceController extends FormSurveyController {
  SpecialtyConsultationAttendanceController({
    required super.patientId,
    required super.surveyService,
    super.investigationId,
  }) : super(surveyType: 'specialty_consultation_attendance');

  @override
  Map<int, String> get requiredFields => SpecialtyConsultationAttendanceRequiredFields.labels;

  void preloadPatientData(PatientModel patient) {
    final day = patient.birthDate.day.toString().padLeft(2, '0');
    final month = patient.birthDate.month.toString().padLeft(2, '0');
    final year = patient.birthDate.year.toString();

    setTextAnswer(
      SpecialtyConsultationAttendanceFieldIds.nombreCompleto,
      patient.name,
    );
    setTextAnswer(
      SpecialtyConsultationAttendanceFieldIds.fechaNacimiento,
      '$day/$month/$year',
    );
  }

  @override
  List<String> missingRequiredLabels() {
    final missing = super.missingRequiredLabels();

    final especialidad = intAnswer(SpecialtyConsultationAttendanceFieldIds.especialidad);
    if (especialidad == 15 &&
        (textAnswer(SpecialtyConsultationAttendanceFieldIds.especialidadOtra) ?? '').isEmpty) {
      missing.add('Otra especialidad');
    }

    final faltoCita = intAnswer(SpecialtyConsultationAttendanceFieldIds.faltoCita);
    if (faltoCita == 0 &&
        intAnswer(SpecialtyConsultationAttendanceFieldIds.citasPerdidas) == null) {
      missing.add('Citas programadas perdidas');
    }

    return missing;
  }
}
