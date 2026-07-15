import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';
import 'package:ssapp/features/surveys/types/bai/domain/bai_survey_handler.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_survey_handler.dart';
import 'package:ssapp/features/surveys/types/gds/domain/gds_survey_handler.dart';
import 'package:ssapp/features/surveys/types/ghq12/domain/ghq12_survey_handler.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/domain/iciq_sf_survey_handler.dart';
import 'package:ssapp/features/surveys/types/katz/domain/katz_survey_handler.dart';
import 'package:ssapp/features/surveys/types/lawton/domain/lawton_survey_handler.dart';
import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_survey_handler.dart';
import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_survey_handler.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/osteoporosis_survey_handler.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_survey_handler.dart';
import 'package:ssapp/features/surveys/types/phq9/domain/phq9_survey_handler.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_survey_handler.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_survey_handler.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_survey_handler.dart';
import 'package:ssapp/features/surveys/types/custom/domain/custom_survey_handler.dart';
import 'package:ssapp/features/surveys/types/fantastic_mexa/domain/fantastic_mexa_survey_handler.dart';

class SurveyTypeHandlerRegistry {
  SurveyTypeHandlerRegistry._();

  static const SurveyTypeHandler _defaultHandler = BdiSurveyHandler();

  static const Map<String, SurveyTypeHandler> _handlersByType = {
    'bdi': BdiSurveyHandler(),
    'bai': BaiSurveyHandler(),
    'gds': GdsSurveyHandler(),
    'lawton': LawtonSurveyHandler(),
    'katz': KatzSurveyHandler(),
    'iciqsf': IciqSfSurveyHandler(),
    'osteoporosis': OsteoporosisSurveyHandler(),
    'ghq12': Ghq12SurveyHandler(),
    'phq9': Phq9SurveyHandler(),
    'sociodemographic': SociodemographicSurveyHandler(),
    'social_determinants': SocialDeterminantsSurveyHandler(),
    'specialty_consultation_attendance': SpecialtyConsultationAttendanceSurveyHandler(),
    'perceived_attendance_barriers': PerceivedAttendanceBarriersSurveyHandler(),
    'moca_basic': MocaBasicSurveyHandler(),
    'moca_blind': MocaBlindSurveyHandler(),
    'fantastic_mexa': FantasticMexaSurveyHandler(),
    'custom': CustomSurveyHandler(),
  };

  static SurveyTypeHandler resolve(String surveyType) {
    return _handlersByType[surveyType.toLowerCase()] ?? _defaultHandler;
  }
}
