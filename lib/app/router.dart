import 'package:go_router/go_router.dart';
import 'package:ssapp/features/surveys/presentation/assist_screen.dart';
import 'package:ssapp/features/surveys/presentation/consent_form_screen.dart';
import 'package:ssapp/features/dashboard/dashboard_screen.dart';
import 'package:ssapp/features/surveys/presentation/moca_test_screen.dart';
import 'package:ssapp/features/patients/presentation/patients_screen.dart';
import 'package:ssapp/shared/widgets/placeholder_screen.dart';
import 'package:ssapp/features/reports/presentation/reports_screen.dart';
import 'package:ssapp/features/settings/settings_screen.dart';
import 'package:ssapp/features/surveys/presentation/sf36_screen.dart';
import 'package:ssapp/features/surveys/presentation/survey_results_screen.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen.dart';
import 'package:ssapp/features/surveys/presentation/surveys_list_screen.dart';
import 'package:ssapp/features/surveys/presentation/survey_type_selection_screen.dart';
import 'package:ssapp/features/surveys/presentation/whoqol_screen.dart';

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

        return SurveyScreen(
          patientId: patientId,
          surveyType: surveyType,
        );
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
      path: '/patients',
      builder: (context, state) => const PatientsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
