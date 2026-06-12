import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/survey_draft_models.dart';
import 'package:ssapp/features/surveys/shared/form/face_icon.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';

const _typeLabels = {
  FormFieldType.singleChoice: 'Opción única',
  FormFieldType.multiChoice: 'Opción múltiple',
  FormFieldType.scale: 'Escala numérica',
  FormFieldType.numeric: 'Numérico',
  FormFieldType.text: 'Texto libre',
};

bool _typeHasOptions(FormFieldType type) =>
    type == FormFieldType.singleChoice ||
    type == FormFieldType.multiChoice ||
    type == FormFieldType.scale ||
    type == FormFieldType.emojiScale;

/// Tipos de pregunta donde el doctor puede asignar una carita por opción.
bool _typeSupportsOptionEmoji(FormFieldType type) =>
    type == FormFieldType.singleChoice || type == FormFieldType.multiChoice;

/// Tarjeta editable para una pregunta de la encuesta personalizada.
class QuestionEditorCard extends StatefulWidget {
  final QuestionDraft draft;
  final int index;
  final Color color;
  final VoidCallback onRemove;

  const QuestionEditorCard({
    super.key,
    required this.draft,
    required this.index,
    required this.color,
    required this.onRemove,
  });

  @override
  State<QuestionEditorCard> createState() => _QuestionEditorCardState();
}

class _QuestionEditorCardState extends State<QuestionEditorCard> {
  QuestionDraft get _d => widget.draft;

  void _setType(FormFieldType type) {
    setState(() => _d.type = type);
  }

  void _addOption() {
    setState(() => _d.options.add(OptionDraft(value: _d.options.length)));
  }

  void _setOptionEmoji(OptionDraft option, String? emoji) {
    setState(() => option.emoji = option.emoji == emoji ? null : emoji);
  }

  void _removeOption(int i) {
    setState(() {
      _d.options[i].dispose();
      _d.options.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasOptions = _typeHasOptions(_d.type);

    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              'Pregunta ${widget.index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          IconButton(
            icon: const Icon(material.Icons.delete_outline),
            variance: ButtonVariance.ghost,
            onPressed: widget.onRemove,
          ),
        ]),
        const Gap(12),
        TextField(
          controller: _d.labelController,
          placeholder: const Text('Texto de la pregunta'),
        ),
        const Gap(8),
        TextField(
          controller: _d.categoryController,
          placeholder: const Text('Categoría / sección (opcional)'),
        ),
        const Gap(12),
        const Text('Tipo de respuesta').semiBold().small(),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _typeLabels.entries.map((entry) {
            final selected = entry.key == _d.type;
            return selected
                ? PrimaryButton(onPressed: () => _setType(entry.key), child: Text(entry.value))
                : OutlineButton(onPressed: () => _setType(entry.key), child: Text(entry.value));
          }).toList(),
        ),
        if (hasOptions) ...[
          const Gap(16),
          const Text('Opciones de respuesta').semiBold().small(),
          const Gap(8),
          ..._d.options.asMap().entries.map((entry) {
            final i = entry.key;
            final option = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: option.labelController,
                      placeholder: const Text('Texto de la opción'),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: option.valueController,
                      placeholder: const Text('Puntaje'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(material.Icons.close),
                    variance: ButtonVariance.ghost,
                    onPressed: () => _removeOption(i),
                  ),
                ]),
                if (_typeSupportsOptionEmoji(_d.type)) ...[
                  const Gap(6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: const Text('Carita:').muted().small(),
                      ),
                      ...faceIconKeys.map((key) {
                        final selected = option.emoji == key;
                        final icon = Icon(faceIconForKey(key), size: 18, color: faceColorForKey(key));
                        return selected
                            ? PrimaryButton(
                                onPressed: () => _setOptionEmoji(option, key),
                                child: icon,
                              )
                            : OutlineButton(
                                onPressed: () => _setOptionEmoji(option, key),
                                child: icon,
                              );
                      }),
                      OutlineButton(
                        onPressed: () => _setOptionEmoji(option, null),
                        child: const Text('Sin carita'),
                      ),
                    ],
                  ),
                ],
              ]),
            );
          }),
          OutlineButton(
            onPressed: _addOption,
            child: const Text('+ Agregar opción'),
          ),
        ],
      ]),
    );
  }
}
