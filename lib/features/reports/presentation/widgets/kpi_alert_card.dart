import 'package:flutter/material.dart' show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// A highlighted KPI card used for critical alerts (e.g. PHQ-9 item 9 suicidal ideation).
class KpiAlertCard extends StatelessWidget {
  final String label;
  final String value;
  final String? description;
  final bool isAlert;

  const KpiAlertCard({
    super.key,
    required this.label,
    required this.value,
    this.description,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    const alertColor = Color(0xFFDC2626);
    const safeColor = Color(0xFF16A34A);
    final color = isAlert ? alertColor : safeColor;

    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(16),
      backgroundColor: color.withValues(alpha: 0.06),
      borderColor: color.withValues(alpha: 0.5),
      borderWidth: isAlert ? 2.0 : 1.5,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAlert ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: color,
              size: 24,
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const Gap(2),
                Text(
                  value,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
                if (description != null) ...[
                  const Gap(4),
                  Text(
                    description!,
                    style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
