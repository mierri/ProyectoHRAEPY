import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/radar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/stacked_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';

/// Field IDs from social_determinants_fields.dart
const _kAguaPotable = 13, _kDrenaje = 14, _kEnergia = 15;
const _kTipoVivienda = 4, _kProgramasSociales = 11, _kBienesDurables = 19;
const _kIngresoMensual = 3, _kEscolaridad = 1, _kSeguridadSocial = 10;
const _kEdLevels = [
  'Sin escolaridad', 'Preescolar', 'Primaria', 'Secundaria',
  'Preparatoria', 'Técnica', 'Licenciatura', 'Posgrado',
];

class SocialDeterminantsReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  static final k1 = GlobalKey(debugLabel: 'socdeter_k1');
  static final k2 = GlobalKey(debugLabel: 'socdeter_k2');
  static final k3 = GlobalKey(debugLabel: 'socdeter_k3');
  static final k4 = GlobalKey(debugLabel: 'socdeter_k4');
  static List<GlobalKey> get chartKeys => [k1, k2, k3, k4];

  const SocialDeterminantsReportSection({super.key, required this.surveys});

  static const _color = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) return const Center(child: Text('Sin encuestas disponibles'));

    int? getField(Map<String, dynamic> s, int fieldId) {
      final r = (s['responses'] as List? ?? []).cast<Map<String, dynamic>>();
      final match = r.where((x) => (x['question_id'] as int?) == fieldId);
      return match.isEmpty ? null : match.first['answer_value'] as int?;
    }

    // Access to basic services (0=Sí, 1=No)
    int aguaYes = 0, drenYes = 0, energYes = 0;
    final edCounts = List<int>.filled(_kEdLevels.length, 0);
    for (final s in surveys) {
      if (getField(s, _kAguaPotable) == 0) aguaYes++;
      if (getField(s, _kDrenaje) == 0) drenYes++;
      if (getField(s, _kEnergia) == 0) energYes++;
      final esc = getField(s, _kEscolaridad);
      if (esc != null && esc < edCounts.length) edCounts[esc]++;
    }
    final n = surveys.isEmpty ? 1 : surveys.length;

    final edMax = edCounts.reduce((a, b) => a > b ? a : b).toDouble();
    final edItems = List.generate(_kEdLevels.length, (i) =>
      (label: _kEdLevels[i], value: edCounts[i].toDouble()));

    final serviceItems = [
      (label: 'Agua potable', value: aguaYes / n * 100),
      (label: 'Drenaje', value: drenYes / n * 100),
      (label: 'Energía eléctrica', value: energYes / n * 100),
    ];

    // Vulnerability radar: domains scored as % of population with basic access
    // Higher = better (less vulnerability)
    final viviendaOk = surveys.where((s) => (getField(s, _kTipoVivienda) ?? 2) <= 1).length / n * 100;
    final serviciosOk = [aguaYes, drenYes, energYes].fold<int>(0, (a, b) => a + b) / (n * 3) * 100;
    final ingresoOk = surveys.where((s) => (getField(s, _kIngresoMensual) ?? 0) >= 2).length / n * 100;
    final educOk = surveys.where((s) => (getField(s, _kEscolaridad) ?? 0) >= 3).length / n * 100;
    final saludOk = surveys.where((s) {
      final v = getField(s, _kSeguridadSocial);
      return v != null && v != 5;
    }).length / n * 100;

    final radarValues = [viviendaOk, serviciosOk, ingresoOk, educOk, saludOk];
    const radarLabels = ['Vivienda', 'Servicios', 'Ingreso', 'Educación', 'Salud'];

    // 100% stacked bar for needs (satisfied vs not) per domain
    final stackGroups = <({String label, double yes, double no})>[
      (label: 'Agua', yes: aguaYes / n * 100, no: (n - aguaYes) / n * 100),
      (label: 'Drenaje', yes: drenYes / n * 100, no: (n - drenYes) / n * 100),
      (label: 'Electricidad', yes: energYes / n * 100, no: (n - energYes) / n * 100),
    ];
    final barGroups = <BarChartGroupData>[
      for (var i = 0; i < stackGroups.length; i++)
        _makeStackedBar(i, stackGroups[i].yes, stackGroups[i].no),
    ];
    final barLabels = stackGroups.map((g) => g.label).toList();

    final lastDate = surveys.isNotEmpty
        ? surveys.map((s) => s['created_at'] as String? ?? '').reduce((a, b) => a.compareTo(b) > 0 ? a : b)
        : '';
    final vulnIndex = 100 - radarValues.fold(0.0, (a, b) => a + b) / radarValues.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(
        title: 'Determinantes Sociales de la Salud',
        subtitle: 'Acceso a recursos, servicios y condiciones de vida',
        icon: Icons.location_city_outlined,
        color: _color,
      ),
      const Gap(16),
      MetricCardGroup(cards: [
        MetricCardData(icon: Icons.assignment_turned_in, label: 'Total encuestas',
            value: '${surveys.length}', color: _color),
        MetricCardData(icon: Icons.warning_amber_outlined, label: 'Índice vulnerabilidad',
            value: '${vulnIndex.toStringAsFixed(1)}%', color: _color),
        MetricCardData(icon: Icons.water_drop_outlined, label: 'Acceso a agua',
            value: '${(aguaYes / n * 100).toStringAsFixed(0)}%', color: _color),
        MetricCardData(icon: Icons.calendar_today, label: 'Última encuesta',
            value: lastDate.length >= 10 ? lastDate.substring(0, 10) : '—', color: _color),
      ]),
      const Gap(16),
      ChartCard(
        title: 'Perfil de acceso por dominio (% con acceso)',
        boundaryKey: k1,
        chart: ReportRadarChart(labels: radarLabels, values: radarValues, maxValue: 100, color: _color),
      ),
      const Gap(12),
      ChartCard(
        title: 'Necesidades básicas satisfechas vs no satisfechas',
        boundaryKey: k2,
        chart: StackedBarChart(
          groups: barGroups,
          maxY: 100,
          bottomLabels: barLabels,
          percentageMode: true,
          legend: const [
            (label: 'Con acceso', color: Color(0xFF10B981)),
            (label: 'Sin acceso', color: Color(0xFFEF4444)),
          ],
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Acceso a servicios básicos (% de la población)',
        boundaryKey: k3,
        height: 180,
        chart: HorizontalBarChart(
          items: serviceItems,
          maxValue: 100,
          color: _color,
          valueUnit: '%',
        ),
      ),
      const Gap(12),
      ChartCard(
        title: 'Escolaridad máxima alcanzada',
        boundaryKey: k4,
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

  static BarChartGroupData _makeStackedBar(int x, double yes, double no) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: 100, width: 30, color: const Color(0xFF10B981),
        rodStackItems: [
          BarChartRodStackItem(0, yes, const Color(0xFF10B981)),
          BarChartRodStackItem(yes, 100, const Color(0xFFEF4444)),
        ],
      ),
    ]);
  }
}
