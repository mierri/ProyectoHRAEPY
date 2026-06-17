import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_fields.dart';

class PerceivedAttendanceBarriersQuestions {
  static const List<SurveyQuestion> questions = [];
}

List<FormQuestion> buildPerceivedAttendanceBarriersQuestions({
  required bool includeAntecedentsSection,
}) {
  final questions = <FormQuestion>[];

  if (includeAntecedentsSection) {
    questions.add(
      const FormQuestion(
        number: '1',
        label:
            'Pensando en la ocasión más reciente en que faltó a una cita médica programada, ¿cuál fue el principal motivo por el que no asistió?',
        category: 'Sección A. Antecedentes de inasistencia',
        fields: [
          FormFieldDef(
            fieldId: PerceivedAttendanceBarriersFieldIds.motivoReciente,
            label: 'Seleccione una sola respuesta',
            type: FormFieldType.singleChoice,
            options: PerceivedAttendanceBarriersChoices.motivos,
          ),
          FormConditionalField(
            fieldId: PerceivedAttendanceBarriersFieldIds.motivoRecienteOtro,
            label: 'Especifique otro motivo',
            type: FormFieldType.text,
            watchFieldId: PerceivedAttendanceBarriersFieldIds.motivoReciente,
            showWhenEquals:
                PerceivedAttendanceBarriersChoices.otroMotivoValue,
          ),
        ],
      ),
    );
  }

  questions.addAll(const [
    FormQuestion(
      number: '2.1',
      label:
          'Independientemente de si ha faltado o no a una cita médica, seleccione el motivo número 1, es decir, el principal motivo por el que considera que podría llegar a faltar a una cita médica programada en este hospital.',
      category: 'Sección B. Barreras percibidas para la asistencia futura',
      fields: [
        FormFieldDef(
          fieldId: PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipal,
          label: 'Motivo número 1',
          type: FormFieldType.singleChoice,
          options: PerceivedAttendanceBarriersChoices.motivos,
        ),
        FormConditionalField(
          fieldId:
              PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipalOtro,
          label: 'Especifique otro motivo',
          type: FormFieldType.text,
          watchFieldId:
              PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipal,
          showWhenEquals:
              PerceivedAttendanceBarriersChoices.otroMotivoValue,
        ),
      ],
    ),
    FormQuestion(
      number: '2.2',
      label:
          'Seleccione el motivo número 2, es decir, el segundo motivo en orden de importancia por el que podría llegar a faltar a una cita médica programada.',
      category: 'Sección B. Barreras percibidas para la asistencia futura',
      fields: [
        FormFieldDef(
          fieldId: PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundario,
          label: 'Motivo número 2',
          type: FormFieldType.singleChoice,
          options: PerceivedAttendanceBarriersChoices.motivos,
        ),
        FormConditionalField(
          fieldId:
              PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundarioOtro,
          label: 'Especifique otro motivo',
          type: FormFieldType.text,
          watchFieldId:
              PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundario,
          showWhenEquals:
              PerceivedAttendanceBarriersChoices.otroMotivoValue,
        ),
      ],
    ),
    FormQuestion(
      number: '2.3',
      label:
          'Seleccione el motivo número 3, es decir, el tercer motivo en orden de importancia por el que podría llegar a faltar a una cita médica programada.',
      category: 'Sección B. Barreras percibidas para la asistencia futura',
      fields: [
        FormFieldDef(
          fieldId: PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciario,
          label: 'Motivo número 3',
          type: FormFieldType.singleChoice,
          options: PerceivedAttendanceBarriersChoices.motivos,
        ),
        FormConditionalField(
          fieldId:
              PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciarioOtro,
          label: 'Especifique otro motivo',
          type: FormFieldType.text,
          watchFieldId:
              PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciario,
          showWhenEquals:
              PerceivedAttendanceBarriersChoices.otroMotivoValue,
        ),
      ],
    ),
  ]);

  return questions;
}
