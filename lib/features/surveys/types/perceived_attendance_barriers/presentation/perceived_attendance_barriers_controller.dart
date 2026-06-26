import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_fields.dart';

class PerceivedAttendanceBarriersController extends FormSurveyController {
  final bool includeAntecedentsSection;

  PerceivedAttendanceBarriersController({
    required super.patientId,
    required super.surveyService,
    required this.includeAntecedentsSection,
    super.investigationId,
  }) : super(surveyType: 'perceived_attendance_barriers');

  @override
  Map<int, String> get requiredFields => {
        if (includeAntecedentsSection)
          PerceivedAttendanceBarriersFieldIds.motivoReciente:
              'Motivo principal de la inasistencia más reciente',
        PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipal:
            'Motivo número 1 para asistencia futura',
        PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundario:
            'Motivo número 2 para asistencia futura',
        PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciario:
            'Motivo número 3 para asistencia futura',
      };

  @override
  List<String> missingRequiredLabels() {
    final missing = super.missingRequiredLabels();

    void requireOtherText(int choiceFieldId, int textFieldId, String label) {
      if (intAnswer(choiceFieldId) ==
              PerceivedAttendanceBarriersChoices.otroMotivoValue &&
          (textAnswer(textFieldId) ?? '').isEmpty) {
        missing.add(label);
      }
    }

    if (includeAntecedentsSection) {
      requireOtherText(
        PerceivedAttendanceBarriersFieldIds.motivoReciente,
        PerceivedAttendanceBarriersFieldIds.motivoRecienteOtro,
        'Otro motivo de inasistencia reciente',
      );
    }

    requireOtherText(
      PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipal,
      PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipalOtro,
      'Otro motivo número 1',
    );
    requireOtherText(
      PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundario,
      PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundarioOtro,
      'Otro motivo número 2',
    );
    requireOtherText(
      PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciario,
      PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciarioOtro,
      'Otro motivo número 3',
    );

    final futureSelections = [
      intAnswer(PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipal),
      intAnswer(PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundario),
      intAnswer(PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciario),
    ].whereType<int>().toList();

    if (futureSelections.length == 3 &&
        futureSelections.toSet().length != futureSelections.length) {
      missing.add(
        'Seleccione tres motivos distintos para la asistencia futura',
      );
    }

    return missing;
  }
}
