import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class InvestigationsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const InvestigationsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(material.Icons.search, size: 18),
        const Gap(8),
        Expanded(
          child: TextField(
            controller: controller,
            placeholder: const Text('Buscar por nombre o ID de investigacion...'),
            onChanged: onChanged,
          ),
        ),
        if (controller.text.trim().isNotEmpty) ...[
          const Gap(8),
          IconButton(
            icon: const Icon(material.Icons.close),
            variance: ButtonVariance.ghost,
            onPressed: onClear,
          ),
        ],
      ],
    );
  }
}

