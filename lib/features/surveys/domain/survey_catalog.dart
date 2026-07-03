import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/gds/domain/gds_questions.dart';
import 'package:ssapp/features/surveys/types/ghq12/domain/ghq12_questions.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/domain/iciq_sf_questions.dart';
import 'package:ssapp/features/surveys/types/katz/domain/katz_questions.dart';
import 'package:ssapp/features/surveys/types/lawton/domain/lawton_questions.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/osteoporosis_questions.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_questions.dart';
import 'package:ssapp/features/surveys/types/phq9/domain/phq9_questions.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_questions.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_questions.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_questions.dart';

class SurveyCatalog {
  static const int bdi = 1;
  static const int bai = 2;
  static const int whoqol = 3;
  static const int sf36 = 5;
  static const int assist = 6;
  static const int gds = 7;
  static const int lawton = 8;
  static const int osteoporosis = 9;
  static const int katz = 10;
  static const int iciqSf = 11;
  static const int ghq12 = 12;
  static const int phq9 = 13;
  static const int sociodemographic = 14;
  static const int socialDeterminants = 15;
  static const int specialtyConsultationAttendance = 16;
  static const int perceivedAttendanceBarriers = 17;
  static const int mocaBasic = 18;
  static const int mocaBlind = 19;
  static const int custom = 100;

  static const Map<int, String> namesById = {
    bdi: 'BDI-II',
    bai: 'BAI',
    whoqol: 'WHOQOL-BREF',
    sf36: 'SF-36',
    assist: 'ASSIST V3.0',
    gds: 'GDS-15',
    lawton: 'Lawton AIVD',
    osteoporosis: 'Osteoporosis',
    katz: 'Katz ABVD',
    iciqSf: 'ICIQ-SF',
    ghq12: 'GHQ-12',
    phq9: 'PHQ-9',
    sociodemographic: 'Sociodemografico',
    socialDeterminants: 'Determinantes Sociales',
    specialtyConsultationAttendance: 'Asistencia en Consulta de Especialidad',
    perceivedAttendanceBarriers: 'Barreras Percibidas para la Asistencia',
    mocaBasic: 'MoCA 8.1',
    mocaBlind: 'MoCA Blind',
    custom: 'Encuesta personalizada',
  };

  static const Map<int, String> colorsById = {
    bdi: 'primary',
    bai: 'tertiary',
    whoqol: 'secondary',
    sf36: 'secondary',
    assist: 'secondary',
    gds: 'secondary',
    lawton: 'secondary',
    osteoporosis: 'secondary',
    katz: 'secondary',
    iciqSf: 'secondary',
    ghq12: 'secondary',
    phq9: 'secondary',
    sociodemographic: 'secondary',
    socialDeterminants: 'secondary',
    specialtyConsultationAttendance: 'secondary',
    perceivedAttendanceBarriers: 'secondary',
    mocaBasic: 'secondary',
    mocaBlind: 'secondary',
    custom: 'primary',
  };

  static const Map<String, int> idsByType = {
    'bdi': bdi,
    'bai': bai,
    'whoqol': whoqol,
    'sf36': sf36,
    'assist': assist,
    'gds': gds,
    'lawton': lawton,
    'katz': katz,
    'iciqsf': iciqSf,
    'osteoporosis': osteoporosis,
    'ghq12': ghq12,
    'phq9': phq9,
    'sociodemographic': sociodemographic,
    'social_determinants': socialDeterminants,
    'socialdeterminants': socialDeterminants,
    'specialty_consultation_attendance': specialtyConsultationAttendance,
    'perceived_attendance_barriers': perceivedAttendanceBarriers,
    'moca_basic': mocaBasic,
    'mocabasic': mocaBasic,
    'moca_blind': mocaBlind,
    'mocablind': mocaBlind,
    'custom': custom,
  };

  static const Map<int, String> typesById = {
    bdi: 'bdi',
    bai: 'bai',
    whoqol: 'whoqol',
    sf36: 'sf36',
    assist: 'assist',
    gds: 'gds',
    lawton: 'lawton',
    osteoporosis: 'osteoporosis',
    katz: 'katz',
    iciqSf: 'iciqsf',
    ghq12: 'ghq12',
    phq9: 'phq9',
    sociodemographic: 'sociodemographic',
    socialDeterminants: 'social_determinants',
    specialtyConsultationAttendance: 'specialty_consultation_attendance',
    perceivedAttendanceBarriers: 'perceived_attendance_barriers',
    mocaBasic: 'moca_basic',
    mocaBlind: 'moca_blind',
    custom: 'custom',
  };

  static int idForType(String surveyType) {
    return idsByType[surveyType.toLowerCase()] ?? bdi;
  }

  static String typeForId(int surveyId) {
    return typesById[surveyId] ?? 'bdi';
  }

  static String nameForId(int surveyId) {
    return namesById[surveyId] ?? 'Encuesta #$surveyId';
  }

  static String colorForId(int surveyId) {
    return colorsById[surveyId] ?? 'secondary';
  }

  static List<SurveyQuestion> questionsForType(String surveyType) {
    return questionsForId(idForType(surveyType));
  }

  static List<SurveyQuestion> questionsForId(int surveyId) {
    switch (surveyId) {
      case bai:
        return BAIQuestions.questions;
      case gds:
        return GDSQuestions.questions;
      case lawton:
        return LawtonQuestions.questions;
      case katz:
        return KatzQuestions.questions;
      case iciqSf:
        return IciqSfQuestions.questions;
      case osteoporosis:
        return OsteoporosisQuestions.questions;
      case ghq12:
        return Ghq12Questions.questions;
      case phq9:
        return Phq9Questions.questions;
      case sociodemographic:
        return SociodemographicQuestions.questions;
      case socialDeterminants:
        return SocialDeterminantsQuestions.questions;
      case specialtyConsultationAttendance:
        return SpecialtyConsultationAttendanceQuestions.questions;
      case perceivedAttendanceBarriers:
        return PerceivedAttendanceBarriersQuestions.questions;
      case whoqol:
      case sf36:
      case assist:
      case bdi:
      default:
        return BDIQuestions.questions;
    }
  }
}
