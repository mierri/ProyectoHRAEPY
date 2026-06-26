import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_colors.dart';

class CustomSurveyEditorHeroCard extends StatelessWidget {
  final String colorHex;
  final String title;
  final String description;
  final int questionCount;
  final int levelCount;
  final bool isActive;
  final int completedSteps;

  const CustomSurveyEditorHeroCard({
    super.key,
    required this.colorHex,
    required this.title,
    required this.description,
    required this.questionCount,
    required this.levelCount,
    required this.isActive,
    required this.completedSteps,
  });

  @override
  Widget build(BuildContext context) {
    final color = parseCustomSurveyColor(colorHex);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.14), Theme.of(context).colorScheme.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(material.Icons.auto_awesome, color: color, size: 28),
              ),
              _StatusChip(
                label: isActive ? 'Activa' : 'Inactiva',
                color: isActive ? const Color(0xFF15803D) : const Color(0xFF64748B),
              ),
              _StatusChip(
                label: '$completedSteps de 3 pasos listos',
                color: color,
              ),
            ],
          ),
          const Gap(16),
          Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const Gap(8),
          Text(
            description.isEmpty
                ? 'Define la estructura, ajusta el tono visual y deja lista la interpretacion del instrumento.'
                : description,
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
              _MetricCard(
                label: 'Preguntas',
                value: '$questionCount',
                icon: material.Icons.quiz_outlined,
                color: color,
              ),
              _MetricCard(
                label: 'Niveles',
                value: '$levelCount',
                icon: material.Icons.insights_outlined,
                color: const Color(0xFF7C3AED),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomSurveyEditorSidebar extends StatelessWidget {
  final int completedSteps;
  final int questionCount;
  final int levelCount;
  final bool hasBasics;
  final bool hasQuestions;
  final bool hasLevels;

  const CustomSurveyEditorSidebar({
    super.key,
    required this.completedSteps,
    required this.questionCount,
    required this.levelCount,
    required this.hasBasics,
    required this.hasQuestions,
    required this.hasLevels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Checklist').semiBold(),
              const Gap(12),
              _ChecklistRow(label: 'Titulo y configuracion general', done: hasBasics),
              const Gap(8),
              _ChecklistRow(label: 'Preguntas completas', done: hasQuestions),
              const Gap(8),
              _ChecklistRow(
                label: 'Interpretacion definida',
                done: hasLevels,
                optional: true,
              ),
              const Gap(14),
              Text(
                'Progreso: $completedSteps de 3 pasos.',
                style: const TextStyle(fontSize: 12),
              ).muted(),
            ],
          ),
        ),
        const Gap(16),
        OutlinedContainer(
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumen rapido').semiBold(),
              const Gap(12),
              _SidebarStat(label: 'Preguntas creadas', value: '$questionCount'),
              const Gap(8),
              _SidebarStat(label: 'Niveles de resultado', value: '$levelCount'),
              const Gap(14),
              const Divider(),
              const Gap(14),
              Text('Consejos').semiBold().small(),
              const Gap(8),
              const Text(
                'Usa preguntas cortas y un solo criterio por reactivo.',
                style: TextStyle(fontSize: 12),
              ).muted(),
              const Gap(6),
              const Text(
                'Si hay puntajes, mantenlos consistentes para facilitar reportes.',
                style: TextStyle(fontSize: 12),
              ).muted(),
              const Gap(6),
              const Text(
                'Los niveles ayudan a leer el resultado sin interpretar manualmente cada vez.',
                style: TextStyle(fontSize: 12),
              ).muted(),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                Text(label).muted().small(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool optional;

  const _ChecklistRow({
    required this.label,
    required this.done,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? const Color(0xFF15803D) : const Color(0xFF94A3B8);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          done ? material.Icons.check_circle : material.Icons.radio_button_unchecked,
          size: 18,
          color: color,
        ),
        const Gap(10),
        Expanded(
          child: Text(
            optional ? '$label (opcional)' : label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.foreground,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarStat extends StatelessWidget {
  final String label;
  final String value;

  const _SidebarStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label).muted()),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
