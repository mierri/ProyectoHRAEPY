import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

class PerceivedAttendanceBarriersFieldIds {
  static const int motivoReciente = 1;
  static const int motivoRecienteOtro = 2;
  static const int motivoFuturoPrincipal = 3;
  static const int motivoFuturoPrincipalOtro = 4;
  static const int motivoFuturoSecundario = 5;
  static const int motivoFuturoSecundarioOtro = 6;
  static const int motivoFuturoTerciario = 7;
  static const int motivoFuturoTerciarioOtro = 8;
}

class PerceivedAttendanceBarriersChoices {
  static const int otroMotivoValue = 15;

  static const List<SurveyChoice> motivos = [
    SurveyChoice(
      value: 0,
      label: 'No contaba con dinero suficiente para el traslado.',
    ),
    SurveyChoice(
      value: 1,
      label: 'No tenía medio de transporte disponible.',
    ),
    SurveyChoice(
      value: 2,
      label: 'La distancia o el tiempo de traslado al hospital dificultaron mi asistencia.',
    ),
    SurveyChoice(
      value: 3,
      label: 'Necesitaba recursos para hospedaje y/o alimentación durante el traslado al hospital y no contaba con ellos.',
    ),
    SurveyChoice(
      value: 4,
      label: 'Tuve problemas de salud que me impidieron acudir.',
    ),
    SurveyChoice(
      value: 5,
      label: 'Me sentía mejor y consideré que no era necesario asistir.',
    ),
    SurveyChoice(
      value: 6,
      label: 'Tuve compromisos laborales.',
    ),
    SurveyChoice(
      value: 7,
      label: 'Tuve compromisos escolares.',
    ),
    SurveyChoice(
      value: 8,
      label: 'Tuve responsabilidades familiares o de cuidado de otras personas.',
    ),
    SurveyChoice(
      value: 9,
      label: 'Olvidé la cita.',
    ),
    SurveyChoice(
      value: 10,
      label: 'Llegué tarde a la cita.',
    ),
    SurveyChoice(
      value: 11,
      label: 'No contaba con un acompañante para acudir.',
    ),
    SurveyChoice(
      value: 12,
      label: 'La cita fue cancelada o modificada por el hospital.',
    ),
    SurveyChoice(
      value: 13,
      label: 'Hubo problemas administrativos relacionados con mi atención.',
    ),
    SurveyChoice(
      value: 14,
      label: 'Las condiciones climáticas dificultaron mi asistencia.',
    ),
    SurveyChoice(
      value: otroMotivoValue,
      label: 'Otro motivo',
    ),
  ];
}
