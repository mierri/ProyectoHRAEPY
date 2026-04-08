import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/report_models.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/timeline_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class Sf36ReportSection extends StatelessWidget {
  final SF36ReportData data;

  const Sf36ReportSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dims = [
      data.physicalFunctioning,
      data.rolePhysical,
      data.bodilyPain,
      data.generalHealth,
      data.vitality,
      data.socialFunctioning,
      data.roleEmotional,
      data.mentalHealth,
    ];

    final maxY = data.globalTimeline.isEmpty
        ? 1.0
        : data.globalTimeline.reduce((a, b) => a > b ? a : b) + 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SF-36').semiBold().xLarge(),
        const Gap(12),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dimensiones de salud (0-100)').semiBold(),
                const Gap(10),
                ...dims.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(d.label)),
                        Text(d.mean.toStringAsFixed(1)).small().semiBold(),
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
                const Text('Tendencia global SF-36').semiBold(),
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
