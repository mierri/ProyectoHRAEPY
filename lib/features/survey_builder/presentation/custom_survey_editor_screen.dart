import 'package:flutter/material.dart' as material
    show
        Icons,
        HSVColor,
        Slider,
        SliderTheme,
        RoundSliderThumbShape;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_service.dart';
import 'package:ssapp/features/survey_builder/presentation/components/level_editor_card.dart';
import 'package:ssapp/features/survey_builder/presentation/components/question_editor_card.dart';
import 'package:ssapp/features/survey_builder/presentation/components/survey_draft_models.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

const _colorPresets = [
  '#0D9488',
  '#0891B2',
  '#7C3AED',
  '#DB2777',
  '#EA580C',
  '#16A34A',
];

Color _parseColor(String hex) {
  var value = hex.replaceFirst('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

String _colorToHex(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

String? _normalizeHexInput(String raw) {
  final sanitized = raw.trim().replaceFirst('#', '').toUpperCase();
  final hexPattern = RegExp(r'^[0-9A-F]{6}$');
  if (!hexPattern.hasMatch(sanitized)) {
    return null;
  }
  return '#$sanitized';
}

/// Pantalla para crear o editar una encuesta personalizada.
class CustomSurveyEditorScreen extends StatefulWidget {
  final int? customSurveyId;

  const CustomSurveyEditorScreen({super.key, this.customSurveyId});

  @override
  State<CustomSurveyEditorScreen> createState() => _CustomSurveyEditorScreenState();
}

class _CustomSurveyEditorScreenState extends State<CustomSurveyEditorScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _colorHex = _colorPresets.first;
  bool _active = true;
  int? _id;
  List<QuestionDraft> _questions = [];
  List<LevelDraft> _levels = [];
  bool _initialized = false;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (widget.customSurveyId == null) {
      setState(() {
        _questions = [QuestionDraft()];
        _loading = false;
      });
      return;
    }

    final service = context.read<CustomSurveyService>();
    var definition = service.getById(widget.customSurveyId!);
    if (definition == null) {
      await service.loadAll();
      definition = service.getById(widget.customSurveyId!);
    }
    if (!mounted) return;

    if (definition == null) {
      setState(() {
        _questions = [QuestionDraft()];
        _loading = false;
      });
      return;
    }

    setState(() {
      _id = definition!.id;
      _titleController.text = definition.title;
      _descController.text = definition.description;
      _colorHex = definition.colorHex;
      _active = definition.active;
      _questions = definition.questions.map(QuestionDraft.fromDef).toList();
      _levels = definition.levels.map(LevelDraft.fromDef).toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    for (final l in _levels) {
      l.dispose();
    }
    super.dispose();
  }

  void _addQuestion() => setState(() => _questions.add(QuestionDraft()));

  void _removeQuestion(int i) => setState(() {
        _questions[i].dispose();
        _questions.removeAt(i);
      });

  void _addLevel() => setState(() => _levels.add(LevelDraft()));

  void _removeLevel(int i) => setState(() {
        _levels[i].dispose();
        _levels.removeAt(i);
      });

  void _showError(String message) {
    showCenteredToast(
      context,
      title: 'Revisa la encuesta',
      subtitle: message,
      icon: material.Icons.warning,
      iconColor: LightModeColors.lightError,
      location: ToastLocation.topCenter,
    );
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Ingresa un título para la encuesta');
      return;
    }
    if (_questions.isEmpty) {
      _showError('Agrega al menos una pregunta');
      return;
    }
    for (final q in _questions) {
      if (q.labelController.text.trim().isEmpty) {
        _showError('Todas las preguntas deben tener texto');
        return;
      }
      final needsOptions =
          q.type != FormFieldType.text && q.type != FormFieldType.numeric;
      if (needsOptions && q.options.isEmpty) {
        _showError('"${q.labelController.text.trim()}" necesita al menos una opción');
        return;
      }
    }

    final definition = CustomSurveyDefinition(
      id: _id ?? 0,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      colorHex: _colorHex,
      active: _active,
      questions: _questions.map((q) => q.toDef()).toList(),
      levels: _levels.map((l) => l.toDef()).toList(),
    );

    final service = context.read<CustomSurveyService>();
    if (_id == null) {
      await service.create(definition);
    } else {
      await service.update(definition);
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _pickColor() async {
    final selectedHex = await showDialog<String>(
      context: context,
      builder: (ctx) => _ColorPickerDialog(initialHex: _colorHex),
    );
    if (selectedHex != null && mounted) {
      setState(() => _colorHex = selectedHex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text(_id == null ? 'Nueva encuesta' : 'Editar encuesta'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => context.pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: [
            PrimaryButton(
              onPressed: _loading ? null : _save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Título de la encuesta').semiBold(),
                const Gap(8),
                TextField(
                  controller: _titleController,
                  placeholder: const Text('Ej. Escala de bienestar emocional'),
                ),
                const Gap(16),
                const Text('Descripción').semiBold(),
                const Gap(8),
                TextField(
                  controller: _descController,
                  placeholder: const Text('Descripción breve (opcional)'),
                ),
                const Gap(16),
                const Text('Color').semiBold(),
                const Gap(8),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(_colorHex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.foreground,
                          width: 2,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(child: Text(_colorHex).muted()),
                    OutlineButton(
                      onPressed: _pickColor,
                      child: const Text('Elegir color'),
                    ),
                  ],
                ),
                const Gap(12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colorPresets.map((hex) {
                    final color = _parseColor(hex);
                    final selected = hex == _colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.foreground
                                : color.withValues(alpha: 0.25),
                            width: selected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Gap(16),
                Row(children: [
                  Expanded(child: const Text('Encuesta activa').semiBold()),
                  Switch(
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                ]),
                const Gap(24),
                const Divider(),
                const Gap(24),
                const Text('Preguntas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const Gap(12),
                ..._questions.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuestionEditorCard(
                      key: ValueKey(entry.value.fieldId),
                      draft: entry.value,
                      index: entry.key,
                      color: _parseColor(_colorHex),
                      onRemove: () => _removeQuestion(entry.key),
                    ),
                  );
                }),
                OutlineButton(
                  onPressed: _addQuestion,
                  child: const Text('+ Agregar pregunta'),
                ),
                const Gap(24),
                const Divider(),
                const Gap(24),
                const Text('Interpretación de resultados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const Gap(8),
                Text(
                  'Define rangos de puntaje y su interpretación (ej. 0-4: Mínimo).',
                ).muted().small(),
                const Gap(12),
                ..._levels.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LevelEditorCard(
                      draft: entry.value,
                      index: entry.key,
                      onRemove: () => _removeLevel(entry.key),
                    ),
                  );
                }),
                OutlineButton(
                  onPressed: _addLevel,
                  child: const Text('+ Agregar nivel'),
                ),
                const Gap(24),
              ],
            ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final String initialHex;

  const _ColorPickerDialog({required this.initialHex});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _color;
  late material.HSVColor _hsv;
  late TextEditingController _hexController;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _color = _parseColor(widget.initialHex);
    _hsv = material.HSVColor.fromColor(_color);
    _hexController = TextEditingController(text: _colorToHex(_color));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateFromColor(Color color) {
    setState(() {
      _color = color;
      _hsv = material.HSVColor.fromColor(color);
      _hexController.text = _colorToHex(color);
      _hexError = null;
    });
  }

  void _updateFromHsv(material.HSVColor hsv) {
    _updateFromColor(hsv.toColor());
  }

  void _applyHex() {
    final normalized = _normalizeHexInput(_hexController.text);
    if (normalized == null) {
      setState(() => _hexError = 'Usa un color hex como #0D9488');
      return;
    }
    _updateFromColor(_parseColor(normalized));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Elegir color').textLarge().semiBold(),
              const Gap(8),
              const Text(
                'Ajusta el color con los controles o escribe un código hex.',
              ).muted(),
              const Gap(20),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.foreground,
                        width: 2,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_colorToHex(_color)).semiBold(),
                        const Gap(6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _colorPresets.map((hex) {
                            final preset = _parseColor(hex);
                            final selected = _colorToHex(preset) == _colorToHex(_color);
                            return GestureDetector(
                              onTap: () => _updateFromColor(preset),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: preset,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.foreground
                                        : preset.withValues(alpha: 0.25),
                                    width: selected ? 3 : 1,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),
              _ColorSliderRow(
                label: 'Tono',
                value: _hsv.hue,
                max: 360,
                onChanged: (value) => _updateFromHsv(_hsv.withHue(value)),
                activeColor: _color,
              ),
              const Gap(12),
              _ColorSliderRow(
                label: 'Saturación',
                value: _hsv.saturation,
                max: 1,
                onChanged: (value) => _updateFromHsv(_hsv.withSaturation(value)),
                activeColor: _color,
                percent: true,
              ),
              const Gap(12),
              _ColorSliderRow(
                label: 'Brillo',
                value: _hsv.value,
                max: 1,
                onChanged: (value) => _updateFromHsv(_hsv.withValue(value)),
                activeColor: _color,
                percent: true,
              ),
              const Gap(16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      placeholder: const Text('#0D9488'),
                    ),
                  ),
                  const Gap(10),
                  OutlineButton(
                    onPressed: _applyHex,
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
              if (_hexError != null) ...[
                const Gap(8),
                Text(
                  _hexError!,
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
              ],
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () => Navigator.of(context).pop(_colorToHex(_color)),
                      child: const Text('Usar color'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final Color activeColor;
  final bool percent;

  const _ColorSliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.activeColor,
    this.percent = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = percent
        ? '${(value * 100).round()}%'
        : value.round().toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label).semiBold()),
            Text(displayValue).muted().small(),
          ],
        ),
        material.SliderTheme(
          data: material.SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.15),
            thumbShape: const material.RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: material.Slider(
            value: value.clamp(0, max),
            min: 0,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
