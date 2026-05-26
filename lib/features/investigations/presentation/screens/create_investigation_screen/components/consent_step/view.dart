import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class InvestigationConsentStep extends StatefulWidget {
  final TextEditingController consentController;
  final List<String> checkboxLabels;
  final ValueChanged<List<String>> onCheckboxesChanged;

  const InvestigationConsentStep({
    super.key,
    required this.consentController,
    required this.checkboxLabels,
    required this.onCheckboxesChanged,
  });

  @override
  State<InvestigationConsentStep> createState() => _InvestigationConsentStepState();
}

class _InvestigationConsentStepState extends State<InvestigationConsentStep> {
  final List<TextEditingController> _checkboxControllers = [];

  @override
  void initState() {
    super.initState();
    for (final label in widget.checkboxLabels) {
      _checkboxControllers.add(TextEditingController(text: label));
    }
  }

  @override
  void dispose() {
    for (final c in _checkboxControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCheckbox() {
    setState(() {
      _checkboxControllers.add(TextEditingController());
    });
    _notifyParent();
  }

  void _removeCheckbox(int index) {
    setState(() {
      _checkboxControllers[index].dispose();
      _checkboxControllers.removeAt(index);
    });
    _notifyParent();
  }

  void _notifyParent() {
    final labels = _checkboxControllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    widget.onCheckboxesChanged(labels);
  }

  @override
  Widget build(BuildContext context) {
    final consentLength = widget.consentController.text.trim().length;

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
                  child: Text(
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
          controller: widget.consentController,
          placeholder: const Text('Escribe el consentimiento...'),
          maxLines: 12,
        ),
        const Gap(6),
        Text('Caracteres: $consentLength').small().muted(),

        const Gap(24),
        const Text('Checkboxes adicionales').semiBold(),
        const Gap(4),
        const Text(
          'El participante debe marcar estos checkboxes antes de poder continuar.',
        ).small().muted(),
        const Gap(12),

        for (int i = 0; i < _checkboxControllers.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _checkboxControllers[i],
                  placeholder: const Text('Texto del checkbox...'),
                  maxLines: 2,
                  onChanged: (_) => _notifyParent(),
                ),
              ),
              const Gap(8),
              IconButton(
                icon: const Icon(material.Icons.remove_circle_outline, size: 20),
                variance: ButtonVariance.ghost,
                onPressed: () => _removeCheckbox(i),
              ),
            ],
          ),
          const Gap(8),
        ],

        OutlineButton(
          onPressed: _addCheckbox,
          leading: const Icon(material.Icons.add, size: 16),
          child: const Text('Agregar checkbox'),
        ),
      ],
    );
  }
}
