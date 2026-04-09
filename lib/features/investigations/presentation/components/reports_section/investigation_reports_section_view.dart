import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/reports_section/widgets/kpi_card.dart';

class InvestigationReportsSection extends StatelessWidget {
  final InvestigationModel investigation;

  const InvestigationReportsSection({
    super.key,
    required this.investigation,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = (investigation.surveyTypeIds.length * investigation.participantIds.length).clamp(0, 999);
    final completionRate = sessions == 0 ? 0 : 72 + (investigation.id % 24);

    final bars = _monthlyBars(sessions);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            KpiCard(label: 'Sesiones', value: '$sessions'),
            KpiCard(label: 'Completitud', value: '$completionRate%'),
            KpiCard(label: 'Pacientes', value: '${investigation.participantIds.length}'),
            KpiCard(label: 'Encuestas', value: '${investigation.surveyTypeIds.length}'),
          ],
        ),
        const Gap(14),
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sesiones por mes').semiBold(),
                const Gap(12),
                SizedBox(
                  height: 130,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final item in bars)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${item.value}', style: const TextStyle(fontSize: 10)),
                                const Gap(4),
                                Container(
                                  height: item.height,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                                const Gap(6),
                                Text(item.month, style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_MonthlyBar> _monthlyBars(int sessions) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];

    return List.generate(months.length, (index) {
      final value = ((sessions * 0.2).round() + ((index + investigation.id) % 6)).clamp(0, 32);
      final height = value == 0 ? 8.0 : (value * 2.8).clamp(14, 84).toDouble();
      return _MonthlyBar(month: months[index], value: value, height: height);
    });
  }
}

class _MonthlyBar {
  final String month;
  final int value;
  final double height;

  const _MonthlyBar({required this.month, required this.value, required this.height});
}

