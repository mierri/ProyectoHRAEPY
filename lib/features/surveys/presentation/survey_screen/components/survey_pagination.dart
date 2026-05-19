import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';

class SurveyPagination extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final Map<int, int> responses;
  final List<SurveyQuestion> questions;
  final Color surveyColor;
  final ValueChanged<int> onPageChanged;

  static const _answered   = Color(0xFF16A34A);
  static const _unanswered = Color(0xFFDC2626);

  const SurveyPagination({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.responses,
    required this.questions,
    required this.surveyColor,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final answeredCount   = responses.length;
    final unansweredCount = totalQuestions - answeredCount;

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _LegendDot(color: _answered,   label: '$answeredCount respondidas'),
        const Gap(16),
        _LegendDot(color: _unanswered, label: '$unansweredCount sin responder'),
      ]),
      const Gap(10),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: List.generate(totalQuestions, (i) {
          final number    = i + 1;
          final isAnswered = responses.containsKey(number);
          final isCurrent  = i == currentIndex;
          final bgColor    = isAnswered ? _answered : _unanswered;

          return GestureDetector(
            onTap: () => onPageChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCurrent ? bgColor : bgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: bgColor, width: isCurrent ? 2.5 : 1.5),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCurrent ? Colors.white : bgColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const Gap(5),
      Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}
