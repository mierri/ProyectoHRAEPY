import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class SurveysStatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;
  const SurveysStatsSection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      (material.Icons.assignment,   'Total',         '${stats['total']}',   LightModeColors.lightPrimary),
      (material.Icons.cloud_done,   'Sincronizadas', '${stats['synced']}',  LightModeColors.lightTertiary),
      (material.Icons.cloud_upload, 'Pendientes',    '${stats['pending']}', LightModeColors.lightSecondary),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas').medium(),
          const Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const Gap(10),
                Expanded(
                  child: SurveyStatCard(
                    icon: items[i].$1,
                    label: items[i].$2,
                    value: items[i].$3,
                    color: items[i].$4,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class SurveyStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const SurveyStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: color.withValues(alpha: 0.05),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const Gap(2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: LightModeColors.lightOnSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
