
import 'package:hive/hive.dart';
import 'package:ssapp/Services/survey_service.dart';

import 'package:ssapp/models/survey_model.dart';

class SurveyProvider {
  late Box<SurveyModel> box;
  final SurveyService _service = SurveyService();

  Future<bool> initBox() async{
    box = await Hive.openBox<SurveyModel>('surveyBox');
    return box.isOpen;
  }
  Future<bool> addSurvey(SurveyModel survey) async{
    await box.add(survey);
    bool synced = await _service.syncSurvey(survey);
    survey.synced = synced;
    await survey.save();
    return true;
  }
  Map<dynamic, dynamic> getAllSurveys(){
    Map<dynamic, dynamic> surveys = box.toMap();
    return surveys;
  }
  Future<bool> deleteSurvey(int index) async{
    await box.deleteAt(index);
    return true;
  }
  Future<bool> updateSurvey(int index, SurveyModel survey) async{
    await box.putAt(index, survey);
    bool synced = await _service.syncSurvey(survey);
    survey.synced = synced;
    await survey.save();
    return true;
  }
  
  Future<void>  syncPendingSurveys() async {
    var surveys = getAllSurveys();
    for(var entry in surveys.entries){
      SurveyModel survey = entry.value;
      if(!survey.synced){
        bool synced = await _service.syncSurvey(survey);
        if(synced){
          survey.synced = true;
          await survey.save();
        }
      }
    }
  }
  
  Future<void> dispose() async{
    await box.close();
  }
}