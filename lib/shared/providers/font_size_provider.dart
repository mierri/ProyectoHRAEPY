import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  static const double _min = 0.85;
  static const double _max = 1.75;
  static const double _step = 0.15;

  double _multiplier = 1.0;

  double get multiplier => _multiplier;
  bool get canDecrease => _multiplier > _min + 0.001;
  bool get canIncrease => _multiplier < _max - 0.001;

  void decrease() {
    if (canDecrease) {
      _multiplier = (_multiplier - _step).clamp(_min, _max);
      notifyListeners();
    }
  }

  void increase() {
    if (canIncrease) {
      _multiplier = (_multiplier + _step).clamp(_min, _max);
      notifyListeners();
    }
  }

  double scaled(double base) => base * _multiplier;
}
