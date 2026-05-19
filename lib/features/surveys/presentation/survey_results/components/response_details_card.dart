import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class ResponseDetailsCard extends StatelessWidget {
  final List responses;
  final int surveyType;

  const ResponseDetailsCard({super.key, required this.responses, required this.surveyType});

  @override
  Widget build(BuildContext context) {
    final avg = responses.fold<int>(0, (s, r) => s + (r['answer_value'] as int? ?? 0)) / responses.length;

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(material.Icons.assignment_outlined, color: LightModeColors.lightPrimary),
            const Gap(12),
            Expanded(child: Text('Detalle de Respuestas').semiBold().large()),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${responses.length} preg.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: LightModeColors.lightPrimary),
              ),
            ),
          ]),
          const Gap(16),
          const Divider(),
          const Gap(16),
          Text('Total de respuestas: ${responses.length}', style: const TextStyle(fontSize: 14)).muted(),
          const Gap(8),
          Text('Puntaje promedio por pregunta: ${avg.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14)).muted(),
        ]),
      ),
    );
  }
}
