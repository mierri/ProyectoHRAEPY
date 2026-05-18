import 'package:ssapp/features/surveys/core/domain/survey_type_handler.dart';
import 'package:ssapp/features/surveys/types/bai/domain/bai_survey_handler.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_survey_handler.dart';
import 'package:ssapp/features/surveys/types/gds/domain/gds_survey_handler.dart';
import 'package:ssapp/features/surveys/types/ghq12/domain/ghq12_survey_handler.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/domain/iciq_sf_survey_handler.dart';
import 'package:ssapp/features/surveys/types/katz/domain/katz_survey_handler.dart';
import 'package:ssapp/features/surveys/types/lawton/domain/lawton_survey_handler.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/osteoporosis_survey_handler.dart';
import 'package:ssapp/features/surveys/types/phq9/domain/phq9_survey_handler.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_survey_handler.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_survey_handler.dart';

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
  };

  static SurveyTypeHandler resolve(String surveyType) {
    return _handlersByType[surveyType.toLowerCase()] ?? _defaultHandler;
  }
}
