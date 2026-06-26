import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/data/custom_survey_repository.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_service.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

Color _parseColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

class CustomSurveysListScreen extends StatefulWidget {
  const CustomSurveysListScreen({super.key});

  @override
  State<CustomSurveysListScreen> createState() => _CustomSurveysListScreenState();
}

class _CustomSurveysListScreenState extends State<CustomSurveysListScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await context.read<CustomSurveyService>().loadAll();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _confirmDelete(CustomSurveyDefinition definition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar encuesta'),
        content: Text('Eliminar "${definition.title}"? Esta accion no se puede deshacer.'),
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

    if (confirmed == true) {
      try {
        await context.read<CustomSurveyService>().delete(definition.id);
      } on CustomSurveyInUseException {
        if (mounted) {
          showCenteredToast(
            context,
            title: 'No se puede eliminar',
            subtitle: 'Esta encuesta ya tiene respuestas registradas. Desactvala en su lugar.',
            icon: material.Icons.block,
            iconColor: Colors.red,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surveys = context.watch<CustomSurveyService>().surveys;
    final activeCount = surveys.where((survey) => survey.active).length;
    final totalQuestions = surveys.fold<int>(0, (sum, survey) => sum + survey.questions.length);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Mis encuestas'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => context.pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: [
            PrimaryButton(
              onPressed: () => context.push('/survey-builder/new'),
              child: const Text('Nueva encuesta'),
            ),
          ],
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _BuilderHeroCard(
                  totalSurveys: surveys.length,
                  activeSurveys: activeCount,
                  totalQuestions: totalQuestions,
                ),
                const Gap(20),
                if (surveys.isEmpty)
                  const _EmptyState()
                else
                  ...surveys.map(
                    (survey) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CustomSurveyCard(
                        definition: survey,
                        onToggleActive: () =>
                            context.read<CustomSurveyService>().toggleActive(survey.id),
                        onDelete: () => _confirmDelete(survey),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _BuilderHeroCard extends StatelessWidget {
  final int totalSurveys;
  final int activeSurveys;
  final int totalQuestions;

  const _BuilderHeroCard({
    required this.totalSurveys,
    required this.activeSurveys,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LightModeColors.lightTertiary.withValues(alpha: 0.18),
            Theme.of(context).colorScheme.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: LightModeColors.lightTertiary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Creador de encuestas personalizadas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          Text(
            'Diseña instrumentos propios, actívalos cuando estén listos y ajústalos sin perder visibilidad del contenido.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const Gap(18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryPill(label: 'Encuestas', value: '$totalSurveys'),
              _SummaryPill(label: 'Activas', value: '$activeSurveys'),
              _SummaryPill(label: 'Preguntas totales', value: '$totalQuestions'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomSurveyCard extends StatelessWidget {
  final CustomSurveyDefinition definition;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _CustomSurveyCard({
    required this.definition,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(definition.colorHex);

    return OutlinedContainer(
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(material.Icons.assignment_outlined, color: color, size: 28),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      definition.title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const Gap(6),
                    Text(
                      definition.description.isEmpty
                          ? 'Sin descripcion.'
                          : definition.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                    const Gap(10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SurveyBadge(
                          label: '${definition.questions.length} pregunta${definition.questions.length == 1 ? '' : 's'}',
                          color: color,
                        ),
                        _SurveyBadge(
                          label: '${definition.levels.length} nivel${definition.levels.length == 1 ? '' : 'es'}',
                          color: const Color(0xFF7C3AED),
                        ),
                        _SurveyBadge(
                          label: definition.active ? 'Activa' : 'Inactiva',
                          color: definition.active
                              ? const Color(0xFF15803D)
                              : const Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  onPressed: () => context.push('/survey-builder/${definition.id}/edit'),
                  child: const Text('Editar'),
                ),
              ),
              const Gap(8),
              Expanded(
                child: OutlineButton(
                  onPressed: onToggleActive,
                  child: Text(definition.active ? 'Desactivar' : 'Activar'),
                ),
              ),
              const Gap(8),
              IconButton(
                icon: const Icon(material.Icons.delete_outline),
                variance: ButtonVariance.ghost,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          Text(label).muted().small(),
        ],
      ),
    );
  }
}

class _SurveyBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SurveyBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            material.Icons.assignment_outlined,
            size: 54,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(14),
          const Text(
            'Todavía no has creado encuestas personalizadas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          Text(
            'Crea tu primer instrumento para capturar información que no exista en los formularios base.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const Gap(18),
          PrimaryButton(
            onPressed: () => context.push('/survey-builder/new'),
            child: const Text('Crear primera encuesta'),
          ),
        ],
      ),
    );
  }
}
