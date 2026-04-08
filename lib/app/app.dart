import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/app/router.dart';

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
        title: 'Sistema de Evaluación',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
