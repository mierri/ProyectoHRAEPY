import 'package:go_router/go_router.dart';
import 'package:ssapp/features/splash/splash_screen.dart';
import 'package:ssapp/features/surveys/types/assist/presentation/assist_screen.dart';
import 'package:ssapp/features/surveys/types/bai/presentation/bai_screen.dart';
import 'package:ssapp/features/surveys/types/bdi/presentation/bdi_screen.dart';
import 'package:ssapp/features/surveys/presentation/consent_form/consent_form_screen.dart';
import 'package:ssapp/features/dashboard/dashboard_screen.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/investigation_apply_screen.dart';
import 'package:ssapp/features/investigations/presentation/screens/create_investigation_screen/create_investigation_screen.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_detail_screen/investigation_detail_screen.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigations_screen/investigations_screen.dart';
import 'package:ssapp/features/surveys/types/gds/presentation/gds_screen.dart';
import 'package:ssapp/features/surveys/types/ghq12/presentation/ghq12_screen.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/presentation/iciq_sf_screen.dart';
import 'package:ssapp/features/surveys/types/katz/presentation/katz_screen.dart';
import 'package:ssapp/features/surveys/types/lawton/presentation/lawton_screen.dart';
import 'package:ssapp/features/surveys/types/moca_basic/presentation/moca_basic_screen.dart';
import 'package:ssapp/features/surveys/types/moca_blind/presentation/moca_blind_screen.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/presentation/osteoporosis_screen.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/presentation/perceived_attendance_barriers_screen.dart';
import 'package:ssapp/features/patients/presentation/screens/patients_screen.dart';
import 'package:ssapp/shared/widgets/placeholder_screen.dart';
import 'package:ssapp/features/reports/presentation/reports_screen.dart';
import 'package:ssapp/features/settings/settings_screen.dart';
import 'package:ssapp/features/surveys/types/sf36/presentation/sf36_screen.dart';
import 'package:ssapp/features/surveys/types/phq9/presentation/phq9_screen.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/presentation/specialty_consultation_attendance_screen.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/presentation/sociodemographic_screen.dart';
import 'package:ssapp/features/surveys/types/social_determinants/presentation/social_determinants_screen.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/survey_results_screen.dart';
import 'package:ssapp/features/surveys/presentation/surveys_list/surveys_list_screen.dart';
import 'package:ssapp/features/surveys/presentation/survey_type_selection/survey_type_selection_screen.dart';
import 'package:ssapp/features/surveys/presentation/dynamic_survey/dynamic_survey_screen.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/features/surveys/types/whoqol/presentation/whoqol_screen.dart';
import 'package:ssapp/features/survey_builder/presentation/custom_surveys_list_screen.dart';
import 'package:ssapp/features/survey_builder/presentation/custom_survey_editor_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/new-survey',
      builder: (context, state) => const SurveyTypeSelectionScreen(),
    ),
    GoRoute(
      path: '/consent-form',
      builder: (context, state) {
        final surveyType = state.uri.queryParameters['surveyType'];
        final customSurveyId = int.tryParse(state.uri.queryParameters['customSurveyId'] ?? '');
        return ConsentFormScreen(surveyType: surveyType, customSurveyId: customSurveyId);
      },
    ),
    GoRoute(
      path: '/survey/:patientId',
      builder: (context, state) {
        final patientIdStr = state.pathParameters['patientId'];
        final patientId = int.tryParse(patientIdStr ?? '');

        if (patientId == null || patientId == 0) {
          return const PlaceholderScreen(
            title: 'Error',
            message: 'ID de paciente inválido. Por favor, intente nuevamente.',
          );
        }

        final surveyType = SurveyTypeConfig.normalizeType(
          state.uri.queryParameters['surveyType'],
        );

        if (surveyType == 'whoqol') {
          return WhoqolScreen(patientId: patientId);
        }

        if (surveyType == 'sf36') {
          return SF36Screen(patientId: patientId);
        }

        if (surveyType == 'assist') {
          return AssistScreen(patientId: patientId);
        }

        if (surveyType == 'bai') {
          return BaiScreen(patientId: patientId);
        }

        if (surveyType == 'gds') {
          return GdsScreen(patientId: patientId);
        }

        if (surveyType == 'ghq12') {
          return Ghq12Screen(patientId: patientId);
        }

        if (surveyType == 'phq9') {
          return Phq9Screen(patientId: patientId);
        }

        if (surveyType == 'sociodemographic') {
          return SociodemographicScreen(patientId: patientId);
        }

        if (surveyType == 'social_determinants') {
          return SocialDeterminantsScreen(patientId: patientId);
        }

        if (surveyType == 'specialty_consultation_attendance') {
          return SpecialtyConsultationAttendanceScreen(patientId: patientId);
        }

        if (surveyType == 'perceived_attendance_barriers') {
          return PerceivedAttendanceBarriersScreen(patientId: patientId);
        }

        if (surveyType == 'moca_basic') {
          return MocaBasicScreen(patientId: patientId);
        }

        if (surveyType == 'moca_blind') {
          return MocaBlindScreen(patientId: patientId);
        }

        if (surveyType == 'lawton') {
          return LawtonScreen(patientId: patientId);
        }

        if (surveyType == 'katz') {
          return KatzScreen(patientId: patientId);
        }

        if (surveyType == 'iciqsf') {
          return IciqSfScreen(patientId: patientId);
        }

        if (surveyType == 'osteoporosis') {
          return OsteoporosisScreen(patientId: patientId);
        }

        if (surveyType == 'custom') {
          final customSurveyId = int.tryParse(state.uri.queryParameters['customSurveyId'] ?? '') ?? 0;
          final fromInvestigation = state.uri.queryParameters['fromInvestigation'];
          return DynamicSurveyScreen(
            patientId: patientId,
            customSurveyId: customSurveyId,
            investigationId: int.tryParse(fromInvestigation ?? ''),
          );
        }

        return BdiScreen(patientId: patientId);
      },
    ),
    GoRoute(
      path: '/surveys',
      builder: (context, state) => const SurveysListScreen(),
    ),
    GoRoute(
      path: '/survey-result/:surveyId',
      builder: (context, state) {
        final surveyIdStr = state.pathParameters['surveyId'];
        final surveyId = int.tryParse(surveyIdStr ?? '');

        if (surveyId == null) {
          return const PlaceholderScreen(
            title: 'Error',
            message: 'ID de encuesta inválido',
          );
        }

        return SurveyResultsScreen(surveyId: surveyId);
      },
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/investigations',
      builder: (context, state) => const InvestigationsScreen(),
    ),
    GoRoute(
      path: '/investigations/new',
      builder: (context, state) => const CreateInvestigationScreen(),
    ),
    GoRoute(
      path: '/investigations/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const PlaceholderScreen(
            title: 'Error',
            message: 'ID de investigacion invalido',
          );
        }
        return InvestigationDetailScreen(investigationId: id);
      },
    ),
    GoRoute(
      path: '/investigations/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const PlaceholderScreen(
            title: 'Error',
            message: 'ID de investigacion invalido',
          );
        }
        return CreateInvestigationScreen(investigationId: id);
      },
    ),
    GoRoute(
      path: '/investigations/:id/apply',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) {
          return const PlaceholderScreen(
            title: 'Error',
            message: 'ID de investigacion invalido',
          );
        }
        return InvestigationApplyScreen(investigationId: id);
      },
    ),
    GoRoute(
      path: '/patients',
      builder: (context, state) => const PatientsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/survey-builder',
      builder: (context, state) => const CustomSurveysListScreen(),
    ),
    GoRoute(
      path: '/survey-builder/new',
      builder: (context, state) => const CustomSurveyEditorScreen(),
    ),
    GoRoute(
      path: '/survey-builder/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return CustomSurveyEditorScreen(customSurveyId: id);
      },
    ),
  ],
);
