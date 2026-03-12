import 'package:flutter/material.dart';
import 'package:ssapp/models/moca_questions.dart';

/// Controller for MoCA Test logic
/// Handles responses, section navigation, and score calculations
class MocaController extends ChangeNotifier {
  final int patientId;

  int _currentSectionIndex = 0;
  final Map<String, dynamic> _results = {};
  bool _isLoading = false;

  MocaController({required this.patientId});

  // Getters
  int get currentSectionIndex => _currentSectionIndex;
  Map<String, dynamic> get results => Map.unmodifiable(_results);
  bool get isLoading => _isLoading;
  
  List<MocaSection> get sections => MocaTest.sections;
  MocaSection get currentSection => sections[_currentSectionIndex];
  double get progress => (_currentSectionIndex + 1) / sections.length;
  bool get canGoNext => _currentSectionIndex < sections.length - 1;
  bool get canGoPrevious => _currentSectionIndex > 0;
  bool get isLastSection => _currentSectionIndex >= sections.length - 1;

  /// Set result for a specific key
  void setResult(String key, dynamic value) {
    _results[key] = value;
    notifyListeners();
  }

  /// Get result for a specific key
  dynamic getResult(String key) {
    return _results[key];
  }

  /// Navigate to next section
  bool nextSection() {
    if (_currentSectionIndex < sections.length - 1) {
      _currentSectionIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Navigate to previous section
  bool previousSection() {
    if (_currentSectionIndex > 0) {
      _currentSectionIndex--;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Go to specific section by index
  void goToSection(int index) {
    if (index >= 0 && index < sections.length) {
      _currentSectionIndex = index;
      notifyListeners();
    }
  }

  /// Calculate total MoCA score
  int calculateTotalScore() {
    int score = 0;
    
    for (var entry in _results.entries) {
      if (entry.value is int) {
        score += entry.value as int;
      } else if (entry.value is bool && entry.value == true) {
        score += 1;
      }
    }
    
    return score;
  }

  /// Get score interpretation
  String interpretScore(int score) {
    return MocaTest.interpretScore(score);
  }

  /// Get score description
  String getScoreDescription(int score) {
    return MocaTest.getScoreDescription(score);
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Clear all results
  void clearResults() {
    _results.clear();
    _currentSectionIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
