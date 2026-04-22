import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/shared/widgets/section_empty_state.dart';
import 'package:ssapp/shared/widgets/tts/consent_tts_cards.dart';

class InvestigationConsentSection extends StatelessWidget {
  final InvestigationModel investigation;

  const InvestigationConsentSection({
    super.key,
    required this.investigation,
  });

  @override
  Widget build(BuildContext context) {
    final content = investigation.formConsent.trim();

    if (content.isEmpty) {
      return const SectionEmptyState(
        icon: material.Icons.description_outlined,
        title: 'Sin consentimiento registrado',
        subtitle: 'Esta investigacion aun no tiene texto de consentimiento informado.',
      );
    }

    return InvestigationConsentTtsCard(
      investigationName: investigation.investigationName,
      consentText: investigation.formConsent,
    );
  }
}

