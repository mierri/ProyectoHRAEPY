import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_service.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_basics_section.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_color_picker_dialog.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_colors.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_common.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_form_sections.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_overview.dart';
import 'package:ssapp/features/survey_builder/presentation/components/survey_draft_models.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

QuestionDraft _buildQuestionDraft() {
  return QuestionDraft(
    options: [
      OptionDraft(label: 'Opcion 1', value: 0),
      OptionDraft(label: 'Opcion 2', value: 1),
    ],
  );
}

class CustomSurveyEditorScreen extends StatefulWidget {
  final int? customSurveyId;

  const CustomSurveyEditorScreen({super.key, this.customSurveyId});

  @override
  State<CustomSurveyEditorScreen> createState() => _CustomSurveyEditorScreenState();
}

class _CustomSurveyEditorScreenState extends State<CustomSurveyEditorScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _colorHex = customSurveyColorPresets.first;
  bool _active = true;
  int? _id;
  List<QuestionDraft> _questions = [];
  List<LevelDraft> _levels = [];
  bool _initialized = false;
  bool _loading = true;

  bool get _hasBasics => _titleController.text.trim().isNotEmpty;

  bool get _hasValidQuestions {
    if (_questions.isEmpty) return false;
    for (final question in _questions) {
      if (question.labelController.text.trim().isEmpty) return false;
      final needsOptions =
          question.type != FormFieldType.text && question.type != FormFieldType.numeric;
      if (needsOptions) {
        if (question.options.isEmpty) return false;
        if (question.options.any((option) => option.labelController.text.trim().isEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  bool get _hasValidLevels {
    if (_levels.isEmpty) return false;
    for (final level in _levels) {
      final min = int.tryParse(level.minController.text.trim());
      final max = int.tryParse(level.maxController.text.trim());
      if (min == null || max == null || max < min) return false;
      if (level.labelController.text.trim().isEmpty) return false;
    }
    return true;
  }

  int get _completedSteps {
    var total = 0;
    if (_hasBasics) total++;
    if (_hasValidQuestions) total++;
    if (_hasValidLevels) total++;
    return total;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _load();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    for (final level in _levels) {
      level.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.customSurveyId == null) {
      setState(() {
        _questions = [_buildQuestionDraft()];
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
        _questions = [_buildQuestionDraft()];
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

  void _addQuestion() => setState(() => _questions.add(_buildQuestionDraft()));

  void _removeQuestion(int index) => setState(() {
        _questions[index].dispose();
        _questions.removeAt(index);
      });

  void _addLevel() => setState(() => _levels.add(LevelDraft()));

  void _removeLevel(int index) => setState(() {
        _levels[index].dispose();
        _levels.removeAt(index);
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

  Future<void> _pickColor() async {
    final selectedHex = await showDialog<String>(
      context: context,
      builder: (ctx) => CustomSurveyColorPickerDialog(initialHex: _colorHex),
    );
    if (selectedHex != null && mounted) {
      setState(() => _colorHex = selectedHex);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showError('Ingresa un titulo para la encuesta.');
      return;
    }
    if (_questions.isEmpty) {
      _showError('Agrega al menos una pregunta.');
      return;
    }
    for (final question in _questions) {
      if (question.labelController.text.trim().isEmpty) {
        _showError('Todas las preguntas deben tener texto.');
        return;
      }
      final needsOptions =
          question.type != FormFieldType.text && question.type != FormFieldType.numeric;
      if (needsOptions && question.options.isEmpty) {
        _showError('"${question.labelController.text.trim()}" necesita al menos una opcion.');
        return;
      }
      if (needsOptions &&
          question.options.any((option) => option.labelController.text.trim().isEmpty)) {
        _showError('Completa el texto de cada opcion antes de guardar.');
        return;
      }
    }

    for (final level in _levels) {
      final min = int.tryParse(level.minController.text.trim());
      final max = int.tryParse(level.maxController.text.trim());
      if (min == null || max == null) {
        _showError('Los niveles deben tener puntajes minimos y maximos validos.');
        return;
      }
      if (max < min) {
        _showError('Cada nivel debe tener un puntaje maximo mayor o igual al minimo.');
        return;
      }
      if (level.labelController.text.trim().isEmpty) {
        _showError('Cada nivel debe tener una etiqueta.');
        return;
      }
    }

    final definition = CustomSurveyDefinition(
      id: _id ?? 0,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      colorHex: _colorHex,
      active: _active,
      questions: _questions.map((question) => question.toDef()).toList(),
      levels: _levels.map((level) => level.toDef()).toList(),
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
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 980;
                final content = _buildContent();

                if (!isWide) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [...content, _buildSidebar()],
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 10, child: Column(children: content)),
                            const Gap(24),
                            Expanded(flex: 4, child: _buildSidebar()),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  List<Widget> _buildContent() {
    return [
      CustomSurveyEditorHeroCard(
        colorHex: _colorHex,
        title: _titleController.text.trim().isEmpty
            ? 'Tu encuesta aun no tiene titulo'
            : _titleController.text.trim(),
        description: _descController.text.trim(),
        questionCount: _questions.length,
        levelCount: _levels.length,
        isActive: _active,
        completedSteps: _completedSteps,
      ),
      const Gap(20),
      CustomSurveyStepSection(
        index: 1,
        title: 'Configuracion',
        subtitle: 'Define la identidad de la encuesta antes de crear preguntas.',
        child: CustomSurveyBasicsSection(
          titleController: _titleController,
          descriptionController: _descController,
          colorHex: _colorHex,
          isActive: _active,
          onPickColor: _pickColor,
          onColorSelected: (hex) => setState(() => _colorHex = hex),
          onActiveChanged: (value) => setState(() => _active = value),
          onTitleChanged: (_) => setState(() {}),
          onDescriptionChanged: (_) => setState(() {}),
        ),
      ),
      const Gap(20),
      CustomSurveyStepSection(
        index: 2,
        title: 'Preguntas',
        subtitle: 'Ordena el formulario y deja claro como debe responderse.',
        child: CustomSurveyQuestionsSection(
          questions: _questions,
          colorHex: _colorHex,
          onAddQuestion: _addQuestion,
          onRemoveQuestion: _removeQuestion,
        ),
      ),
      const Gap(20),
      CustomSurveyStepSection(
        index: 3,
        title: 'Interpretacion',
        subtitle: 'Opcional, pero muy util para entender resultados al instante.',
        child: CustomSurveyLevelsSection(
          levels: _levels,
          onAddLevel: _addLevel,
          onRemoveLevel: _removeLevel,
        ),
      ),
      const Gap(32),
    ];
  }

  Widget _buildSidebar() {
    return CustomSurveyEditorSidebar(
      completedSteps: _completedSteps,
      questionCount: _questions.length,
      levelCount: _levels.length,
      hasBasics: _hasBasics,
      hasQuestions: _hasValidQuestions,
      hasLevels: _hasValidLevels,
    );
  }
}
