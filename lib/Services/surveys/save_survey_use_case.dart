import 'package:ssapp/Services/surveys/survey_repository.dart';
import 'package:ssapp/models/survey_model.dart';

class SaveSurveyUseCase {
  final SurveyRepositoryContract _repository;

  SaveSurveyUseCase(this._repository);

  Future<SaveSurveyResult> execute(
    SurveyModel survey, {
    Duration syncTimeout = const Duration(seconds: 40),
  }) async {
    await _repository.saveSurveyLocally(survey);

    bool wasSynced = false;
    try {
      wasSynced = await _repository
          .syncSurveyToSupabase(survey)
          .timeout(syncTimeout, onTimeout: () => false);

      if (wasSynced) {
        survey.synced = true;
        await survey.save();
      }
    } catch (_) {
      wasSynced = false;
    }

    return SaveSurveyResult(wasSynced: wasSynced);
  }
}

class SaveSurveyResult {
  final bool wasSynced;

  const SaveSurveyResult({required this.wasSynced});
}
