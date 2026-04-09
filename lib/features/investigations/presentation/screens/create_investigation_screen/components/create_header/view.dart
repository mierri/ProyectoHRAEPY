import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/presentation/screens/create_investigation_screen/create_flow_step.dart';

class CreateInvestigationHeader extends StatelessWidget {
  final bool isEditMode;
  final CreateFlowStep currentStep;
  final int currentStepIndex;
  final int totalSteps;
  final VoidCallback onBackStep;

  const CreateInvestigationHeader({
    super.key,
    required this.isEditMode,
    required this.currentStep,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onBackStep,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isEditMode ? 'Editar investigacion' : 'Nueva investigacion').small().muted(),
          Text(currentStep.label).semiBold(),
        ],
      ),
      leading: [
        IconButton(
          icon: const Icon(material.Icons.arrow_back),
          variance: ButtonVariance.ghost,
          onPressed: () {
            if (currentStepIndex > 0) {
              onBackStep();
              return;
            }
            context.pop();
          },
        ),
      ],
      trailing: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.muted,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text('${currentStepIndex + 1}/$totalSteps').small().semiBold(),
        ),
      ],
    );
  }
}

