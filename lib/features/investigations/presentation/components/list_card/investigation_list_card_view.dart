import 'package:flutter/material.dart' as material show Icons;
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/investigation_status_pill/investigation_status_pill.dart';
import 'package:ssapp/features/investigations/presentation/components/list_card/widgets/info_pill.dart';
import 'package:ssapp/features/investigations/presentation/components/list_card/widgets/survey_pill.dart';

class InvestigationListCard extends StatelessWidget {
  final InvestigationModel investigation;
  final VoidCallback onTap;

  const InvestigationListCard({
    super.key,
    required this.investigation,
    required this.onTap,
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
    final surveyNames = investigation.surveyTypeIds
        .map((id) => InvestigationService.surveyTypes[id] ?? 'Tipo $id')
        .toList();

    return GestureDetector(
      onTap: onTap,
      child: OutlinedContainer(
        borderRadius: BorderRadius.circular(16),
        borderColor: Theme.of(context).colorScheme.border,
        borderWidth: 1,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(material.Icons.science, size: 20, color: _accentColor),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investigation.investigationName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).semiBold(),
                      const Gap(2),
                      Text(
                        'ID ${investigation.id} - ${DateFormat('dd MMM yyyy').format(investigation.createdAt)}',
                      ).small().muted(),
                    ],
                  ),
                ),
                const Gap(8),
                Icon(
                  material.Icons.chevron_right,
                  size: 18,
                  color: Theme.of(context).colorScheme.mutedForeground,
                ),
              ],
            ),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InvestigationStatusPill(status: status),
                InfoPill(
                  icon: material.Icons.checklist,
                  label: '${investigation.surveyTypeIds.length} instrumentos',
                ),
                InfoPill(
                  icon: material.Icons.group,
                  label: '${investigation.participantIds.length} participantes',
                ),
              ],
            ),
            if (surveyNames.isNotEmpty) ...[
              const Gap(10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final surveyName in surveyNames.take(3))
                    SurveyPill(
                      name: surveyName,
                      accentColor: _accentColor,
                    ),
                  if (surveyNames.length > 3)
                    SurveyPill(name: '+${surveyNames.length - 3} mas', accentColor: _accentColor),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

