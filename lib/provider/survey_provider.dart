
import 'package:hive/hive.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/models/response_model.dart';
import 'package:ssapp/models/survey_model.dart';

class SurveyProvider {
  late Box<SurveyModel> box;
  final SurveyService _service = SurveyService();

  Future<bool> initBox() async {
    box = await Hive.openBox<SurveyModel>('surveyBox');
    return box.isOpen;
  }
  Future<bool> addSurvey(SurveyModel survey) async {
    await box.add(survey);
    bool synced = await _service.syncSurveyToSupabase(survey);
    survey.synced = synced;
    await survey.save();
    return true;
  }

  Map<dynamic, dynamic> getAllSurveys() {
    Map<dynamic, dynamic> surveys = box.toMap();
    return surveys;
  }

  List<SurveyModel> getAllSurveysAsList() {
    return box.values.toList();
  }

  SurveyModel? getSurveyByIndex(int index) {
    if (index < 0 || index >= box.length) return null;
    return box.getAt(index);
  }
  Future<bool> deleteSurvey(int index) async {
    await box.deleteAt(index);
    return true;
  }

  Future<bool> updateSurvey(int index, SurveyModel survey) async {
    await box.putAt(index, survey);
    bool synced = await _service.syncSurveyToSupabase(survey);
    survey.synced = synced;
    await survey.save();
    return true;
  }
  
  Future<void> syncPendingSurveys() async {
    var surveys = getAllSurveys();
    for (var entry in surveys.entries) {
      SurveyModel survey = entry.value;
      if (!survey.synced) {
        bool synced = await _service.syncSurveyToSupabase(survey);
        if (synced) {
          survey.synced = true;
          await survey.save();
        }
      }
    }
  }

  Future<void> syncFromSupabase() async {
    try {
      List<Map<String, dynamic>> remoteSurveys = await _service.getAllSurveysFromSupabase();
      
      // Actualizar o agregar encuestas del servidor
      for (var surveyData in remoteSurveys) {
        // Buscar si ya existe localmente por survey_id
        var existingSurvey = box.values.where(
          (s) => s.surveyId == surveyData['survey_id']
        ).firstOrNull;
        
        if (existingSurvey == null) {
          // No existe localmente, crear y agregar
          final responses = (surveyData['responses'] as List? ?? [])
              .map((r) => ResponseModel(
                    questionId: r['question_id'],
                    answerValue: r['answer_value'],
                  ))
              .toList();
          
          final newSurvey = SurveyModel(
            surveyId: surveyData['survey_id'],
            surveyType: surveyData['survey_type'] ?? 1, // 1=BDI por defecto
            patientId: surveyData['patient_id'],
            responses: responses,
            synced: true,
          );
          
          await box.add(newSurvey);
        }
      }
    } catch (e) {
      print('Error al sincronizar desde Supabase: $e');
    }
  }

  Future<void> dispose() async {
    await box.close();
  }
}