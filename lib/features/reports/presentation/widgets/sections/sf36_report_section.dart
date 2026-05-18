import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/line_timeline_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/radar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/tornado_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class Sf36ReportSection extends StatelessWidget {
  final SF36ReportData data;
  static final k1 = GlobalKey(debugLabel: 'sf36_k1');
  static final k2 = GlobalKey(debugLabel: 'sf36_k2');
  static final k3 = GlobalKey(debugLabel: 'sf36_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const Sf36ReportSection({super.key, required this.data});

  static const _color = Color(0xFF06B6D4);

  @override
  Widget build(BuildContext context) {
    final dims = [
      data.physicalFunctioning, data.rolePhysical, data.bodilyPain, data.generalHealth,
      data.vitality, data.socialFunctioning, data.roleEmotional, data.mentalHealth,
    ];

    final radarLabels = dims.map((d) => d.label.split(' ').first).toList();
    final radarValues = dims.map((d) => d.mean).toList();

    // Physical component dimensions: 0-3 (PF, RP, BP, GH)
    // Mental component dimensions: 4-7 (VT, SF, RE, MH)
    final tornadoItems = List.generate(4, (i) => (
      label: '${dims[i].label.split(' ').first}/${dims[i + 4].label.split(' ').first}',
      leftValue: dims[i].mean,
      rightValue: dims[i + 4].mean,
    ));

    final maxTimeline = data.globalTimeline.isEmpty ? 100.0
        : data.globalTimeline.reduce((a, b) => a > b ? a : b) * 1.1;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'SF-36 — Cuestionario de Salud de 36 Ítems',
        subtitle: '8 dimensiones de salud física y mental (0–100)',
        icon: Icons.medical_information_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: buildScoredMetricCards(
        mean: data.globalStats.mean,
        mode: data.globalStats.mode,
        stdDev: data.globalStats.stdDev,
        count: data.surveyCount,
        color: _color,
      )),
      const Gap(16),
      ChartCard(
        title: 'Perfil completo de salud — 8 dimensiones',
        boundaryKey: k1,
        chart: ReportRadarChart(labels: radarLabels, values: radarValues, maxValue: 100, color: _color),
      ),
      const Gap(12),
      ChartCard(
        title: 'Componente Físico (izq.) vs Componente Mental (der.)',
        boundaryKey: k2,
        height: 220,
        chart: TornadoChart(
          items: tornadoItems,
          maxValue: 100,
          leftColor: _color,
          rightColor: const Color(0xFF8B5CF6),
          leftLegend: 'Físico',
          rightLegend: 'Mental',
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Evolución del puntaje global',
        boundaryKey: k3,
        chart: LineTimelineChart(
          series: [LineChartBarData(
            spots: [for (var i = 0; i < data.globalTimeline.length; i++)
              FlSpot(i.toDouble(), data.globalTimeline[i])],
            isCurved: true,
            color: _color,
            barWidth: 2.5,
            dotData: FlDotData(show: data.globalTimeline.length <= 15),
          )],
          maxY: maxTimeline,
        ),
      ),
      const Gap(12),
      OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(14),
        backgroundColor: _color.withValues(alpha: 0.05),
        borderColor: _color.withValues(alpha: 0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Interpretación por dimensión', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const Gap(8),
          ...dims.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('${d.label}: ${SurveyStatsCalculator.sf36DimensionInterpretation(d)}',
                style: const TextStyle(fontSize: 12, height: 1.4)),
          )),
        ]),
      ),
    ]);
  }
}
