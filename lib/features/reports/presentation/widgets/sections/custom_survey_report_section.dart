import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';

Color _parseDefinitionColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

class CustomSurveyReportSection extends StatelessWidget {
  final CustomSurveyDefinition definition;
  final List<Map<String, dynamic>> surveys;

  const CustomSurveyReportSection({super.key, required this.definition, required this.surveys});

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));

    final color = _parseDefinitionColor(definition.colorHex);
    final scores = surveys
        .map((s) => s['score'] as int? ?? SurveyStatsCalculator.calculateSurveyScore(s))
        .toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: definition.title,
        subtitle: definition.description.isNotEmpty ? definition.description : 'Encuesta personalizada',
        icon: Icons.assignment_outlined,
        color: color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: color,
      )),
      const Gap(16),
      SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Respuestas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const Gap(12),
            const Divider(),
            const Gap(8),
            ...surveys.map((s) {
              final score = s['score'] as int? ?? SurveyStatsCalculator.calculateSurveyScore(s);
              final level = definition.levelForScore(score);
              final levelLabel = level?.label ?? (s['risk_level'] as String? ?? '-');
              final createdAt = DateTime.tryParse(s['created_at'] as String? ?? '');
              final dateLabel = createdAt != null
                  ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
                  : '-';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(flex: 2, child: Text(dateLabel)),
                  Expanded(flex: 2, child: Text('Paciente ${s['patient_id'] ?? '-'}')),
                  Expanded(child: Text('$score pts', style: const TextStyle(fontWeight: FontWeight.w600))),
                  Expanded(flex: 2, child: Text(levelLabel, textAlign: TextAlign.end)),
                ]),
              );
            }),
          ]),
        ),
      ),
    ]);
  }
}
