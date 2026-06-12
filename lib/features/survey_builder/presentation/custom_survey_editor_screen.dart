import 'package:flutter/material.dart' as material show Icons;
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
                Wrap(
                  spacing: 12,
                  children: _colorPresets.map((hex) {
                    final color = _parseColor(hex);
                    final selected = hex == _colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(color: Theme.of(context).colorScheme.foreground, width: 3)
                              : null,
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
