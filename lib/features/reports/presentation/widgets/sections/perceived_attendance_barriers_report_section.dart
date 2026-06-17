import 'package:flutter/material.dart' show Icons;
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/perceived_attendance_barriers_report_support.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

class PerceivedAttendanceBarriersReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;

  static final k1 = GlobalKey(debugLabel: 'perceived_attendance_barriers_k1');
  static final k2 = GlobalKey(debugLabel: 'perceived_attendance_barriers_k2');
  static final k3 = GlobalKey(debugLabel: 'perceived_attendance_barriers_k3');

  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  static const _color = Color(0xFFBE123C);

  const PerceivedAttendanceBarriersReportSection({
    super.key,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return const Center(child: Text('Sin encuestas disponibles'));
    }

    final summary = PerceivedAttendanceBarriersReportSummary.fromSurveys(
      surveys,
    );

    List<({String label, double value})> sortedItems(Map<String, int> counts) {
      final entries = counts.entries.toList()
        ..sort((a, b) {
          final countCompare = b.value.compareTo(a.value);
          if (countCompare != 0) {
            return countCompare;
          }
          return a.key.compareTo(b.key);
        });
      return entries
          .map((entry) => (label: entry.key, value: entry.value.toDouble()))
          .toList();
    }

    final recentItems = sortedItems(summary.recentReasonCounts);
    final recentMax = recentItems.isEmpty ? 1.0 : recentItems.first.value;

    final primaryItems = sortedItems(summary.primaryFutureReasonCounts);
    final primaryMax = primaryItems.isEmpty ? 1.0 : primaryItems.first.value;

    final allFutureItems = sortedItems(summary.allFutureReasonCounts);
    final allFutureMax =
        allFutureItems.isEmpty ? 1.0 : allFutureItems.first.value;

    final latestSurvey = summary.latestSurveyDate == null
        ? '—'
        : DateFormat('dd/MM/yyyy').format(summary.latestSurveyDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Barreras Percibidas para la Asistencia',
          subtitle:
              'Motivos de inasistencia reciente y riesgos percibidos para futuras consultas',
          icon: Icons.route_outlined,
          color: _color,
        ),
        const Gap(16),
        MetricCardGroup(
          cards: [
            MetricCardData(
              icon: Icons.assignment_turned_in,
              label: 'Total encuestas',
              value: '${summary.total}',
              color: _color,
            ),
            MetricCardData(
              icon: Icons.history_toggle_off,
              label: 'Con sección A',
              value:
                  '${summary.antecedentSectionPercentage.toStringAsFixed(1)}%',
              hint: '${summary.withAntecedentSection} pacientes',
              color: _color,
            ),
            MetricCardData(
              icon: Icons.looks_one_outlined,
              label: 'Motivo futuro #1',
              value: summary.topPrimaryReason,
              color: _color,
            ),
            MetricCardData(
              icon: Icons.rule_folder_outlined,
              label: 'Motivo global top',
              value: summary.topOverallFutureReason,
              hint: 'Última encuesta: $latestSurvey',
              color: _color,
            ),
          ],
        ),
        const Gap(16),
        ChartCard(
          title: 'Motivos de la inasistencia más reciente',
          boundaryKey: k1,
          height: recentItems.isEmpty ? 220 : recentItems.length * 34.0 + 28,
          chart: HorizontalBarChart(
            items: recentItems,
            maxValue: recentMax,
            color: const Color(0xFFE11D48),
            valueUnit: ' pac.',
          ),
        ),
        const Gap(12),
        ChartCard(
          title: 'Motivos principales para una falta futura',
          boundaryKey: k2,
          height: primaryItems.isEmpty ? 220 : primaryItems.length * 34.0 + 28,
          chart: HorizontalBarChart(
            items: primaryItems,
            maxValue: primaryMax,
            color: _color,
            valueUnit: ' pac.',
          ),
        ),
        const Gap(12),
        ChartCard(
          title: 'Frecuencia total de barreras futuras seleccionadas',
          boundaryKey: k3,
          height: allFutureItems.isEmpty
              ? 220
              : allFutureItems.length * 34.0 + 28,
          chart: HorizontalBarChart(
            items: allFutureItems,
            maxValue: allFutureMax,
            color: const Color(0xFF9F1239),
            valueUnit: ' sel.',
          ),
        ),
      ],
    );
  }
}
