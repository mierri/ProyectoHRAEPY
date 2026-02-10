import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ssapp/config/supabase_config.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';
import 'package:ssapp/provider/survey_provider.dart';
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
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ResponseModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
<<<<<<< HEAD
  Hive.registerAdapter(PatientModelAdapter());
  
=======
  Hive.registerAdapter(GenderAdapter());
  Hive.registerAdapter(PatientModelAdapter());

>>>>>>> 55c5dded7962bacdf9b7b2cc225a602262ea640a
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      title: 'BDI-2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SurveyHomePage(),
=======
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
>>>>>>> 55c5dded7962bacdf9b7b2cc225a602262ea640a
    );
  }
}

<<<<<<< HEAD
class SurveyHomePage extends StatefulWidget {
  const SurveyHomePage({super.key});

  @override
  State<SurveyHomePage> createState() => _SurveyHomePageState();
}

class _SurveyHomePageState extends State<SurveyHomePage> {
  final SurveyProvider _provider = SurveyProvider();
  bool _isLoading = true;
  Map<dynamic, dynamic> _surveys = {};
  
  @override
  void initState() {
    super.initState();
    _initProvider();
  }
  
  Future<void> _initProvider() async {
    await _provider.initBox();
    _loadSurveys();
  }
  
  void _loadSurveys() {
    setState(() {
      _surveys = _provider.getAllSurveys();
      _isLoading = false;
    });
  }
  
  Future<void> _addTestSurvey() async {
    final survey = SurveyModel(
      surveyId: DateTime.now().millisecondsSinceEpoch,
      responses: [
        ResponseModel(questionId: 1, answerValue: 2),
        ResponseModel(questionId: 2, answerValue: 3),
        ResponseModel(questionId: 3, answerValue: 1),
      ],
    );
    
    await _provider.addSurvey(survey);
    _loadSurveys();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encuesta agregada')),
      );
    }
  }
  
  Future<void> _syncAll() async {
    await _provider.syncPendingSurveys();
    _loadSurveys();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronización completada')),
      );
    }
  }
  
  Future<void> _deleteSurvey(int index) async {
    await _provider.deleteSurvey(index);
    _loadSurveys();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encuesta eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BDI-2 - Encuestas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncAll,
            tooltip: 'Sincronizar pendientes',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? const Center(
                  child: Text(
                    'No hay encuestas.\nPresiona + para agregar una de prueba',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _surveys.length,
                  itemBuilder: (context, index) {
                    final entry = _surveys.entries.elementAt(index);
                    final survey = entry.value as SurveyModel;
                    
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Icon(
                          survey.synced ? Icons.cloud_done : Icons.cloud_off,
                          color: survey.synced ? Colors.green : Colors.orange,
                        ),
                        title: Text('Encuesta #${survey.surveyId}'),
                        subtitle: Text(
                          '${survey.responses.length} respuestas\n'
                          'Estado: ${survey.synced ? "Sincronizada" : "Pendiente"}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSurvey(entry.key),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Encuesta #${survey.surveyId}'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Respuestas:'),
                                  const SizedBox(height: 8),
                                  ...survey.responses.map((r) => 
                                    Text('  Pregunta ${r.questionId}: ${r.answerValue}')
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestSurvey,
        tooltip: 'Agregar encuesta de prueba',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }
}
=======
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




>>>>>>> 55c5dded7962bacdf9b7b2cc225a602262ea640a
