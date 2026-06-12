import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/survey_draft_models.dart';

/// Tarjeta editable para un rango de interpretación de resultados.
class LevelEditorCard extends StatelessWidget {
  final LevelDraft draft;
  final int index;
  final VoidCallback onRemove;

  const LevelEditorCard({
    super.key,
    required this.draft,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              'Nivel ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          IconButton(
            icon: const Icon(material.Icons.delete_outline),
            variance: ButtonVariance.ghost,
            onPressed: onRemove,
          ),
        ]),
        const Gap(12),
        Row(children: [
          Expanded(
            child: TextField(
              controller: draft.minController,
              placeholder: const Text('Puntaje mínimo'),
              keyboardType: TextInputType.number,
            ),
          ),
          const Gap(8),
          Expanded(
            child: TextField(
              controller: draft.maxController,
              placeholder: const Text('Puntaje máximo'),
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
        const Gap(8),
        TextField(
          controller: draft.labelController,
          placeholder: const Text('Etiqueta (ej. "Riesgo bajo")'),
        ),
        const Gap(8),
        TextField(
          controller: draft.descController,
          placeholder: const Text('Descripción (opcional)'),
        ),
      ]),
    );
  }
}
