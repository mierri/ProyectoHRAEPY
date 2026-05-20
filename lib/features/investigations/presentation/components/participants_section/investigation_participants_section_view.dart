import 'package:flutter/material.dart' as material show Icons;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/widgets/section_empty_state.dart';

class InvestigationParticipantsSection extends StatelessWidget {
  final InvestigationModel investigation;
  final Map<int, PatientModel> patientsById;

  const InvestigationParticipantsSection({
    super.key,
    required this.investigation,
    required this.patientsById,
  });

  Future<void> _confirmAndRemove(
    BuildContext context,
    PatientModel patient,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar participante'),
        content: Text(
          '¿Seguro que deseas eliminar a ${patient.name} de esta investigación?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<InvestigationService>().unlinkParticipant(
            investigationId: investigation.id,
            patientId: patient.patientId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (investigation.participantIds.isEmpty) {
      return const SectionEmptyState(
        icon: material.Icons.group_off,
        title: 'Sin participantes inscritos',
        subtitle: 'Cuando vincules pacientes apareceran en este panel.',
      );
    }

    final participants = investigation.participantIds
        .map((id) => patientsById[id])
        .whereType<PatientModel>()
        .toList();

    if (participants.isEmpty) {
      return const SectionEmptyState(
        icon: material.Icons.person_search,
        title: 'No encontramos los datos locales',
        subtitle: 'Sincroniza pacientes para mostrar sus datos completos.',
      );
    }

    return Column(
      children: [
        for (final patient in participants)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedContainer(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.muted,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      material.Icons.person,
                      size: 18,
                      color: Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.name).semiBold(),
                        const Gap(2),
                        Text('ID ${patient.patientId} - ${patient.age} anos')
                            .small()
                            .muted(),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: patient.synced
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      patient.synced ? 'Sync' : 'Pendiente',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: patient.synced
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  const Gap(8),
                  IconButton(
                    onPressed: () => _confirmAndRemove(context, patient),
                    icon: const Icon(
                      material.Icons.delete_outline,
                      size: 18,
                    ),
                    variance: ButtonVariance.ghost,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

