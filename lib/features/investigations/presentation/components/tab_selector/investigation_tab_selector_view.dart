import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/presentation/components/tab_selector/widgets/tab_chip.dart';

enum InvestigationDetailTab { surveys, consent, participants, reports }

class InvestigationTabSelector extends StatelessWidget {
  final InvestigationDetailTab selected;
  final ValueChanged<InvestigationDetailTab> onChanged;

  const InvestigationTabSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TabChip(
          icon: material.Icons.checklist,
          label: 'Encuestas',
          selected: selected == InvestigationDetailTab.surveys,
          onTap: () => onChanged(InvestigationDetailTab.surveys),
        ),
        TabChip(
          icon: material.Icons.description,
          label: 'Consentimiento',
          selected: selected == InvestigationDetailTab.consent,
          onTap: () => onChanged(InvestigationDetailTab.consent),
        ),
        TabChip(
          icon: material.Icons.group,
          label: 'Participantes',
          selected: selected == InvestigationDetailTab.participants,
          onTap: () => onChanged(InvestigationDetailTab.participants),
        ),
        TabChip(
          icon: material.Icons.bar_chart,
          label: 'Reportes',
          selected: selected == InvestigationDetailTab.reports,
          onTap: () => onChanged(InvestigationDetailTab.reports),
        ),
      ],
    );
  }
}

