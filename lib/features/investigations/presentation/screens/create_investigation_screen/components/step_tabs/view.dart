import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/presentation/screens/create_investigation_screen/create_flow_step.dart';
import 'package:ssapp/features/investigations/presentation/screens/create_investigation_screen/components/step_tabs/widgets/widgets.dart';

class CreateStepTabs extends StatelessWidget {
  final List<CreateFlowStep> steps;
  final CreateFlowStep currentStep;
  final ValueChanged<CreateFlowStep> onSelectStep;

  const CreateStepTabs({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onSelectStep,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = steps.indexOf(currentStep);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < steps.length; index++)
          StepChip(
            icon: steps[index].icon,
            label: steps[index].label,
            selected: steps[index] == currentStep,
            completed: index < currentIndex,
            onTap: () {
              if (index <= currentIndex) onSelectStep(steps[index]);
            },
          ),
      ],
    );
  }
}

