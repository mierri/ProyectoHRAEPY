import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

class SocialDeterminantsFieldIds {
  static const int escolaridad = 1;
  static const int ocupacionPrincipal = 2;
  static const int ingresoMensual = 3;
  static const int tipoVivienda = 4;
  static const int tipoViviendaOtro = 5;
  static const int materialMuros = 6;
  static const int materialMurosOtro = 7;
  static const int cuartosDormir = 8;
  static const int aporteIngreso = 9;
  static const int seguridadSocial = 10;
  static const int programasSociales = 11;
  static const int programasSocialesOtro = 12;
  static const int aguaPotable = 13;
  static const int drenaje = 14;
  static const int energiaElectrica = 15;
  static const int personasTotal = 16;
  static const int ninosMenores5 = 17;
  static const int mayores65 = 18;
  static const int bienesDurables = 19;
  static const int satisfaccionVivienda = 20;
  static const int satisfaccionIngreso = 21;
  static const int apoyoSocial = 22;
  static const int menores18 = 23;
}

class SocialDeterminantsChoices {
  static const List<SurveyChoice> escolaridad = [
    SurveyChoice(value: 0, label: 'Sin escolaridad'),
    SurveyChoice(value: 1, label: 'Preescolar'),
    SurveyChoice(value: 2, label: 'Primaria terminada'),
    SurveyChoice(value: 3, label: 'Secundaria terminada'),
    SurveyChoice(value: 4, label: 'Preparatoria / Bachillerato terminada'),
    SurveyChoice(value: 5, label: 'Técnica o carrera tecnológica'),
    SurveyChoice(value: 6, label: 'Licenciatura terminada'),
    SurveyChoice(value: 7, label: 'Posgrado (maestría o doctorado)'),
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

  static const List<SurveyChoice> ingresoMensual = [
    SurveyChoice(value: 0, label: 'Menos de 2,000 pesos'),
    SurveyChoice(value: 1, label: '2,000–4,999 pesos'),
    SurveyChoice(value: 2, label: '5,000–9,999 pesos'),
    SurveyChoice(value: 3, label: '10,000–19,999 pesos'),
    SurveyChoice(value: 4, label: '20,000–39,999 pesos'),
    SurveyChoice(value: 5, label: '40,000 pesos o más'),
    SurveyChoice(value: 6, label: 'Prefiero no contestar'),
  ];

  static const List<SurveyChoice> tipoVivienda = [
    SurveyChoice(value: 0, label: 'Casa'),
    SurveyChoice(value: 1, label: 'Departamento / piso'),
    SurveyChoice(value: 2, label: 'Casa de habitación simple'),
    SurveyChoice(value: 3, label: 'Casa de habitación en conjunto'),
    SurveyChoice(value: 4, label: 'Otro'),
  ];

  static const List<SurveyChoice> materialMuros = [
    SurveyChoice(value: 0, label: 'Tabique / cemento'),
    SurveyChoice(value: 1, label: 'Block'),
    SurveyChoice(value: 2, label: 'Lámina / cartón / material reciclado'),
    SurveyChoice(value: 3, label: 'Madera'),
    SurveyChoice(value: 4, label: 'Otro'),
  ];

  static const List<SurveyChoice> aporteIngreso = [
    SurveyChoice(value: 0, label: 'Toda la familia aporta'),
    SurveyChoice(value: 1, label: 'Una sola persona'),
    SurveyChoice(value: 2, label: 'Dos personas'),
    SurveyChoice(value: 3, label: 'Tres o más personas'),
    SurveyChoice(value: 4, label: 'No sé'),
  ];

  static const List<SurveyChoice> seguridadSocial = [
    SurveyChoice(value: 0, label: 'IMSS'),
    SurveyChoice(value: 1, label: 'ISSSTE'),
    SurveyChoice(value: 2, label: 'Seguro popular / INSABI'),
    SurveyChoice(value: 3, label: 'Pemex / Defensa / Marina'),
    SurveyChoice(value: 4, label: 'Seguro privado'),
    SurveyChoice(value: 5, label: 'Ninguno'),
  ];

  static const List<SurveyChoice> programasSociales = [
    SurveyChoice(value: 0, label: 'No participa en ningún programa'),
    SurveyChoice(value: 1, label: 'Bienestar / Jóvenes'),
    SurveyChoice(value: 2, label: 'Pensión para el Bienestar de las Personas Adultas Mayores'),
    SurveyChoice(value: 3, label: 'Jóvenes Construyendo el Futuro'),
    SurveyChoice(value: 4, label: 'Estancias infantiles'),
    SurveyChoice(value: 5, label: 'Otro'),
  ];

  static const List<SurveyChoice> accesoServicios = [
    SurveyChoice(value: 0, label: 'Sí'),
    SurveyChoice(value: 1, label: 'No'),
  ];

  static const List<SurveyChoice> bienesDurables = [
    SurveyChoice(value: 0, label: 'Televisión'),
    SurveyChoice(value: 1, label: 'Computadora o laptop'),
    SurveyChoice(value: 2, label: 'Teléfono celular'),
    SurveyChoice(value: 3, label: 'Automóvil'),
    SurveyChoice(value: 4, label: 'Moto'),
    SurveyChoice(value: 5, label: 'Refrigerador'),
    SurveyChoice(value: 6, label: 'Lavadora'),
    SurveyChoice(value: 7, label: 'Ninguno'),
  ];

  static const List<SurveyChoice> apoyoSocial = [
    SurveyChoice(value: 0, label: 'Tengo apoyo siempre que lo necesito'),
    SurveyChoice(value: 1, label: 'Tengo apoyo la mayoría de las veces'),
    SurveyChoice(value: 2, label: 'Tengo apoyo ocasionalmente'),
    SurveyChoice(value: 3, label: 'Rara vez tengo apoyo'),
    SurveyChoice(value: 4, label: 'Nunca tengo apoyo'),
  ];
}

class SocialDeterminantsRequiredFields {
  static const Map<int, String> labels = {
    SocialDeterminantsFieldIds.escolaridad: 'Escolaridad',
    SocialDeterminantsFieldIds.ocupacionPrincipal: 'Ocupación principal',
    SocialDeterminantsFieldIds.ingresoMensual: 'Ingreso mensual',
    SocialDeterminantsFieldIds.tipoVivienda: 'Tipo de vivienda',
    SocialDeterminantsFieldIds.materialMuros: 'Material de muros',
    SocialDeterminantsFieldIds.cuartosDormir: 'Cuartos para dormir',
    SocialDeterminantsFieldIds.aporteIngreso: 'Aporte de ingreso',
    SocialDeterminantsFieldIds.seguridadSocial: 'Seguridad social',
    SocialDeterminantsFieldIds.programasSociales: 'Programas sociales',
    SocialDeterminantsFieldIds.aguaPotable: 'Agua potable',
    SocialDeterminantsFieldIds.drenaje: 'Drenaje',
    SocialDeterminantsFieldIds.energiaElectrica: 'Energía eléctrica',
    SocialDeterminantsFieldIds.personasTotal: 'Personas en el hogar',
    SocialDeterminantsFieldIds.menores18: 'Menores de 18 años',
    SocialDeterminantsFieldIds.ninosMenores5: 'Niños menores de 5 años',
    SocialDeterminantsFieldIds.mayores65: 'Personas mayores de 65 años',
    SocialDeterminantsFieldIds.bienesDurables: 'Bienes durables',
    SocialDeterminantsFieldIds.satisfaccionVivienda: 'Satisfacción vivienda',
    SocialDeterminantsFieldIds.satisfaccionIngreso: 'Satisfacción ingreso',
    SocialDeterminantsFieldIds.apoyoSocial: 'Apoyo social',
  };
}

