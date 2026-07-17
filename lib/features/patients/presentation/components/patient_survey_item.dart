import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/presentation/patient_utils.dart';
import 'package:ssapp/features/surveys/domain/survey_catalog.dart';
import 'package:ssapp/features/surveys/domain/survey_rules.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/shared/utils/theme.dart';

class PatientSurveyItem extends StatelessWidget {
  final Map<String, dynamic> survey;
  final VoidCallback onClose;

  const PatientSurveyItem({super.key, required this.survey, required this.onClose});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar encuesta'),
        content: const Text(
            '¿Eliminar esta encuesta contestada? Esta acción no se puede deshacer.'),
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

    // No se muestra un toast de éxito: se dispararía mientras este diálogo
    // (dentro de PatientDetailsDialog) sigue abierto y quedaría pintado
    // detrás de él, invisible. La fila desapareciendo de la lista ya es
    // la confirmación. En caso de error sí usamos un AlertDialog, que se
    // apila como ruta nueva y por eso siempre se ve.
    try {
      await context.read<SurveyService>().deleteSurvey(survey['survey_id'] as int);
    } catch (e) {
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('No se pudo eliminar'),
            content: Text('Ocurrió un error al eliminar la encuesta: $e'),
            actions: [
              PrimaryButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responses = survey['responses'] as List?;
    final isComplete = responses != null && responses.isNotEmpty;
    final score = isComplete ? SurveyRules.calculateScore(survey) : 0;
    final surveyType = survey['survey_type'] as int? ?? 1;
    final createdAt = DateTime.parse(survey['created_at'] as String);
    final isSynced = survey['synced'] == true;
    final name = SurveyCatalog.nameForId(surveyType);

    return GestureDetector(
      onTap: isComplete
          ? () {
              onClose();
              context.push('/survey-result/${survey['survey_id']}');
            }
          : null,
      child: OutlinedContainer(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _StatusIcon(isComplete: isComplete),
            const Gap(16),
            Expanded(child: _SurveyInfo(
              name: name,
              createdAt: createdAt,
              isSynced: isSynced,
              isComplete: isComplete,
              score: score,
              surveyType: surveyType,
              survey: survey,
            )),
            IconButton(
              icon: const Icon(material.Icons.delete_outline),
              variance: ButtonVariance.ghost,
              onPressed: () => _confirmDelete(context),
            ),
            if (isComplete)
              Icon(material.Icons.chevron_right,
                  color: Theme.of(context).colorScheme.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isComplete;
  const _StatusIcon({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final color = isComplete ? LightModeColors.lightTertiary : LightModeColors.lightError;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isComplete ? material.Icons.check_circle : material.Icons.pending,
        color: color,
        size: 20,
      ),
    );
  }
}

class _SurveyInfo extends StatelessWidget {
  final String name;
  final DateTime createdAt;
  final bool isSynced, isComplete;
  final int score, surveyType;
  final Map<String, dynamic> survey;

  const _SurveyInfo({
    required this.name, required this.createdAt, required this.isSynced,
    required this.isComplete, required this.score, required this.surveyType,
    required this.survey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        if (!isSynced) ...[const Gap(8), _UnsyncedBadge()],
      ]),
      const Gap(4),
      Text(DateFormat('dd/MM/yyyy HH:mm').format(createdAt)).muted().small(),
      if (isComplete) ...[
        const Gap(4),
        _scoreWidget(),
      ],
    ]);
  }

  Widget _scoreWidget() {
    if (surveyType == 3) return buildAvgScoreText(survey, const Color(0xFF7C3AED));
    if (surveyType == 5) return buildAvgScoreText(survey, const Color(0xFF06B6D4));
    final level = scoreLevel(score, surveyType);
    if (level.isEmpty) {
      return Text('Encuesta completada',
          style: TextStyle(fontSize: 12, color: scoreLevelColor(0, surveyType), fontWeight: FontWeight.w500));
    }
    return Text('Puntaje: $score — $level',
        style: TextStyle(fontSize: 12, color: scoreLevelColor(score, surveyType), fontWeight: FontWeight.w500));
  }
}

class _UnsyncedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LightModeColors.lightError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(material.Icons.cloud_off, size: 10, color: LightModeColors.lightError),
        const Gap(4),
        Text('Sin sync',
            style: TextStyle(fontSize: 10, color: LightModeColors.lightError, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
