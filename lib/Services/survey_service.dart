import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ssapp/models/survey_model.dart';
import 'dart:convert';

/// Service to sync surveys with remote API
class SurveyService extends ChangeNotifier {
  static const String baseUrl = 'https://api.example.com/surveys';

  final List<SurveyModel> _surveys = [];

  List<SurveyModel> get surveys => _surveys;

  /// Add survey to local list
  void addSurveyToList(SurveyModel survey) {
    _surveys.add(survey);
    notifyListeners();
  }

  /// Get statistics from surveys
  Map<String, dynamic> getStatistics() {
    int completed = _surveys.where((s) => s.synced).length;
    int incomplete = _surveys.where((s) => !s.synced).length;

    double averageScore = 0.0;
    if (_surveys.isNotEmpty) {
      int totalScore = 0;
      for (var survey in _surveys) {
        for (var response in survey.responses) {
          totalScore += response.answerValue;
        }
      }
      averageScore = totalScore / _surveys.length;
    }

    return {
      'completed': completed,
      'incomplete': incomplete,
      'averageScore': averageScore,
      'total': _surveys.length,
    };
  }

  /// Sync survey with remote API
  Future<bool> syncSurvey(SurveyModel survey) async {
    try {
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
        notifyListeners();
        return true; // Sincronización exitosa
      } else {
        return false; // Sincronización fallida
      }
    } catch (e) {
      return false;
    }
  }
}
