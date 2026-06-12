import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

class SociodemographicFieldIds {
  static const int sexo = 1;
  static const int sexoOtro = 2;
  static const int edad = 3;
  static const int estadoCivil = 4;
  static const int lugarNacimientoEstado = 5;
  static const int lugarNacimientoMunicipio = 6;
  static const int residenciaCiudad = 7;
  static const int residenciaEstado = 8;
  static const int residenciaTipoLocalidad = 9;
  static const int situacionLaboral = 12;
  static const int menoresHogar = 14;
  static const int jefaturaHogar = 15;
  static const int nivelSocioeconomico = 18;
  static const int grupoEtnico = 19;
  static const int grupoEtnicoNombre = 20;
}

class SociodemographicChoices {
  static const List<SurveyChoice> sexo = [
    SurveyChoice(value: 0, label: 'Mujer'),
    SurveyChoice(value: 1, label: 'Hombre'),
    SurveyChoice(value: 2, label: 'Otro'),
  ];

  static const List<SurveyChoice> estadoCivil = [
    SurveyChoice(value: 0, label: 'Soltero(a)'),
    SurveyChoice(value: 1, label: 'Casado(a)'),
    SurveyChoice(value: 2, label: 'Unión libre'),
    SurveyChoice(value: 3, label: 'Separado(a) / Divorciado(a)'),
    SurveyChoice(value: 4, label: 'Viudo(a)'),
  ];

  static const List<SurveyChoice> tipoLocalidad = [
    SurveyChoice(value: 0, label: 'Urbana'),
    SurveyChoice(value: 1, label: 'Rural'),
  ];

  static const List<SurveyChoice> situacionLaboral = [
    SurveyChoice(value: 0, label: 'Asalariado(a) en el sector privado'),
    SurveyChoice(value: 1, label: 'Asalariado(a) en el sector público'),
    SurveyChoice(value: 2, label: 'Trabajo por cuenta propia / independiente'),
    SurveyChoice(value: 3, label: 'Trabajo no remunerado'),
    SurveyChoice(value: 4, label: 'No aplica'),
  ];

  static const List<SurveyChoice> jefaturaHogar = [
    SurveyChoice(value: 0, label: 'Mujer'),
    SurveyChoice(value: 1, label: 'Hombre'),
    SurveyChoice(value: 2, label: 'No aplica / desconocido'),
  ];

  static const List<SurveyChoice> nivelSocioeconomico = [
    SurveyChoice(value: 0, label: 'NSE alto (A/B)'),
    SurveyChoice(value: 1, label: 'NSE medio alto (C1)'),
    SurveyChoice(value: 2, label: 'NSE medio bajo (C2)'),
    SurveyChoice(value: 3, label: 'NSE bajo (D/E)'),
  ];

  static const List<SurveyChoice> grupoEtnico = [
    SurveyChoice(value: 0, label: 'No pertenezco'),
    SurveyChoice(value: 1, label: 'Sí, pertenezco a un pueblo indígena / comunidad originaria'),
  ];
}

class SociodemographicRequiredFields {
  static const Map<int, String> labels = {
    SociodemographicFieldIds.sexo: 'Sexo',
    SociodemographicFieldIds.edad: 'Edad',
    SociodemographicFieldIds.estadoCivil: 'Estado civil',
    SociodemographicFieldIds.lugarNacimientoEstado: 'Lugar de nacimiento (estado)',
    SociodemographicFieldIds.lugarNacimientoMunicipio: 'Lugar de nacimiento (municipio)',
    SociodemographicFieldIds.residenciaCiudad: 'Residencia actual (ciudad o localidad)',
    SociodemographicFieldIds.residenciaEstado: 'Residencia actual (estado)',
    SociodemographicFieldIds.residenciaTipoLocalidad: 'Tipo de localidad',
    SociodemographicFieldIds.menoresHogar: 'Menores en el hogar',
    SociodemographicFieldIds.jefaturaHogar: 'Jefatura del hogar',
    SociodemographicFieldIds.grupoEtnico: 'Grupo étnico',
  };
}

