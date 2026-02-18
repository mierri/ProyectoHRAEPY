import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/screens/consent_form_screen.dart';
import 'package:ssapp/screens/dashboard_screen.dart';
import 'package:ssapp/screens/patients_screen.dart';
import 'package:ssapp/screens/placeholder_screen.dart';
import 'package:ssapp/screens/reports_screen.dart';
import 'package:ssapp/screens/settings_screen.dart';
import 'package:ssapp/screens/survey_results_screen.dart';
import 'package:ssapp/screens/survey_screen.dart';
import 'package:ssapp/screens/surveys_list_screen.dart';
import 'package:ssapp/screens/survey_type_selection_screen.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ResponseModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
  Hive.registerAdapter(PatientModelAdapter());

  runApp(
      const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SurveyService()),
        ChangeNotifierProvider(create: (_) => PatientService()),
      ],
      child: ShadcnApp.router(
        title: 'HRAEPY - Sistema de Evaluación',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    // Survey type selection screen
    GoRoute(
      path: '/new-survey',
      builder: (context, state) => const SurveyTypeSelectionScreen(),
    ),
    // Consent form screen
    GoRoute(
      path: '/consent-form',
      builder: (context, state) {
        final surveyType = state.uri.queryParameters['surveyType'];
        return ConsentFormScreen(surveyType: surveyType);
      },
    ),
    // Survey screen
    GoRoute(
      path: '/survey/:patientId',
      builder: (context, state) {
        final patientIdStr = state.pathParameters['patientId'];
        final patientId = int.tryParse(patientIdStr ?? '');

        // Validar que el patientId sea válido
        if (patientId == null || patientId == 0) {
          // Si el ID es inválido, redirigir al dashboard
          return const PlaceholderScreen(
            title: 'Error',
            message: 'ID de paciente inválido. Por favor, intente nuevamente.',
          );
        }

        final surveyType = state.uri.queryParameters['surveyType'] ?? 'bdi';
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
