import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
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

    final allSurveys = context.watch<SurveyService>().surveys;
    final totalSurveys = investigation.surveyTypeIds.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final patient in participants)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ParticipantCard(
              patient: patient,
              investigation: investigation,
              allSurveys: allSurveys,
              totalSurveys: totalSurveys,
            ),
          ),
      ],
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  final PatientModel patient;
  final InvestigationModel investigation;
  final List<Map<String, dynamic>> allSurveys;
  final int totalSurveys;

  const _ParticipantCard({
    required this.patient,
    required this.investigation,
    required this.allSurveys,
    required this.totalSurveys,
  });

  int _countCompleted() {
    final completed = <int>{};
    for (final survey in allSurveys) {
      final invId = survey['investigation_id'] as int?;
      final pId = survey['patient_id'] as int?;
      final typeId = survey['survey_type'] as int?;
      if (invId != investigation.id || pId != patient.patientId || typeId == null) continue;
      if (investigation.surveyTypeIds.contains(typeId)) completed.add(typeId);
    }
    return completed.length;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _countCompleted();
    final isComplete = totalSurveys > 0 && completed >= totalSurveys;

    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text('ID ${patient.patientId} - ${patient.age} anos').small().muted(),
                  ],
                ),
              ),
              _StatusBadge(completed: completed, total: totalSurveys, isComplete: isComplete),
            ],
          ),
          if (totalSurveys > 0) ...[
            const Gap(10),
            _ProgressBar(completed: completed, total: totalSurveys),
            const Gap(4),
            Text('$completed/$totalSurveys encuestas completadas').small().muted(),
          ],
          if (!isComplete) ...[
            const Gap(10),
            SizedBox(
              width: double.infinity,
              child: OutlineButton(
                onPressed: () => context.push(
                  '/investigations/${investigation.id}/apply?resumePatientId=${patient.patientId}',
                ),
                leading: const Icon(material.Icons.play_circle_outline, size: 16),
                child: const Text('Retomar investigación'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int completed;
  final int total;
  final bool isComplete;

  const _StatusBadge({
    required this.completed,
    required this.total,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'Completo',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'En curso',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final fillColor = fraction >= 1.0
        ? const Color(0xFF059669)
        : Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                height: 6,
                width: constraints.maxWidth,
                color: Theme.of(context).colorScheme.muted,
              ),
              Container(
                height: 6,
                width: constraints.maxWidth * fraction,
                color: fillColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
