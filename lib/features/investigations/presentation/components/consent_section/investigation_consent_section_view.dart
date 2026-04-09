import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/shared/widgets/section_empty_state.dart';

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

    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(material.Icons.fact_check_outlined, size: 16),
                const Gap(8),
                Text('Consentimiento informado').semiBold(),
              ],
            ),
            const Gap(10),
            Text(content, style: const TextStyle(height: 1.5)).small(),
          ],
        ),
      ),
    );
  }
}

