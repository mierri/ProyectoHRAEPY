import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Question header card showing category + context subtitle + question number circle.
class SurveyQuestionCard extends StatelessWidget {
  final String category;
  final String surveyType;
  final int questionIndex;
  final Color surveyColor;

  const SurveyQuestionCard({
    super.key,
    required this.category,
    required this.surveyType,
    required this.questionIndex,
    required this.surveyColor,
  });

  String get _contextLabel => switch (surveyType) {
        'bai'     => 'Durante la última semana',
        'gds'     => 'Responda según su situación actual',
        'ghq12'   => 'Durante las ultimas dos semanas',
        'phq9'    => 'Frecuencia de sintomas en las ultimas dos semanas',
        'lawton'  => 'Responda según su capacidad actual',
        'katz'    => 'Responda según su nivel de independencia actual',
        'iciqsf'  => 'Responda según su situación urinaria actual',
        _         => 'Últimas dos semanas incluyendo hoy',
      };

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      backgroundColor: surveyColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: surveyColor, shape: BoxShape.circle),
          child: Center(
            child: Text(
              '${questionIndex + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Gap(16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(category, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: surveyColor.withValues(alpha: 0.9))),
          const Gap(4),
          Text(_contextLabel, style: TextStyle(fontSize: 13, color: surveyColor.withValues(alpha: 0.7))),
        ])),
      ]),
    );
  }
}

/// Bottom navigation bar with Previous / Next / Finalizar buttons.
class SurveyNavBar extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLastQuestion;
  final bool isSaving;
  final Color surveyColor;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  // ignore: avoid_positional_boolean_parameters
  const SurveyNavBar({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isLastQuestion,
    required this.isSaving,
    required this.surveyColor,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        if (canGoPrevious) ...[
          Expanded(
            child: OutlineButton(
              onPressed: onPrevious,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.arrow_back, color: surveyColor, size: 20),
                const Gap(8),
                Text('Anterior', style: TextStyle(color: surveyColor)),
              ]),
            ),
          ),
          const Gap(12),
        ],
        Expanded(
          child: PrimaryButton(
            onPressed: (canGoNext && !isSaving) ? onNext : null,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (isSaving) ...[
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                const Gap(8),
              ],
              Text(isSaving ? 'Guardando...' : (isLastQuestion ? 'Finalizar' : 'Siguiente')),
              if (!isSaving) ...[
                const Gap(8),
                Icon(isLastQuestion ? Icons.check : Icons.arrow_forward, size: 20),
              ],
            ]),
          ),
        ),
      ]),
    );
  }
}
