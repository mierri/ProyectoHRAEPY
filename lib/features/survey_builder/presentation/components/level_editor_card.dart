import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/survey_draft_models.dart';

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
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(6),
                    const Text(
                      'Define el rango de puntaje y el mensaje que vera el equipo al revisar resultados.',
                      style: TextStyle(fontSize: 12),
                    ).muted(),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(material.Icons.delete_outline),
                variance: ButtonVariance.ghost,
                onPressed: onRemove,
              ),
            ],
          ),
          const Gap(14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.minController,
                  placeholder: const Text('Puntaje minimo'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const Gap(8),
              Expanded(
                child: TextField(
                  controller: draft.maxController,
                  placeholder: const Text('Puntaje maximo'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const Gap(8),
          TextField(
            controller: draft.labelController,
            placeholder: const Text('Etiqueta, por ejemplo: Riesgo bajo'),
          ),
          const Gap(8),
          TextField(
            controller: draft.descController,
            placeholder: const Text('Descripcion opcional para interpretar el nivel'),
          ),
        ],
      ),
    );
  }
}
