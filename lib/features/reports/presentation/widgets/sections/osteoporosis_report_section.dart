import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/osteoporosis_report_model.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/gauge_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class OsteoporosisReportSection extends StatelessWidget {
  final OsteoporosisCompleteReport report;
  static final k1 = GlobalKey(debugLabel: 'osteo_k1');
  static final k2 = GlobalKey(debugLabel: 'osteo_k2');
  static final k3 = GlobalKey(debugLabel: 'osteo_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const OsteoporosisReportSection({super.key, required this.report});

  static const _color = Color(0xFF145374);

  @override
  Widget build(BuildContext context) {
    final ov = report.overview;
    final ageData = report.ageGroupData;

    // Bar chart: high risk % per age group
    final ageBars = <BarChartGroupData>[];
    final ageLabels = <String>[];
    for (var i = 0; i < ageData.length; i++) {
      ageBars.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: ageData[i].highRiskPercentage,
          color: const Color(0xFFEF4444),
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ]));
      ageLabels.add(ageData[i].ageGroup);
    }

    // Risk factors horizontal bar
    final rfItems = report.riskFactors
        .take(8)
        .map((rf) => (label: 'F${rf.questionNumber}', value: rf.yesPercentage))
        .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Osteoporosis — Factores de Riesgo',
        subtitle: 'Estratificación de riesgo y análisis por grupo etario',
        icon: Icons.medical_services_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: [
        MetricCardData(icon: Icons.people_outline, label: 'Total pacientes',
            value: '${ov.totalPatients}', color: _color),
        MetricCardData(icon: Icons.warning_amber_outlined, label: 'Riesgo alto',
            value: '${ov.highRiskCount} (${ov.highRiskPercentage.toStringAsFixed(1)}%)', color: const Color(0xFFEF4444)),
        MetricCardData(icon: Icons.check_circle_outline, label: 'Riesgo bajo',
            value: '${ov.lowRiskCount} (${ov.lowRiskPercentage.toStringAsFixed(1)}%)', color: const Color(0xFF10B981)),
        MetricCardData(icon: Icons.monitor_weight_outlined, label: 'IMC promedio',
            value: ov.averageBMI.toStringAsFixed(1), color: _color),
      ]),
      const Gap(16),
      ChartCard(
        title: 'Porcentaje de riesgo alto (media poblacional)',
        boundaryKey: k1,
        chart: GaugeChart(
          value: ov.highRiskPercentage.clamp(0, 100),
          maxValue: 100,
          centerLabel: '${ov.highRiskPercentage.toStringAsFixed(1)}%',
          sublabel: ov.highRiskPercentage > 50 ? 'Riesgo alto prevalente' : 'Riesgo bajo prevalente',
          segments: const [
            GaugeSegment(label: 'Bajo', endValue: 33, color: Color(0xFF10B981)),
            GaugeSegment(label: 'Moderado', endValue: 66, color: Color(0xFFF59E0B)),
            GaugeSegment(label: 'Alto', endValue: 100, color: Color(0xFFEF4444)),
          ],
        ),
      ),
      const Gap(12),
      if (ageData.isNotEmpty)
        ChartCard(
          title: 'Riesgo alto por grupo etario (%)',
          boundaryKey: k2,
          chart: ReportBarChart(groups: ageBars, maxY: 100, bottomLabels: ageLabels, leftLabel: '%'),
        ),
      const Gap(12),
      if (rfItems.isNotEmpty)
        ChartCard(
          title: 'Factores de riesgo prevalentes (% de respuestas afirmativas)',
          boundaryKey: k3,
          height: rfItems.length * 36.0 + 20,
          chart: HorizontalBarChart(items: rfItems, maxValue: 100, color: _color, valueUnit: '%'),
        ),
    ]);
  }
}
