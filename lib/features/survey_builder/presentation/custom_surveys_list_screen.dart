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

/// Lista de encuestas personalizadas creadas por la doctora.
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
        content: Text('¿Eliminar "${definition.title}"? Esta acción no se puede deshacer.'),
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
            subtitle: 'Esta encuesta ya tiene respuestas registradas. Desactívala en su lugar.',
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
              density: ButtonDensity.icon,
              onPressed: () => context.push('/survey-builder/new'),
              child: const Icon(material.Icons.add),
            ),
          ],
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : surveys.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: surveys.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (_, i) => _CustomSurveyCard(
                    definition: surveys[i],
                    onToggleActive: () =>
                        context.read<CustomSurveyService>().toggleActive(surveys[i].id),
                    onDelete: () => _confirmDelete(surveys[i]),
                  ),
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
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(material.Icons.assignment_outlined, color: color, size: 28),
          ),
          const Gap(16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                definition.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
              Text('${definition.questions.length} pregunta${definition.questions.length != 1 ? 's' : ''}')
                  .muted()
                  .small(),
            ]),
          ),
          if (!definition.active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: LightModeColors.lightOutline.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Inactiva', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ),
        ]),
        const Gap(16),
        const Divider(),
        const Gap(12),
        Row(children: [
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
        ]),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(material.Icons.assignment_outlined,
            size: 80, color: Theme.of(context).colorScheme.mutedForeground),
        const Gap(16),
        Text(
          'No hay encuestas personalizadas',
          style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.mutedForeground),
        ),
        const Gap(8),
        const Text('Crea tu primera encuesta para comenzar').muted().small(),
      ]),
    );
  }
}
