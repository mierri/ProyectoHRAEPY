import 'package:flutter_test/flutter_test.dart';
import 'package:ssapp/models/katz_questions.dart';

void main() {
  group('KatzQuestions.evaluate', () {
    test('returns total independence for all independent responses', () {
      final result = KatzQuestions.evaluate({
        1: 1,
        2: 1,
        3: 1,
        4: 1,
        5: 1,
        6: 1,
      });

      expect(result.score, 6);
      expect(result.total, 6);
      expect(result.interpretacion, 'Independencia total');
      expect(result.clasificacionKatz, 'A');
      expect(result.toMap()['clasificacion_katz'], 'A');
    });

    test('returns full dependence for all dependent responses', () {
      final result = KatzQuestions.evaluate({
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
        6: 0,
      });

      expect(result.score, 0);
      expect(result.total, 6);
      expect(result.interpretacion, 'Dependencia en algun grado');
      expect(result.clasificacionKatz, 'G');
    });
  });
}
