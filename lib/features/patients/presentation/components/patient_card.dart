import 'package:flutter/material.dart' as material show Icons;
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/presentation/components/patient_details_dialog.dart';
import 'package:ssapp/features/patients/presentation/patient_utils.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/utils/theme.dart';

class PatientCard extends StatelessWidget {
  final PatientModel patient;
  /// Conteo pre-calculado en la pantalla padre (evita O(N×M) por card).
  final int surveyCount;

  const PatientCard({super.key, required this.patient, required this.surveyCount});

  @override
  Widget build(BuildContext context) {
    final count = surveyCount;
    final color = genderColor(patient.gender);

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => PatientDetailsDialog(patient: patient),
      ),
      child: OutlinedContainer(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _GenderAvatar(gender: patient.gender, color: color),
            const Gap(16),
            Expanded(child: _PatientInfo(patient: patient, color: color)),
          ]),
          const Gap(16),
          const Divider(),
          const Gap(16),
          Row(children: [
            Expanded(
              child: _InfoChip(
                icon: material.Icons.assignment,
                label: '$count encuesta${count != 1 ? 's' : ''}',
                color: LightModeColors.lightPrimary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _InfoChip(
                icon: material.Icons.calendar_today,
                label: 'ID: ${patient.patientId}',
                color: LightModeColors.lightSecondary,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _GenderAvatar extends StatelessWidget {
  final String gender;
  final Color color;
  const _GenderAvatar({required this.gender, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(genderIcon(gender), color: color, size: 28),
    );
  }
}

class _PatientInfo extends StatelessWidget {
  static final _dateFmt = DateFormat('dd/MM/yyyy');

  final PatientModel patient;
  final Color color;
  const _PatientInfo({required this.patient, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(
            patient.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!patient.synced) _UnsyncedBadge(),
      ]),
      const Gap(6),
      Wrap(spacing: 0, runSpacing: 2, children: [
        Text('${patient.age} años').muted().small(),
        Text(' • ').muted().small(),
        Text(genderLabel(patient.gender)).muted().small(),
        Text(' • ').muted().small(),
        Text(_dateFmt.format(patient.birthDate)).muted().small(),
      ]),
    ]);
  }
}

class _UnsyncedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: LightModeColors.lightError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(material.Icons.cloud_off, size: 12, color: LightModeColors.lightError),
        const Gap(4),
        Text('Sin sincronizar',
            style: TextStyle(
                fontSize: 11, color: LightModeColors.lightError, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: color),
      const Gap(6),
      Flexible(
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.foreground),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }
}
