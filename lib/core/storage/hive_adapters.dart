import 'package:hive_flutter/hive_flutter.dart';
import 'package:ssapp/features/survey_builder/data/custom_survey_model.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/models/response_model.dart';
import 'package:ssapp/shared/models/survey_model.dart';

/// Punto unico para registrar adapters de Hive.
Future<void> registerHiveAdapters() async {
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ResponseModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SurveyModelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(PatientModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(CustomSurveyModelAdapter());
  }
}
