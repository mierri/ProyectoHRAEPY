import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ApplyConsentCard extends StatelessWidget {
  final String consentText;

  const ApplyConsentCard({
    super.key,
    required this.consentText,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(material.Icons.fact_check_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                const Gap(8),
                Expanded(
                  child: Text('Consentimiento de la investigacion').semiBold(),
                ),
              ],
            ),
            const Gap(12),
            Text(
              consentText.trim().isEmpty
                  ? 'Esta investigacion aun no tiene consentimiento registrado.'
                  : consentText,
              style: const TextStyle(height: 1.5),
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}


