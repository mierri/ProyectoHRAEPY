import 'package:flutter_test/flutter_test.dart';
import 'package:ssapp/models/iciq_sf_questions.dart';

void main() {
  group('IciqSfQuestions.evaluate', () {
    test('returns score 0 when no incontinence', () {
      final result = IciqSfQuestions.evaluate({
        1: 0,
        2: 0,
        3: 0,
        4: IciqSfQuestions.encodeSituationsToMask({
          IciqSfLeakSituation.nuncaPierdeOrina,
        }),
      });

      expect(result.score, 0);
      expect(result.tieneIncontinencia, false);
      expect(result.severidad, 'sin incontinencia');
      expect(result.interpretacion, 'Sin evidencia de incontinencia urinaria segun ICIQ-SF.');
    });

    test('returns severe impact for high score', () {
      final result = IciqSfQuestions.evaluate({
        1: 5,
        2: 6,
        3: 8,
        4: IciqSfQuestions.encodeSituationsToMask({
          IciqSfLeakSituation.antesDeLlegarAlBano,
          IciqSfLeakSituation.alToserOEstornudar,
        }),
      });

      expect(result.score, greaterThanOrEqualTo(18));
      expect(result.tieneIncontinencia, true);
      expect(result.severidad, 'severo');
      expect(result.orientacionTipo, contains('Mixta'));
    });
  });
}
