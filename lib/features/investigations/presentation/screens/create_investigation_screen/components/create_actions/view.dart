import 'package:shadcn_flutter/shadcn_flutter.dart';

class CreateInvestigationActions extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final bool canProceed;
  final bool isSubmitting;
  final bool isEditMode;
  final VoidCallback onCancel;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onSubmit;

  const CreateInvestigationActions({
    super.key,
    required this.isFirstStep,
    required this.isLastStep,
    required this.canProceed,
    required this.isSubmitting,
    required this.isEditMode,
    required this.onCancel,
    required this.onBack,
    required this.onContinue,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isFirstStep)
          OutlineButton(
            onPressed: isSubmitting ? null : onCancel,
            child: const Text('Cancelar'),
          )
        else
          OutlineButton(
            onPressed: isSubmitting ? null : onBack,
            child: const Text('Atras'),
          ),
        const Gap(12),
        Expanded(
          child: PrimaryButton(
            onPressed: (!canProceed || isSubmitting)
                ? null
                : (isLastStep ? onSubmit : onContinue),
            child: Text(isLastStep ? (isEditMode ? 'Guardar cambios' : 'Crear investigacion') : 'Continuar'),
          ),
        ),
      ],
    );
  }
}

