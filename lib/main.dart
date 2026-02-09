import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/screens/consent_form_screen.dart';
import 'package:ssapp/screens/dashboard_screen.dart';
import 'package:ssapp/screens/placeholder_screen.dart';
import 'package:ssapp/screens/survey_type_selection_screen.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ResponseModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
  Hive.registerAdapter(GenderAdapter());
  Hive.registerAdapter(PatientModelAdapter());

  runApp(const MyApp());
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
      child: MaterialApp.router(
        title: 'HRAEPY - Sistema de Evaluación',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
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
    // Survey screen - placeholder for now
    GoRoute(
      path: '/survey/:patientId',
      builder: (context, state) {
        final patientId = state.pathParameters['patientId'];
        final surveyType = state.uri.queryParameters['surveyType'] ?? 'bdi';
        return PlaceholderScreen(
          title: 'Encuesta ${surveyType.toUpperCase()}',
          message: 'Aquí se mostrará la encuesta para el paciente $patientId',
        );
      },
    ),
    GoRoute(
      path: '/surveys',
      builder: (context, state) => const PlaceholderScreen(
        title: 'Ver Encuestas',
        message: 'Aquí verás el historial de encuestas aplicadas',
      ),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const PlaceholderScreen(
        title: 'Reportes',
        message: 'Aquí verás estadísticas y análisis de las encuestas',
      ),
    ),
    GoRoute(
      path: '/patients',
      builder: (context, state) => const PlaceholderScreen(
        title: 'Pacientes',
        message: 'Aquí podrás gestionar la información de los pacientes',
      ),
    ),
  ],
);




