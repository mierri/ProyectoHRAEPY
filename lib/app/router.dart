import 'package:go_router/go_router.dart';
import 'package:ssapp/features/surveys/types/assist/presentation/assist_screen.dart';
import 'package:ssapp/features/surveys/types/bai/presentation/bai_screen.dart';
import 'package:ssapp/features/surveys/types/bdi/presentation/bdi_screen.dart';
import 'package:ssapp/features/surveys/presentation/consent_form_screen.dart';
import 'package:ssapp/features/dashboard/dashboard_screen.dart';
import 'package:ssapp/features/investigations/presentation/investigation_detail_screen.dart';
import 'package:ssapp/features/investigations/presentation/investigations_screen.dart';
import 'package:ssapp/features/surveys/types/gds/presentation/gds_screen.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/presentation/iciq_sf_screen.dart';
import 'package:ssapp/features/surveys/types/katz/presentation/katz_screen.dart';
import 'package:ssapp/features/surveys/types/lawton/presentation/lawton_screen.dart';
import 'package:ssapp/features/surveys/types/moca/presentation/moca_test_screen.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/presentation/osteoporosis_screen.dart';
import 'package:ssapp/features/patients/presentation/patients_screen.dart';
import 'package:ssapp/shared/widgets/placeholder_screen.dart';
import 'package:ssapp/features/reports/presentation/reports_screen.dart';
import 'package:ssapp/features/settings/settings_screen.dart';
import 'package:ssapp/features/surveys/types/sf36/presentation/sf36_screen.dart';
import 'package:ssapp/features/surveys/presentation/survey_results_screen.dart';
import 'package:ssapp/features/surveys/presentation/surveys_list_screen.dart';
import 'package:ssapp/features/surveys/presentation/survey_type_selection_screen.dart';
import 'package:ssapp/features/surveys/types/whoqol/presentation/whoqol_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
        return ConsentFormScreen(surveyType: surveyType);
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

        final surveyType = state.uri.queryParameters['surveyType'] ?? 'bdi';

        if (surveyType == 'moca') {
          return MocaTestScreen(patientId: patientId);
        }

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
      path: '/patients',
      builder: (context, state) => const PatientsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
