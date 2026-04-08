import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/timeline_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class WhoqolReportSection extends StatelessWidget {
  final WhoqolReportData data;

  const WhoqolReportSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final domainRows = [
      ('Salud física', data.dom1.mean, data.dom1.maxPossible),
      ('Salud psicológica', data.dom2.mean, data.dom2.maxPossible),
      ('Relaciones sociales', data.dom3.mean, data.dom3.maxPossible),
      ('Ambiente', data.dom4.mean, data.dom4.maxPossible),
    ];

    final maxY = data.globalTimeline.isEmpty
        ? 1.0
        : data.globalTimeline.reduce((a, b) => a > b ? a : b) + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WHOQOL-BREF').semiBold().xLarge(),
        const Gap(12),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Resumen de dominios').semiBold(),
                const Gap(10),
                ...domainRows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(row.$1)),
                        Text('${row.$2.toStringAsFixed(1)} / ${row.$3}').small().semiBold(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tendencia de puntaje global').semiBold(),
                const Gap(12),
                SizedBox(
                  height: 260,
                  child: TimelineLineChart(
                    series: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < data.globalTimeline.length; i++)
                            FlSpot(i.toDouble(), data.globalTimeline[i]),
                        ],
                        isCurved: true,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                    maxY: maxY,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
