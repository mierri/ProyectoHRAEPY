import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/survey_draft_models.dart';
import 'package:ssapp/features/surveys/shared/form/face_icon.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';

const _typeLabels = {
  FormFieldType.singleChoice: 'Opcion unica',
  FormFieldType.multiChoice: 'Opcion multiple',
  FormFieldType.scale: 'Escala numerica',
  FormFieldType.emojiScale: 'Escala visual',
  FormFieldType.numeric: 'Numerico',
  FormFieldType.text: 'Texto libre',
};

const _typeDescriptions = {
  FormFieldType.singleChoice: 'El participante elige una sola opcion.',
  FormFieldType.multiChoice: 'Permite marcar varias opciones a la vez.',
  FormFieldType.scale: 'Ideal para escalas con valores progresivos.',
  FormFieldType.emojiScale: 'Hace la pregunta mas visual con apoyo de caritas.',
  FormFieldType.numeric: 'Captura cantidades o valores enteros.',
  FormFieldType.text: 'Permite una respuesta abierta.',
};

bool _typeHasOptions(FormFieldType type) =>
    type == FormFieldType.singleChoice ||
    type == FormFieldType.multiChoice ||
    type == FormFieldType.scale ||
    type == FormFieldType.emojiScale;

bool _typeSupportsOptionEmoji(FormFieldType type) =>
    type == FormFieldType.singleChoice ||
    type == FormFieldType.multiChoice ||
    type == FormFieldType.emojiScale;

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
    setState(() {
      _d.type = type;
      if (_typeHasOptions(type) && _d.options.isEmpty) {
        _d.options.addAll([
          OptionDraft(label: 'Opcion 1', value: 0),
          OptionDraft(label: 'Opcion 2', value: 1),
        ]);
      }
    });
  }

  void _addOption() {
    setState(() => _d.options.add(OptionDraft(value: _d.options.length)));
  }

  void _setOptionEmoji(OptionDraft option, String? emoji) {
    setState(() => option.emoji = option.emoji == emoji ? null : emoji);
  }

  void _removeOption(int index) {
    setState(() {
      _d.options[index].dispose();
      _d.options.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasOptions = _typeHasOptions(_d.type);
    final optionCount = _d.options.length;

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
                      'Pregunta ${widget.index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoPill(
                          label: _typeLabels[_d.type] ?? 'Pregunta',
                          color: widget.color,
                        ),
                        if (hasOptions)
                          _InfoPill(
                            label: '$optionCount opcion${optionCount == 1 ? '' : 'es'}',
                            color: const Color(0xFF64748B),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(material.Icons.delete_outline),
                variance: ButtonVariance.ghost,
                onPressed: widget.onRemove,
              ),
            ],
          ),
          const Gap(14),
          TextField(
            controller: _d.labelController,
            placeholder: const Text('Texto de la pregunta'),
          ),
          const Gap(8),
          TextField(
            controller: _d.categoryController,
            placeholder: const Text('Categoria o seccion (opcional)'),
          ),
          const Gap(12),
          Text('Tipo de respuesta').semiBold().small(),
          const Gap(6),
          Text(
            _typeDescriptions[_d.type] ?? '',
            style: const TextStyle(fontSize: 12),
          ).muted(),
          const Gap(10),
          Select<FormFieldType>(
            value: _d.type,
            onChanged: (value) {
              if (value != null) {
                _setType(value);
              }
            },
            itemBuilder: (context, item) => Text(_typeLabels[item] ?? 'Pregunta'),
            popup: SelectPopup(
              items: SelectItemList(
                children: _typeLabels.entries
                    .map(
                      (entry) => SelectItemButton<FormFieldType>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
              ),
            ).call,
            placeholder: const Text('Selecciona el tipo de respuesta'),
          ),
          if (hasOptions) ...[
            const Gap(16),
            Text('Opciones de respuesta').semiBold().small(),
            const Gap(8),
            if (_d.type == FormFieldType.scale || _d.type == FormFieldType.emojiScale)
              const Text(
                'Tip: usa valores consecutivos para que la interpretacion final sea mas clara.',
                style: TextStyle(fontSize: 12),
              ).muted(),
            if (_d.type == FormFieldType.scale || _d.type == FormFieldType.emojiScale)
              const Gap(8),
            ..._d.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: option.labelController,
                            placeholder: const Text('Texto de la opcion'),
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
                          onPressed: () => _removeOption(index),
                        ),
                      ],
                    ),
                    if (_typeSupportsOptionEmoji(_d.type)) ...[
                      const Gap(6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text('Carita:').muted().small(),
                          ),
                          ...faceIconKeys.map((key) {
                            final selected = option.emoji == key;
                            final icon = Icon(
                              faceIconForKey(key),
                              size: 18,
                              color: faceColorForKey(key),
                            );
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
                  ],
                ),
              );
            }),
            OutlineButton(
              onPressed: _addOption,
              child: const Text('+ Agregar opcion'),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
