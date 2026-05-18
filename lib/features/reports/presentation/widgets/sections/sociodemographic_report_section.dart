import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/doughnut_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/histogram_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

/// Field IDs from sociodemographic_fields.dart
const _kSexo = 1, _kEdad = 3, _kEscolaridad = 10;
const _kGenderLabels = ['Mujer', 'Hombre', 'Otro'];
const _kEdLevels = [
  'Sin escolaridad', 'Preescolar', 'Primaria', 'Secundaria',
  'Preparatoria', 'Técnica', 'Licenciatura', 'Posgrado',
];

class SociodemographicReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'sociodemo_k1');
  static final k2 = GlobalKey(debugLabel: 'sociodemo_k2');
  static final k3 = GlobalKey(debugLabel: 'sociodemo_k3');
  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  const SociodemographicReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF4F46E5);
  static const _genderColors = [Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFF8B5CF6)];

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));

    // Extract responses
    int? getResponse(Map<String, dynamic> s, int fieldId) {
      final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
      final match = r.where((x) => (x['question_id'] as int?) == fieldId);
      return match.isEmpty ? null : match.first['answer_value'] as int?;
    }

    // Gender distribution
    final genderCounts = [0, 0, 0];
    final ages = <double>[];
    final edCounts = List<int>.filled(_kEdLevels.length, 0);

    for (final s in surveys) {
      final sexo = getResponse(s, _kSexo);
      if (sexo != null && sexo < genderCounts.length) genderCounts[sexo]++;
      final edad = getResponse(s, _kEdad);
      if (edad != null && edad > 0) ages.add(edad.toDouble());
      final esc = getResponse(s, _kEscolaridad);
      if (esc != null && esc < edCounts.length) edCounts[esc]++;
    }

    final totalGender = genderCounts.fold<int>(0, (a, b) => a + b);
    final doughnut = <PieChartSectionData>[];
    final legend = <({String label, Color color, String? value})>[];
    for (var i = 0; i < _kGenderLabels.length; i++) {
      if (genderCounts[i] == 0) continue;
      final c = _genderColors[i % _genderColors.length];
      doughnut.add(PieChartSectionData(
        value: genderCounts[i].toDouble(), color: c, radius: 55,
        title: '${(genderCounts[i] / (totalGender == 0 ? 1 : totalGender) * 100).toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
      ));
      legend.add((label: _kGenderLabels[i], color: c, value: '${genderCounts[i]}'));
    }

    // Escolaridad horizontal bar
    final edMax = edCounts.reduce((a, b) => a > b ? a : b).toDouble();
    final edItems = List.generate(_kEdLevels.length, (i) =>
      (label: _kEdLevels[i], value: edCounts[i].toDouble()));

    // Metric cards for this survey type
    final meanAge = ages.isEmpty ? 0.0 : ages.reduce((a, b) => a + b) / ages.length;
    final mostCommon = genderCounts.indexOf(genderCounts.reduce((a, b) => a > b ? a : b));
    final lastDate = surveys.isNotEmpty
        ? surveys.map((s) => s['created_at'] as String? ?? '').reduce((a, b) => a.compareTo(b) > 0 ? a : b)
        : '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Cuestionario Sociodemográfico',
        subtitle: 'Distribución de características de la población',
        icon: Icons.people_outline,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: [
        MetricCardData(icon: Icons.assignment_turned_in, label: 'Total encuestas',
            value: '${surveys.length}', color: _color),
        MetricCardData(icon: Icons.cake_outlined, label: 'Edad media',
            value: '${meanAge.toStringAsFixed(1)} años', color: _color),
        MetricCardData(icon: Icons.person_outline, label: 'Sexo más frecuente',
            value: mostCommon < _kGenderLabels.length ? _kGenderLabels[mostCommon] : '—', color: _color),
        MetricCardData(icon: Icons.calendar_today, label: 'Última encuesta',
            value: lastDate.length >= 10 ? lastDate.substring(0, 10) : '—', color: _color),
      ]),
      const Gap(16),
      ChartCard(
        title: 'Distribución por sexo',
        boundaryKey: k1,
        chart: DoughnutChart(sections: doughnut, legend: legend, holeRadius: 55),
      ),
      const Gap(12),
      if (ages.isNotEmpty)
        ChartCard(
          title: 'Distribución de edades',
          boundaryKey: k2,
          chart: HistogramChart(values: ages, color: _color, xLabel: 'Edad (años)'),
        ),
      const Gap(12),
      ChartCard(
        title: 'Escolaridad máxima alcanzada',
        boundaryKey: k3,
        height: _kEdLevels.length * 36.0 + 20,
        chart: HorizontalBarChart(
          items: edItems,
          maxValue: edMax == 0 ? 1 : edMax,
          color: _color,
          valueUnit: ' pac.',
        ),
      ),
    ]);
  }
}
