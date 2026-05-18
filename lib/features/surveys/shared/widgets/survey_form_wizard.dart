import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class FormStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<int> requiredIds;

  const FormStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.requiredIds,
  });
}

class FormStepProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const FormStepProgressBar({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      color: LightModeColors.lightSurfaceVariant,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(color: color),
      ),
    );
  }
}

class FormStepPagination extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool Function(int) isStepAnswered;
  final ValueChanged<int> onStepTapped;

  static const _answered = Color(0xFF16A34A);
  static const _unanswered = Color(0xFFDC2626);

  const FormStepPagination({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isStepAnswered,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final answeredCount = List.generate(totalSteps, isStepAnswered).where((v) => v).length;
    final unansweredCount = totalSteps - answeredCount;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: _answered, label: '$answeredCount completas'),
            const Gap(16),
            _LegendDot(color: _unanswered, label: '$unansweredCount pendientes'),
          ],
        ),
        const Gap(10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: List.generate(totalSteps, (i) {
            final answered = isStepAnswered(i);
            final isCurrent = i == currentStep;
            final bgColor = answered ? _answered : _unanswered;

            return GestureDetector(
              onTap: () => onStepTapped(i),
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
                    '${i + 1}',
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
      ],
    );
  }
}

class FormStepNavBar extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final bool isLastStep;
  final bool isSaving;
  final Color color;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const FormStepNavBar({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.isLastStep,
    required this.isSaving,
    required this.color,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canGoPrevious) ...[
            Expanded(
              child: OutlineButton(
                onPressed: onPrevious,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: color, size: 20),
                    const Gap(8),
                    Text('Anterior', style: TextStyle(color: color)),
                  ],
                ),
              ),
            ),
            const Gap(12),
          ],
          Expanded(
            child: PrimaryButton(
              onPressed: (canGoNext && !isSaving) ? onNext : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSaving) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const Gap(8),
                    const Text('Guardando...'),
                  ] else ...[
                    Text(isLastStep ? 'Finalizar' : 'Siguiente'),
                    const Gap(8),
                    Icon(
                      isLastStep ? Icons.check : Icons.arrow_forward,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(5),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
