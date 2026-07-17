import 'package:flutter/material.dart' as material show Icons;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/patients/presentation/components/patient_survey_item.dart';
import 'package:ssapp/features/patients/presentation/patient_utils.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/utils/theme.dart';

class PatientDetailsDialog extends StatelessWidget {
  final PatientModel patient;

  const PatientDetailsDialog({super.key, required this.patient});

  /// Diálogo modal simple (título + mensaje + botón "Entendido").
  /// Se usa en vez de un toast porque un toast disparado mientras este
  /// mismo diálogo sigue abierto queda pintado detrás de él (misma capa
  /// base que el fondo de la app) y resulta invisible para el usuario.
  Future<void> _showInfoDialog(
      BuildContext context, {required String title, required String message}) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePatient(
      BuildContext context, List<Map<String, dynamic>> surveys) async {
    if (surveys.isNotEmpty) {
      await _showInfoDialog(
        context,
        title: 'No se puede eliminar',
        message: 'Este paciente tiene encuestas registradas. Elimínalas primero desde el historial.',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar paciente'),
        content: Text('¿Eliminar a "${patient.name}"? Esta acción no se puede deshacer.'),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await context.read<PatientService>().deletePatient(patient.patientId);
      if (!context.mounted) return;

      // No mostramos el toast aquí: justo después de pop(), este context
      // está siendo removido del árbol y showToast() falla al buscar su
      // ToastLayer ancestro. En vez de eso, devolvemos `true` y dejamos que
      // el llamador (con un context estable) muestre la confirmación.
      Navigator.of(context).pop(true);
    } on PatientHasSurveysException {
      if (context.mounted) {
        await _showInfoDialog(
          context,
          title: 'No se puede eliminar',
          message: 'Este paciente tiene encuestas registradas. Elimínalas primero.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        await _showInfoDialog(
          context,
          title: 'No se pudo eliminar',
          message: 'Ocurrió un error al eliminar el paciente: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final patientSurveys = surveyService.surveys
        .where((s) => s['patient_id'] == patient.patientId)
        .toList()
      ..sort((a, b) => DateTime.parse(b['created_at'] as String)
          .compareTo(DateTime.parse(a['created_at'] as String)));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 620),
        child: SurfaceCard(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _DialogHeader(),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _PersonalInfoCard(patient: patient),
                  const Gap(24),
                  _SurveyHistorySection(
                    patient: patient,
                    surveys: patientSurveys,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ]),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                OutlineButton(
                  onPressed: () => _confirmDeletePatient(context, patientSurveys),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(material.Icons.delete_outline,
                        size: 16, color: LightModeColors.lightError),
                    const Gap(6),
                    Text('Eliminar paciente',
                        style: TextStyle(color: LightModeColors.lightError)),
                  ]),
                ),
                const Spacer(),
                OutlineButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(children: [
        Icon(material.Icons.person, color: LightModeColors.lightPrimary),
        const Gap(12),
        const Expanded(
          child: Text('Detalles del Paciente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  final PatientModel patient;
  const _PersonalInfoCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Información Personal').semiBold().large(),
          const Gap(16),
          _InfoRow(icon: material.Icons.person, label: 'Nombre', value: patient.name),
          const Gap(12),
          _InfoRow(icon: material.Icons.cake, label: 'Edad', value: '${patient.age} años'),
          const Gap(12),
          _InfoRow(
            icon: material.Icons.calendar_today,
            label: 'Fecha de nacimiento',
            value: DateFormat('dd/MM/yyyy').format(patient.birthDate),
          ),
          const Gap(12),
          _InfoRow(icon: material.Icons.wc, label: 'Sexo', value: genderLabel(patient.gender)),
          const Gap(12),
          _InfoRow(
            icon: material.Icons.fingerprint,
            label: 'ID del Paciente',
            value: patient.patientId.toString(),
          ),
          const Gap(12),
          _InfoRow(
            icon: material.Icons.cloud_sync,
            label: 'Sincronización',
            value: patient.synced ? 'Sincronizado' : 'Pendiente',
            valueColor:
                patient.synced ? LightModeColors.lightTertiary : LightModeColors.lightError,
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.mutedForeground),
      const Gap(12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label).muted().small(),
          const Gap(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Theme.of(context).colorScheme.foreground,
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _SurveyHistorySection extends StatelessWidget {
  final PatientModel patient;
  final List<Map<String, dynamic>> surveys;
  final VoidCallback onClose;

  const _SurveyHistorySection({
    required this.patient,
    required this.surveys,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Historial de Encuestas').semiBold().large(),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${surveys.length}',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: LightModeColors.lightPrimary),
          ),
        ),
      ]),
      const Gap(16),
      if (surveys.isEmpty)
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(children: [
                Icon(material.Icons.assignment_outlined,
                    size: 48, color: Theme.of(context).colorScheme.mutedForeground),
                const Gap(12),
                const Text('No hay encuestas registradas').muted(),
              ]),
            ),
          ),
        )
      else
        ...surveys.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PatientSurveyItem(survey: s, onClose: onClose),
            )),
    ]);
  }
}
