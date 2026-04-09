import 'package:flutter/material.dart' as material show Icons;
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/hero_card/widgets/summary_value.dart';
import 'package:ssapp/features/investigations/presentation/components/investigation_status_pill/investigation_status_pill.dart';

class InvestigationHeroCard extends StatelessWidget {
  final InvestigationModel investigation;

  const InvestigationHeroCard({
    super.key,
    required this.investigation,
  });

  static const List<Color> _palette = [
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
    Color(0xFF14B8A6),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
  ];

  Color get _accentColor => _palette[investigation.id % _palette.length];

  @override
  Widget build(BuildContext context) {
    final status = resolveInvestigationStatus(investigation);

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(material.Icons.science, color: _accentColor),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(investigation.investigationName).semiBold().large(),
                      const Gap(3),
                      Text('Investigacion #${investigation.id}').small().muted(),
                    ],
                  ),
                ),
                InvestigationStatusPill(status: status),
              ],
            ),
            const Gap(12),
            Text(
              investigation.formConsent.trim().isEmpty
                  ? 'Sin descripcion registrada para esta investigacion.'
                  : investigation.formConsent,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ).small().muted(),
            const Gap(12),
            Row(
              children: [
                SummaryValue(
                  icon: material.Icons.checklist,
                  label: 'Instrumentos',
                  value: '${investigation.surveyTypeIds.length}',
                  color: _accentColor,
                ),
                const Gap(8),
                SummaryValue(
                  icon: material.Icons.group,
                  label: 'Participantes',
                  value: '${investigation.participantIds.length}',
                  color: _accentColor,
                ),
                const Gap(8),
                SummaryValue(
                  icon: material.Icons.event,
                  label: 'Creada',
                  value: DateFormat('dd/MM/yy').format(investigation.createdAt),
                  color: _accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
