import 'package:flutter/material.dart' as material show Icons;
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class PatientInfoCard extends StatelessWidget {
  final String patientName;
  final DateTime createdAt;

  const PatientInfoCard({super.key, required this.patientName, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(material.Icons.person, color: LightModeColors.lightPrimary, size: 28),
          ),
          const Gap(16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Paciente').muted().small(),
            const Gap(4),
            Text(patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Gap(4),
            Text('Evaluado el ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}').muted().small(),
          ])),
        ]),
      ),
    );
  }
}
