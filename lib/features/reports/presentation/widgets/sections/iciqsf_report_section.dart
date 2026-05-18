import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/gauge_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/pie_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class IciqsfReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'iciqsf_k1');
  static final k2 = GlobalKey(debugLabel: 'iciqsf_k2');
  static final k3 = GlobalKey(debugLabel: 'iciqsf_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const IciqsfReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF2563EB);

  static const _situationLabels = [
    'Nunca', 'Antes de llegar al baño', 'Al toser/estornudar',
    'Mientras duerme', 'Al hacer ejercicio',
    'Al terminar de orinar', 'Sin motivo', 'Continua',
  ];

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));
    final sorted = List<Map<String, dynamic>>.from(surveys)
      ..sort((a, b) => DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at'])));
    final scores = sorted.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);

    // Q3 = interference (0-10), Q4 = situations bitmask
    double q3Mean = 0; int q3n = 0;
    final sitCounts = List<int>.filled(_situationLabels.length, 0);

    for (final s in sorted) {
      final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
      for (final x in r) {
        final q = x['question_id'] as int? ?? 0;
        final v = x['answer_value'] as int? ?? 0;
        if (q == 3) { q3Mean += v; q3n++; }
        if (q == 4) {
          for (var bit = 0; bit < _situationLabels.length; bit++) {
            if ((v >> bit) & 1 == 1) sitCounts[bit]++;
          }
        }
      }
    }
    final meanQ3 = q3n == 0 ? 0.0 : q3Mean / q3n;

    final totalSit = sitCounts.fold<int>(0, (a, b) => a + b);
    final pieSections = <PieChartSectionData>[];
    final pieLegend = <({String label, Color color, String? value})>[];
    final baseColors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B),
      const Color(0xFFEF4444), const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFFF97316), const Color(0xFF6366F1)];
    for (var i = 0; i < sitCounts.length; i++) {
      if (sitCounts[i] == 0) continue;
      final c = baseColors[i % baseColors.length];
      pieSections.add(PieChartSectionData(
        value: sitCounts[i].toDouble(), color: c, radius: 50,
        title: '${(sitCounts[i] / (totalSit == 0 ? 1 : totalSit) * 100).toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
      ));
      pieLegend.add((label: _situationLabels[i], color: c, value: '${sitCounts[i]}'));
    }

    // Bar chart: frequency distribution (Q1: 0-5)
    final freqCounts = List<int>.filled(6, 0);
    for (final s in sorted) {
      final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
      final q1 = r.where((x) => (x['question_id'] as int?) == 1);
      if (q1.isNotEmpty) {
        final v = (q1.first['answer_value'] as int? ?? 0).clamp(0, 5);
        freqCounts[v]++;
      }
    }
    const freqLabels = ['Nunca', '1x/sem', '2-3x/sem', '1x/día', 'Varias/día', 'Siempre'];
    final barGroups = [for (var i = 0; i < 6; i++)
      BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: freqCounts[i].toDouble(), color: _color.withValues(alpha: 0.8), width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
      ])
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'ICIQ-SF — Incontinencia Urinaria',
        subtitle: 'Frecuencia, cantidad e impacto en calidad de vida',
        icon: Icons.water_drop_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: stats.mean, mode: stats.mode, stdDev: stats.stdDev, count: stats.count, color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Interferencia con la vida diaria (Ítem 3, 0–10)',
        boundaryKey: k1,
        chart: GaugeChart(
          value: meanQ3.clamp(0, 10),
          maxValue: 10,
          centerLabel: meanQ3.toStringAsFixed(1),
          sublabel: SurveyStatsCalculator.iciqsfLevel(meanQ3.round()),
          segments: const [
            GaugeSegment(label: 'Sin impacto', endValue: 3, color: Color(0xFF10B981)),
            GaugeSegment(label: 'Moderado', endValue: 7, color: Color(0xFFF59E0B)),
            GaugeSegment(label: 'Severo', endValue: 10, color: Color(0xFFEF4444)),
          ],
        ),
      ),
      const Gap(12),
      if (pieSections.isNotEmpty)
        ChartCard(
          title: 'Situaciones de pérdida de orina',
          boundaryKey: k2,
          chart: ReportPieChart(sections: pieSections, legend: pieLegend),
        ),
      const Gap(12),
      ChartCard(
        title: 'Distribución de frecuencia de pérdidas',
        boundaryKey: k3,
        chart: ReportBarChart(
          groups: barGroups,
          maxY: (freqCounts.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
          bottomLabels: freqLabels,
        ),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Text(SurveyStatsCalculator.iciqsfInterpretation(stats.mean),
            style: const TextStyle(fontSize: 13, height: 1.5)),
      ),
    ]);
  }
}
