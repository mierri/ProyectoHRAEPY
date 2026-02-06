import 'package:http/http.dart' as http;
import 'package:ssapp/models/survey_model.dart';
import 'dart:convert';

class SurveyService {
  static const String baseUrl = 'https://api.example.com/surveys';

  Future<bool> syncSurvey(SurveyModel survey) async{
    try{
      final body = {
        'surveyId': survey.surveyId,
        'responses': survey.responses.map((r) => {
          'questionId': r.questionId,
          'answerValue': r.answerValue,
        }).toList(),
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; //Sincro exitosa
      } else {
        return false; //Sincronización fallida
      }
    } catch (e) {
      return false;
    }
  }
}