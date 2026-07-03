import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class GenericReportSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final List<Map<String, dynamic>> surveys;

  const GenericReportSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));

    final scores = surveys
        .map((s) => s['score'] as int? ?? SurveyStatsCalculator.calculateSurveyScore(s))
        .toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          icon: Icons.assessment_outlined,
          color: color,
        ),
        const Gap(16),
        MetricCardGroup(
          cards: buildScoredMetricCards(
            mean: stats.mean,
            mode: stats.mode,
            stdDev: stats.stdDev,
            count: stats.count,
            color: color,
          ),
        ),
        const Gap(16),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resultados capturados', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Gap(12),
                const Divider(),
                const Gap(8),
                ...surveys.map((survey) {
                  final score = survey['score'] as int? ?? SurveyStatsCalculator.calculateSurveyScore(survey);
                  final level = survey['risk_level'] as String? ?? '-';
                  final createdAt = DateTime.tryParse(survey['created_at'] as String? ?? '');
                  final dateLabel = createdAt != null
                      ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
                      : '-';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(dateLabel)),
                        Expanded(flex: 2, child: Text('Paciente ${survey['patient_id'] ?? '-'}')),
                        Expanded(child: Text('$score pts', style: const TextStyle(fontWeight: FontWeight.w600))),
                        Expanded(flex: 2, child: Text(level, textAlign: TextAlign.end)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
