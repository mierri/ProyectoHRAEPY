import 'package:flutter/foundation.dart';
import 'package:ssapp/models/response_model.dart';

// Responsabilidad: centralizar estado de guardado y utilidades compartidas para controladores de encuestas.
abstract class BaseSurveyController extends ChangeNotifier {
  bool _isSaving = false;

  bool get isSaving => _isSaving;

  @protected
  List<ResponseModel> buildResponseModels(Map<int, int> responses) {
    return _buildResponseModels(responses);
  }

  List<ResponseModel> _buildResponseModels(Map<int, int> responses) {
    return responses.entries
        .map(
          (entry) => ResponseModel(
            questionId: entry.key,
            answerValue: entry.value,
          ),
        )
        .toList();
  }

  @protected
  Future<T> executeWithSavingState<T>({
    required T alreadySavingResult,
    required Future<T> Function() action,
    required T Function(Object error, StackTrace stackTrace) onError,
    String operation = 'save survey',
  }) async {
    if (_isSaving) {
      return alreadySavingResult;
    }

    _isSaving = true;
    notifyListeners();

    try {
      return await action();
    } catch (error, stackTrace) {
      logControllerError(operation, error, stackTrace);
      return onError(error, stackTrace);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @protected
  void logControllerError(String operation, Object error, StackTrace stackTrace) {
    debugPrint('Error in $runtimeType during $operation: $error');
    debugPrint(stackTrace.toString());
  }

  Future<dynamic> saveSurvey();
}
