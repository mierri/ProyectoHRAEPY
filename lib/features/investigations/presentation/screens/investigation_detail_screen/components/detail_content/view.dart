import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/consent_section/consent_section.dart';
import 'package:ssapp/features/investigations/presentation/components/hero_card/hero_card.dart';
import 'package:ssapp/features/investigations/presentation/components/participants_section/participants_section.dart';
import 'package:ssapp/features/investigations/presentation/components/reports_section/reports_section.dart';
import 'package:ssapp/features/investigations/presentation/components/surveys_section/surveys_section.dart';
import 'package:ssapp/features/investigations/presentation/components/tab_selector/tab_selector.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class InvestigationDetailContent extends StatelessWidget {
  final InvestigationModel investigation;
  final InvestigationDetailTab selectedTab;
  final ValueChanged<InvestigationDetailTab> onTabChanged;
  final Map<int, PatientModel> patientsById;
  final VoidCallback onApply;

  const InvestigationDetailContent({
    super.key,
    required this.investigation,
    required this.selectedTab,
    required this.onTabChanged,
    required this.patientsById,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InvestigationHeroCard(investigation: investigation),
          const Gap(12),
          PrimaryButton(
            onPressed: onApply,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(material.Icons.play_arrow, size: 18),
                Gap(8),
                Text('Aplicar encuestas'),
              ],
            ),
          ),
          const Gap(16),
          InvestigationTabSelector(selected: selectedTab, onChanged: onTabChanged),
          const Gap(16),
          _selectedSection(),
        ],
      ),
    );
  }

  Widget _selectedSection() {
    switch (selectedTab) {
      case InvestigationDetailTab.surveys:
        return InvestigationSurveysSection(investigation: investigation);
      case InvestigationDetailTab.consent:
        return InvestigationConsentSection(investigation: investigation);
      case InvestigationDetailTab.participants:
        return InvestigationParticipantsSection(
          investigation: investigation,
          patientsById: patientsById,
        );
      case InvestigationDetailTab.reports:
        return InvestigationReportsSection(investigation: investigation);
    }
  }
}

