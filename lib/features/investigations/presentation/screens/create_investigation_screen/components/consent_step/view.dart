import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class InvestigationConsentStep extends StatelessWidget {
  final TextEditingController consentController;

  const InvestigationConsentStep({
    super.key,
    required this.consentController,
  });

  @override
  Widget build(BuildContext context) {
    final consentLength = consentController.text.trim().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  material.Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(8),
                Expanded(
                  child: const Text(
                    'Este texto se mostrara antes de cada sesion para obtener consentimiento informado.',
                  ).small(),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        const Text('Consentimiento informado').semiBold(),
        const Gap(8),
        TextField(
          controller: consentController,
          placeholder: const Text('Escribe el consentimiento...'),
          maxLines: 12,
        ),
        const Gap(6),
        Text('Caracteres: $consentLength').small().muted(),
      ],
    );
  }
}


