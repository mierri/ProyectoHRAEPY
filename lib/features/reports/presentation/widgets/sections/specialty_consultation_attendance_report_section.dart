import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/domain/specialty_consultation_attendance_report_support.dart';
import 'package:ssapp/features/reports/presentation/widgets/chart_card.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/doughnut_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/charts/horizontal_bar_chart.dart';
import 'package:ssapp/features/reports/presentation/widgets/metric_cards.dart';
import 'package:ssapp/features/reports/presentation/widgets/section_header.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_fields.dart';

class SpecialtyConsultationAttendanceReportSection extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;

  static final k1 = GlobalKey(
    debugLabel: 'specialty_consultation_attendance_k1',
  );
  static final k2 = GlobalKey(
    debugLabel: 'specialty_consultation_attendance_k2',
  );
  static final k3 = GlobalKey(
    debugLabel: 'specialty_consultation_attendance_k3',
  );

  static List<GlobalKey> get chartKeys => [k1, k2, k3];

  static const _color = Color(0xFFB45309);
  static const _transportColors = [
    Color(0xFFF59E0B),
    Color(0xFF475569),
  ];

  const SpecialtyConsultationAttendanceReportSection({
    super.key,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return const Center(child: Text('Sin encuestas disponibles'));
    }

    final summary =
        SpecialtyConsultationAttendanceReportSummary.fromSurveys(surveys);
    final totalTransport = summary.withPrivateTransport +
        summary.withoutPrivateTransport;
    final transportSections = <PieChartSectionData>[];
    final transportLegend = <({String label, Color color, String? value})>[];
    final transportItems = [
      (
        SpecialtyConsultationAttendanceChoices.siNo[0].label,
        summary.withPrivateTransport,
        _transportColors[0],
      ),
      (
        SpecialtyConsultationAttendanceChoices.siNo[1].label,
        summary.withoutPrivateTransport,
        _transportColors[1],
      ),
    ];

    for (final item in transportItems) {
      if (item.$2 == 0) {
        continue;
      }
      final pct = totalTransport == 0 ? 0 : item.$2 / totalTransport * 100;
      transportSections.add(
        PieChartSectionData(
          value: item.$2.toDouble(),
          color: item.$3,
          radius: 56,
          title: '${pct.toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            fontSize: 11,
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      transportLegend.add(
        (label: item.$1, color: item.$3, value: '${item.$2}'),
      );
    }

    final specialtyItems = summary.specialtyCounts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return a.key.compareTo(b.key);
      });
    final specialtyBars = specialtyItems
        .map((entry) => (label: entry.key, value: entry.value.toDouble()))
        .toList();
    final specialtyMax = specialtyItems.isEmpty
        ? 1.0
        : specialtyItems.first.value.toDouble();

    final missedOrder = SpecialtyConsultationAttendanceChoices.citasPerdidas
        .map((choice) => choice.label)
        .toList();
    final missedBars = missedOrder
        .map(
          (label) => (
            label: label,
            value: (summary.missedCountDistribution[label] ?? 0).toDouble(),
          ),
        )
        .where((item) => item.value > 0)
        .toList();
    final missedMax = missedBars.isEmpty
        ? 1.0
        : missedBars
            .map((item) => item.value)
            .reduce((current, next) => current > next ? current : next);

    final latestSurvey = summary.latestSurveyDate == null
        ? '—'
        : DateFormat('dd/MM/yyyy').format(summary.latestSurveyDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Asistencia en Consulta de Especialidad',
          subtitle:
              'Seguimiento de asistencia, transporte y especialidad médica',
          icon: Icons.medical_services_outlined,
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
              icon: Icons.directions_car_outlined,
              label: 'Con transporte',
              value:
                  '${summary.privateTransportPercentage.toStringAsFixed(1)}%',
              hint: '${summary.withPrivateTransport} pacientes',
              color: _color,
            ),
            MetricCardData(
              icon: Icons.event_busy_outlined,
              label: 'Faltó a cita',
              value:
                  '${summary.missedAppointmentPercentage.toStringAsFixed(1)}%',
              hint: '${summary.missedAppointmentYes} pacientes',
              color: _color,
            ),
            MetricCardData(
              icon: Icons.local_hospital_outlined,
              label: 'Especialidad top',
              value: summary.mostCommonSpecialty,
              hint: 'Última encuesta: $latestSurvey',
              color: _color,
            ),
          ],
        ),
        const Gap(16),
        ChartCard(
          title: 'Disponibilidad de transporte privado',
          boundaryKey: k1,
          chart: DoughnutChart(
            sections: transportSections,
            legend: transportLegend,
            holeRadius: 52,
          ),
        ),
        const Gap(12),
        ChartCard(
          title: 'Distribución por especialidad médica',
          boundaryKey: k2,
          height: specialtyBars.isEmpty ? 220 : specialtyBars.length * 34.0 + 28,
          chart: HorizontalBarChart(
            items: specialtyBars,
            maxValue: specialtyMax,
            color: _color,
            valueUnit: ' pac.',
          ),
        ),
        const Gap(12),
        ChartCard(
          title: 'Citas perdidas en pacientes con inasistencia',
          boundaryKey: k3,
          height: 220,
          chart: HorizontalBarChart(
            items: missedBars,
            maxValue: missedMax,
            color: const Color(0xFFDC2626),
            valueUnit: ' pac.',
          ),
        ),
      ],
    );
  }
}
