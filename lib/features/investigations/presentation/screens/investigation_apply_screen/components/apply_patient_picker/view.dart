import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class ApplyPatientPicker extends StatelessWidget {
  final List<PatientModel> patients;
  final int? selectedPatientId;
  final ValueChanged<int> onSelected;

  const ApplyPatientPicker({
    super.key,
    required this.patients,
    required this.selectedPatientId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return const Text('No hay participantes disponibles para aplicar encuestas.').small().muted();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final patient in patients)
          GestureDetector(
            onTap: () => onSelected(patient.patientId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selectedPatientId == patient.patientId
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                    : Theme.of(context).colorScheme.muted,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selectedPatientId == patient.patientId
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.border,
                ),
              ),
              child: Text(patient.name).small().semiBold(),
            ),
          ),
      ],
    );
  }
}


