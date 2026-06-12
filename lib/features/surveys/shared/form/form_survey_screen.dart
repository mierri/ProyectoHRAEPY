import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/shared/form/face_icon.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_controller.dart';
import 'package:ssapp/features/surveys/shared/form/survey_text_field.dart';
import 'package:ssapp/features/surveys/shared/widgets/survey_form_dialogs.dart';
import 'package:ssapp/features/surveys/shared/widgets/survey_form_wizard.dart';
import 'package:ssapp/features/surveys/presentation/survey_controller.dart';
import 'package:ssapp/shared/providers/font_size_provider.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';
import 'package:ssapp/shared/widgets/font_size_button.dart';

class FormSurveyScreen extends StatefulWidget {
  final List<FormQuestion> questions;
  final FormSurveyController controller;
  final Color color;
  final void Function(BuildContext context, int? investigationId) onComplete;

  const FormSurveyScreen({
    super.key,
    required this.questions,
    required this.controller,
    required this.color,
    required this.onComplete,
  });

  @override
  State<FormSurveyScreen> createState() => _FormSurveyScreenState();
}

class _FormSurveyScreenState extends State<FormSurveyScreen> {
  int _currentIndex = 0;
  final Map<int, TextEditingController> _textControllers = {};

  FormSurveyController get _c => widget.controller;
  List<FormQuestion> get _questions => widget.questions;
  Color get _color => widget.color;

  @override
  void dispose() {
    for (final tc in _textControllers.values) {
      tc.dispose();
    }
    super.dispose();
  }

  TextEditingController _tcFor(int fieldId, {String initial = ''}) {
    return _textControllers.putIfAbsent(
      fieldId,
      () => TextEditingController(text: initial),
    );
  }

  // ── Visibility ──────────────────────────────────────────────────────────────

  bool _isVisible(FormFieldDef f) {
    if (f is! FormConditionalField) return true;
    if (f.showWhenEquals != null) {
      return _c.intAnswer(f.watchFieldId) == f.showWhenEquals;
    }
    if (f.showWhenContains != null) {
      return _c.multiAnswer(f.watchFieldId).contains(f.showWhenContains);
    }
    return false;
  }

  // ── Answer checking ──────────────────────────────────────────────────────────

  bool _isQuestionAnswered(int i) {
    for (final f in _questions[i].fields) {
      if (!f.isRequired) continue;
      if (!_isVisible(f)) continue;
      if (!_c.isAnswered(f.fieldId)) return false;
    }
    return true;
  }

  bool get _canGoNext => _isQuestionAnswered(_currentIndex);

  // ── Auto-advance ─────────────────────────────────────────────────────────────

  void _tryAutoAdvance() {
    final q = _questions[_currentIndex];
    final isSimple = q.fields.length == 1 &&
        q.fields[0].type == FormFieldType.singleChoice;
    final noConditionalVisible = !q.fields.any(
      (f) => f is FormConditionalField && _isVisible(f) && f.isRequired,
    );
    if (isSimple && noConditionalVisible && _currentIndex < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _currentIndex++);
      });
    }
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void _goToQuestion(int i) => setState(() => _currentIndex = i);

  void _goToPrevious() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  void _goToNextOrSave() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _saveSurvey();
    }
  }

  Future<void> _confirmExit(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dctx) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Salir del cuestionario?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const Gap(12),
                const Text('Se perderá el progreso no guardado.'),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        onPressed: () => Navigator.of(dctx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () => Navigator.of(dctx).pop(true),
                        child: const Text('Salir'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _saveSurvey() async {
    if (_c.isSaving) return;
    if (mounted) showSurveyFormSavingDialog(context);

    final SurveySaveResult result = await _c.saveSurvey();

    if (mounted) Navigator.of(context).pop();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!result.success) {
      if (mounted) {
        showCenteredToast(
          context,
          title: 'Error',
          subtitle: result.error ?? 'No se pudo guardar la encuesta.',
          icon: Icons.error_outline,
          iconColor: LightModeColors.lightError,
          location: ToastLocation.topCenter,
        );
      }
      return;
    }

    if (mounted) {
      showSurveyFormCompletionDialog(
        context,
        wasSynced: result.wasSynced,
        onContinue: () => widget.onComplete(context, _c.investigationId),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final isLast = _currentIndex == _questions.length - 1;

    return Scaffold(
      headers: [
        AppBar(
          title: Text('Pregunta ${_currentIndex + 1} de ${_questions.length}'),
          leading: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _confirmExit(context),
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: [
            const FontSizeButton(),
          ],
        ),
        FormStepProgressBar(
          progress: (_currentIndex + 1) / _questions.length,
          color: _color,
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormQuestionCard(
                    number: q.number,
                    category: q.category,
                    label: q.label,
                    color: _color,
                  ),
                  const Gap(24),
                  ..._buildFields(q),
                  const Gap(28),
                  FormStepPagination(
                    currentStep: _currentIndex,
                    totalSteps: _questions.length,
                    isStepAnswered: _isQuestionAnswered,
                    onStepTapped: _goToQuestion,
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ),
          FormStepNavBar(
            canGoPrevious: _currentIndex > 0,
            canGoNext: _canGoNext,
            isLastStep: isLast,
            isSaving: _c.isSaving,
            color: _color,
            onPrevious: _goToPrevious,
            onNext: _goToNextOrSave,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields(FormQuestion q) {
    final widgets = <Widget>[];
    for (int i = 0; i < q.fields.length; i++) {
      final f = q.fields[i];
      if (!_isVisible(f)) continue;
      if (widgets.isNotEmpty) widgets.add(const Gap(20));
      widgets.add(_buildFieldWidget(f, q));
    }
    return widgets;
  }

  Widget _buildFieldWidget(FormFieldDef f, FormQuestion q) {
    switch (f.type) {
      case FormFieldType.singleChoice:
        return _buildSingleChoice(f, q);
      case FormFieldType.multiChoice:
        return _buildMultiChoice(f);
      case FormFieldType.text:
        return _buildTextField(f, numeric: false);
      case FormFieldType.numeric:
        return _buildTextField(f, numeric: true);
      case FormFieldType.scale:
        return _buildScale(f);
      case FormFieldType.emojiScale:
        return _buildEmojiScale(f);
    }
  }

  // ── Single choice ─────────────────────────────────────────────────────────

  Widget _buildSingleChoice(FormFieldDef f, FormQuestion q) {
    final selected = _c.intAnswer(f.fieldId);
    final showLabel = q.fields.where((ff) => ff is! FormConditionalField).length > 1 ||
        q.fields.any((ff) => ff is FormConditionalField);
    final fs = context.watch<FontSizeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel && f is! FormConditionalField) ...[
          Text(f.label, style: TextStyle(fontSize: fs.scaled(14), fontWeight: FontWeight.w500)),
          const Gap(10),
        ],
        ...f.options.map((option) {
          final isSelected = selected == option.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FormOptionCard(
              label: option.label,
              emoji: option.emoji,
              isSelected: isSelected,
              color: _color,
              onTap: () {
                _c.setIntAnswer(f.fieldId, option.value);
                _tryAutoAdvance();
              },
            ),
          );
        }),
      ],
    );
  }

  // ── Multi choice ──────────────────────────────────────────────────────────

  Widget _buildMultiChoice(FormFieldDef f) {
    final selected = _c.multiAnswer(f.fieldId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: f.options.map((option) {
        final isSelected = selected.contains(option.value);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _FormMultiOptionCard(
            label: option.label,
            isSelected: isSelected,
            color: _color,
            onTap: () {
              final current = Set<int>.from(selected);
              final exclusive = f.exclusiveValue;
              if (isSelected) {
                current.remove(option.value);
              } else {
                if (exclusive != null && option.value == exclusive) {
                  current.clear();
                } else if (exclusive != null) {
                  current.remove(exclusive);
                }
                current.add(option.value);
              }
              _c.setMultiAnswer(f.fieldId, current);
            },
          ),
        );
      }).toList(),
    );
  }

  // ── Text / numeric ────────────────────────────────────────────────────────

  Widget _buildTextField(FormFieldDef f, {required bool numeric}) {
    final tc = _tcFor(
      f.fieldId,
      initial: numeric
          ? (_c.intAnswer(f.fieldId)?.toString() ?? '')
          : (_c.textAnswer(f.fieldId) ?? ''),
    );
    return SurveyTextField(
      label: f.label,
      controller: tc,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
      onChanged: (v) {
        if (numeric) {
          _c.setIntAnswer(f.fieldId, int.tryParse(v.trim()));
          _c.setTextAnswer(f.fieldId, v.trim());
        } else {
          _c.setTextAnswer(f.fieldId, v);
        }
      },
    );
  }

  // ── Scale 1-5 ─────────────────────────────────────────────────────────────

  Widget _buildScale(FormFieldDef f) {
    final selected = _c.intAnswer(f.fieldId);
    final fs = context.watch<FontSizeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label, style: TextStyle(fontSize: fs.scaled(13), color: const Color(0xFF6B7280))),
        const Gap(14),
        Row(
          children: List.generate(5, (i) {
            final value = i + 1;
            final isSelected = selected == value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 4 ? 8 : 0),
                child: _FormScaleButton(
                  value: value,
                  isSelected: isSelected,
                  color: _color,
                  onTap: () => setState(() {
                    _c.setIntAnswer(f.fieldId, value);
                    _c.setTextAnswer(f.fieldId, value.toString());
                  }),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Escala de caritas/emoji ──────────────────────────────────────────────

  Widget _buildEmojiScale(FormFieldDef f) {
    final selected = _c.intAnswer(f.fieldId);
    final fs = context.watch<FontSizeProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label, style: TextStyle(fontSize: fs.scaled(13), color: const Color(0xFF6B7280))),
        const Gap(14),
        Row(
          children: List.generate(f.options.length, (i) {
            final option = f.options[i];
            final isSelected = selected == option.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < f.options.length - 1 ? 8 : 0),
                child: _FormEmojiScaleButton(
                  emoji: option.label,
                  isSelected: isSelected,
                  color: _color,
                  onTap: () {
                    _c.setIntAnswer(f.fieldId, option.value);
                    _tryAutoAdvance();
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── _FormQuestionCard ──────────────────────────────────────────────────────────

class _FormQuestionCard extends StatelessWidget {
  final String number;
  final String category;
  final String label;
  final Color color;

  const _FormQuestionCard({
    required this.number,
    required this.category,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FontSizeProvider>();
    return OutlinedContainer(
      backgroundColor: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fs.scaled(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: fs.scaled(13),
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
                const Gap(6),
                Text(
                  label,
                  style: TextStyle(fontSize: fs.scaled(17), fontWeight: FontWeight.w600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _FormOptionCard ────────────────────────────────────────────────────────────

class _FormOptionCard extends StatefulWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FormOptionCard({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FormOptionCard> createState() => _FormOptionCardState();
}

class _FormOptionCardState extends State<_FormOptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FontSizeProvider>();
    return GestureDetector(
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) {
        _anim.reverse();
        widget.onTap();
      },
      onTapCancel: () => _anim.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: OutlinedContainer(
          backgroundColor:
              widget.isSelected ? widget.color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(16),
          borderColor: widget.isSelected
              ? widget.color
              : LightModeColors.lightOutline.withValues(alpha: 0.5),
          borderWidth: widget.isSelected ? 2.5 : 1.5,
          child: Row(
            children: [
              if (faceIconForKey(widget.emoji) != null) ...[
                Icon(faceIconForKey(widget.emoji), size: fs.scaled(22), color: faceColorForKey(widget.emoji)),
                const Gap(12),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: fs.scaled(15),
                    height: 1.4,
                    color: widget.isSelected
                        ? widget.color.withValues(alpha: 0.9)
                        : LightModeColors.lightOnSurface,
                  ),
                ),
              ),
              if (widget.isSelected) ...[
                const Gap(8),
                Icon(Icons.check_circle_rounded, color: widget.color, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── _FormMultiOptionCard ───────────────────────────────────────────────────────

class _FormMultiOptionCard extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FormMultiOptionCard({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_FormMultiOptionCard> createState() => _FormMultiOptionCardState();
}

class _FormMultiOptionCardState extends State<_FormMultiOptionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FontSizeProvider>();
    return GestureDetector(
      onTapDown: (_) => _anim.forward(),
      onTapUp: (_) {
        _anim.reverse();
        widget.onTap();
      },
      onTapCancel: () => _anim.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: OutlinedContainer(
          backgroundColor:
              widget.isSelected ? widget.color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(16),
          borderColor: widget.isSelected
              ? widget.color
              : LightModeColors.lightOutline.withValues(alpha: 0.5),
          borderWidth: widget.isSelected ? 2.5 : 1.5,
          child: Row(
            children: [
              Icon(
                widget.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: widget.isSelected
                    ? widget.color
                    : LightModeColors.lightOutline,
                size: 22,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: fs.scaled(15),
                    height: 1.4,
                    color: widget.isSelected
                        ? widget.color.withValues(alpha: 0.9)
                        : LightModeColors.lightOnSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _FormScaleButton ───────────────────────────────────────────────────────────

class _FormScaleButton extends StatelessWidget {
  final int value;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FormScaleButton({
    required this.value,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FontSizeProvider>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : LightModeColors.lightOutline.withValues(alpha: 0.5),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: fs.scaled(18),
              fontWeight: FontWeight.w600,
              color: isSelected ? color : LightModeColors.lightOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// ── _FormEmojiScaleButton ──────────────────────────────────────────────────────

class _FormEmojiScaleButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FormEmojiScaleButton({
    required this.emoji,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fs = context.watch<FontSizeProvider>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : LightModeColors.lightOutline.withValues(alpha: 0.5),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: fs.scaled(26)),
          ),
        ),
      ),
    );
  }
}
