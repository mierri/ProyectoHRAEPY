import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ssapp/app/app.dart';
import 'package:ssapp/core/supabase/supabase_config.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';

export 'package:ssapp/app/app.dart' show MyApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(ResponseModelAdapter());
  Hive.registerAdapter(SurveyModelAdapter());
  Hive.registerAdapter(PatientModelAdapter());
  Hive.registerAdapter(InvestigationModelAdapter());
  runApp(const MyApp());
}
