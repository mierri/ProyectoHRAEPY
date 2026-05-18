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
  static const int escolaridad = 10;
  static const int ocupacionPrincipal = 11;
  static const int situacionLaboral = 12;
  static const int personasHogar = 13;
  static const int menoresHogar = 14;
  static const int jefaturaHogar = 15;
  static const int seguridadSocial = 16;
  static const int ingresoMensual = 17;
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

  static const List<SurveyChoice> escolaridad = [
    SurveyChoice(value: 0, label: 'Sin escolaridad'),
    SurveyChoice(value: 1, label: 'Preescolar'),
    SurveyChoice(value: 2, label: 'Primaria terminada'),
    SurveyChoice(value: 3, label: 'Secundaria terminada'),
    SurveyChoice(value: 4, label: 'Preparatoria / Bachillerato terminada'),
    SurveyChoice(value: 5, label: 'Técnica o carreras tecnológicas'),
    SurveyChoice(value: 6, label: 'Licenciatura terminada'),
    SurveyChoice(value: 7, label: 'Posgrado (maestría, doctorado)'),
  ];

  static const List<SurveyChoice> ocupacionPrincipal = [
    SurveyChoice(value: 0, label: 'Trabajo remunerado (tiempo completo)'),
    SurveyChoice(value: 1, label: 'Trabajo remunerado (tiempo parcial)'),
    SurveyChoice(value: 2, label: 'Trabajo no remunerado (hogar, cuidados)'),
    SurveyChoice(value: 3, label: 'Estudiante'),
    SurveyChoice(value: 4, label: 'Jubilado(a) / Pensionado(a)'),
    SurveyChoice(value: 5, label: 'Desempleado(a), buscando trabajo'),
    SurveyChoice(value: 6, label: 'Desempleado(a), no busca trabajo'),
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

  static const List<SurveyChoice> seguridadSocial = [
    SurveyChoice(value: 0, label: 'IMSS'),
    SurveyChoice(value: 1, label: 'ISSSTE'),
    SurveyChoice(value: 2, label: 'Seguro popular / INSABI'),
    SurveyChoice(value: 3, label: 'Pemex / Defensa / Marina'),
    SurveyChoice(value: 4, label: 'Seguro privado'),
    SurveyChoice(value: 5, label: 'Ninguno'),
  ];

  static const List<SurveyChoice> ingresoMensual = [
    SurveyChoice(value: 0, label: 'Menos de 2,000 pesos'),
    SurveyChoice(value: 1, label: '2,000–4,999 pesos'),
    SurveyChoice(value: 2, label: '5,000–9,999 pesos'),
    SurveyChoice(value: 3, label: '10,000–19,999 pesos'),
    SurveyChoice(value: 4, label: '20,000–39,999 pesos'),
    SurveyChoice(value: 5, label: '40,000 pesos o más'),
    SurveyChoice(value: 6, label: 'Prefiero no contestar'),
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
    SociodemographicFieldIds.escolaridad: 'Escolaridad máxima',
    SociodemographicFieldIds.ocupacionPrincipal: 'Ocupación principal',
    SociodemographicFieldIds.personasHogar: 'Personas en el hogar',
    SociodemographicFieldIds.menoresHogar: 'Menores en el hogar',
    SociodemographicFieldIds.jefaturaHogar: 'Jefatura del hogar',
    SociodemographicFieldIds.seguridadSocial: 'Seguridad social',
    SociodemographicFieldIds.ingresoMensual: 'Ingreso mensual',
    SociodemographicFieldIds.grupoEtnico: 'Grupo étnico',
  };
}

