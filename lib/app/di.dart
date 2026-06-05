import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:ssapp/features/auth/provider/auth_service.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/shared/providers/font_size_provider.dart';
import 'package:ssapp/shared/services/tts/tts_provider.dart';

/// Registro central de dependencias para la app.
class AppDi {
  static List<SingleChildWidget> providers() {
    return [
      ChangeNotifierProvider(create: (_) => AuthService()),
      ChangeNotifierProvider(create: (_) => PatientService()),
      ChangeNotifierProvider(create: (_) => SurveyService()),
      ChangeNotifierProvider(create: (_) => InvestigationService()),
      ChangeNotifierProvider(create: (_) => TtsProvider()),
      ChangeNotifierProvider(create: (_) => FontSizeProvider()),
    ];
  }
}
