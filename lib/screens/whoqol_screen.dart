import 'package:flutter/material.dart' as material
    show Icons, Material, Colors, Navigator, BoxDecoration, BoxShadow, BorderRadius, Offset;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/controllers/whoqol_controller.dart';
import 'package:ssapp/models/whoqol_questions.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/toast_helper.dart';

const _kWhoqolColor = Color(0xFF7C3AED);

class WhoqolScreen extends StatefulWidget {
  final int patientId;
  const WhoqolScreen({super.key, required this.patientId});

  @override
  State<WhoqolScreen> createState() => _WhoqolScreenState();
}

class _WhoqolScreenState extends State<WhoqolScreen> {
  late WhoqolController _controller;

  @override
  void initState() {
    super.initState();
    final surveyService = context.read<SurveyService>();
    _controller = WhoqolController(
      patientId: widget.patientId,
      surveyService: surveyService,
    );
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  WhoqolQuestion get _current => _controller.currentQuestion;

  void _selectOption(int questionNumber, int rawScore, int optionIndex) {
    _controller.selectOption(questionNumber, rawScore, optionIndex);
    
    showCenteredToast(
      context,
      title: 'Respuesta guardada',
      icon: material.Icons.check_circle,
      iconColor: _kWhoqolColor,
      location: ToastLocation.topCenter,
    );
    
    if (!_controller.isLastQuestion) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _controller.canGoNext) {
          _controller.nextQuestion();
        }
      });
    }
  }

  void _nextQuestion() {
    if (!_controller.isLastQuestion) {
      _controller.nextQuestion();
    } else {
      _saveSurvey();
    }
  }

  void _previousQuestion() {
    _controller.previousQuestion();
  }

  void _goToQuestion(int index) {
    _controller.goToQuestion(index);
  }

  Future<void> _saveSurvey() async {
    if (_controller.isSaving) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: material.Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const Gap(16),
                const Text(
                  'Guardando encuesta WHOQOL...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = await _controller.saveSurvey();

    if (mounted) {
      material.Navigator.of(context).pop(); // Cerrar diálogo de carga
    }

    await Future.delayed(const Duration(milliseconds: 100));

    if (!result.success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudo guardar la encuesta: ${result.error}'),
            actions: [
              PrimaryButton(
                onPressed: () => material.Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (mounted && result.results != null) {
      _showCompletionDialog(result.wasSynced, result.results!);
    }
  }

  void _showCompletionDialog(bool wasSynced, WhoqolResults results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(24),
          decoration: material.BoxDecoration(
            color: material.Colors.white,
            borderRadius: material.BorderRadius.circular(16),
            boxShadow: [
              material.BoxShadow(
                color: material.Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const material.Offset(0, 8),
              ),
            ],
          ),
          child: material.Material(
            color: material.Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(material.Icons.celebration, color: _kWhoqolColor, size: 32),
                      const Gap(12),
                      const Expanded(
                        child: Text(
                          '¡Gracias por participar!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const Text(
                    'La encuesta ha sido completada exitosamente.',
                    style: TextStyle(fontSize: 15),
                  ),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wasSynced
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: wasSynced
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          wasSynced ? material.Icons.cloud_done : material.Icons.cloud_upload,
                          color: wasSynced ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            wasSynced ? 'Datos sincronizados' : 'Pendiente de sincronización',
                            style: TextStyle(
                              fontSize: 13,
                              color: wasSynced ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    '¿Desea ver su resultado?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlineButton(
                          onPressed: () {
                            material.Navigator.of(ctx).pop();
                            context.go('/new-survey');
                          },
                          child: const Text('No'),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () {
                            material.Navigator.of(ctx).pop();
                            _showResultDialog(wasSynced, results);
                          },
                          child: const Text('Sí'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResultDialog(bool wasSynced, WhoqolResults results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          margin: const EdgeInsets.all(24),
          decoration: material.BoxDecoration(
            color: material.Colors.white,
            borderRadius: material.BorderRadius.circular(20),
            boxShadow: [
              material.BoxShadow(color: material.Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const material.Offset(0, 8)),
            ],
          ),
          child: material.Material(
            color: material.Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: _kWhoqolColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: const Icon(material.Icons.analytics, color: _kWhoqolColor, size: 28),
                      ),
                      const Gap(12),
                      const Expanded(child: Text('Resultado WHOQOL-BREF', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const Gap(20),
                  const Text('Ítems Globales', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const Gap(8),
                  _ResultRow(label: 'Calidad de vida (P1)', value: results.q1Interpretation, color: _kWhoqolColor),
                  _ResultRow(label: 'Satisfacción con la salud (P2)', value: results.q2Display, color: _kWhoqolColor),
                  const Gap(16),
                  const Text('Puntajes por Dominio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const Gap(2),
                  const Text('Mayor puntaje = mejor calidad de vida', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const Gap(8),
                  _ResultRow(label: 'Salud Física (DOM1)', value: results.domain1Display(), color: const Color(0xFF0EA5E9)),
                  _ResultRow(label: 'Salud Psicológica (DOM2)', value: results.domain2Display(), color: const Color(0xFF8B5CF6)),
                  _ResultRow(label: 'Relaciones Sociales (DOM3)', value: results.domain3Display(), color: const Color(0xFF10B981)),
                  _ResultRow(label: 'Ambiente (DOM4)', value: results.domain4Display(), color: const Color(0xFFF59E0B)),
                  const Gap(16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: wasSynced
                          ? const Color(0xFF10B981).withValues(alpha: 0.06)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: wasSynced
                            ? const Color(0xFF10B981).withValues(alpha: 0.25)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          wasSynced ? material.Icons.check_circle : material.Icons.cloud_off,
                          color: wasSynced ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            wasSynced ? 'Datos sincronizados.' : 'Sincronización pendiente.',
                            style: const TextStyle(fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () { material.Navigator.of(ctx).pop(); context.go('/new-survey'); },
                      child: const Text('Finalizar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = WhoqolQuestions.labelsFor(_current.scaleType);
    final progress = _controller.progress;
    final isReversedQuestion = _current.reversed; // true para Q3, Q4, Q26

    return Scaffold(
      headers: [
        AppBar(
          title: Text('Pregunta ${_controller.currentIndex + 1} de ${_controller.questions.length}'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dlg) => AlertDialog(
                    title: const Text('¿Salir del cuestionario?'),
                    content: const Text('Si sales ahora perderás el progreso. ¿Estás seguro?'),
                    actions: [
                      OutlineButton(onPressed: () => material.Navigator.of(dlg).pop(), child: const Text('Cancelar')),
                      DestructiveButton(onPressed: () { material.Navigator.of(dlg).pop(); context.go('/'); }, child: const Text('Salir')),
                    ],
                  ),
                );
              },
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          Container(
            height: 6,
            decoration: const BoxDecoration(color: Color(0xFFEDE9FE)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(color: _kWhoqolColor),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionBadge(scaleType: _current.scaleType),
                  const Gap(16),
                  OutlinedContainer(
                    backgroundColor: _kWhoqolColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    padding: const EdgeInsets.all(20),
                    borderColor: _kWhoqolColor.withValues(alpha: 0.3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(color: _kWhoqolColor, shape: BoxShape.circle),
                          child: Center(
                            child: Text('${_current.number}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const Gap(14),
                        Expanded(child: Text(_current.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5))),
                      ],
                    ),
                  ),
                  const Gap(24),
                  ...labels.asMap().entries.map((entry) {
                    final optIdx = entry.key;
                    final label = entry.value;
                    final rawScore = optIdx + 1;
                    final isSelected = _controller.selectedOptionIndex == optIdx;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _WhoqolOptionCard(
                        label: label,
                        score: rawScore,
                        optionIndex: optIdx,
                        totalOptions: labels.length,
                        isReversedIcons: isReversedQuestion,
                        isSelected: isSelected,
                        onTap: () => _selectOption(_current.number, rawScore, optIdx),
                      ),
                    );
                  }),
                  const Gap(24),
                  _WhoqolPagination(
                    currentIndex: _controller.currentIndex,
                    totalQuestions: _controller.questions.length,
                    responses: _controller.responses,
                    onPageChanged: _goToQuestion,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                if (_controller.canGoPrevious) ...[
                  Expanded(
                    child: OutlineButton(
                      onPressed: _previousQuestion,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(material.Icons.arrow_back, color: _kWhoqolColor, size: 20),
                          const Gap(8),
                          const Text('Anterior', style: TextStyle(color: _kWhoqolColor)),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                ],
                Expanded(
                  child: PrimaryButton(
                    onPressed: _controller.canGoNext ? _nextQuestion : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_controller.isLastQuestion ? 'Finalizar' : 'Siguiente'),
                        const Gap(8),
                        Icon(_controller.isLastQuestion ? material.Icons.check : material.Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  final WhoqolScaleType scaleType;
  const _SectionBadge({required this.scaleType});

  String get _label {
    switch (scaleType) {
      case WhoqolScaleType.qualityOfLife: return 'Calidad de vida global';
      case WhoqolScaleType.intensity: return 'Últimas dos semanas';
      case WhoqolScaleType.capacity: return 'Capacidad / Disponibilidad';
      case WhoqolScaleType.satisfaction: return 'Satisfacción';
      case WhoqolScaleType.frequency: return 'Frecuencia';
    }
  }

  IconData get _icon {
    switch (scaleType) {
      case WhoqolScaleType.qualityOfLife: return Symbols.star;
      case WhoqolScaleType.intensity: return Symbols.calendar_month;
      case WhoqolScaleType.capacity: return Symbols.fitness_center;
      case WhoqolScaleType.satisfaction: return Symbols.sentiment_satisfied;
      case WhoqolScaleType.frequency: return Symbols.repeat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _kWhoqolColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kWhoqolColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _kWhoqolColor, size: 16),
          const Gap(6),
          Text(_label, style: const TextStyle(color: _kWhoqolColor, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _WhoqolOptionCard extends StatefulWidget {
  final String label;
  final int score;
  final int optionIndex;
  final int totalOptions;
  final bool isReversedIcons;
  final bool isSelected;
  final VoidCallback onTap;

  const _WhoqolOptionCard({
    required this.label,
    required this.score,
    required this.optionIndex,
    required this.totalOptions,
    required this.isReversedIcons,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_WhoqolOptionCard> createState() => _WhoqolOptionCardState();
}

class _WhoqolOptionCardState extends State<_WhoqolOptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _optionColor {
    const colors = [Color(0xFFDC2626), Color(0xFFEA580C), Color(0xFFF59E0B), Color(0xFF65A30D), Color(0xFF16A34A)];
    // isReversedIcons=false (normal Qs): index 0 = red (worst), index 4 = green (best)
    // isReversedIcons=true (Q3/4/26):   index 0 = green (no pain = good), cambiar orden
    final idx = widget.isReversedIcons
        ? (colors.length - 1 - widget.optionIndex).clamp(0, colors.length - 1)
        : widget.optionIndex.clamp(0, colors.length - 1);
    return colors[idx];
  }

  IconData get _icon {
    const icons = [Symbols.sentiment_very_dissatisfied, Symbols.sentiment_dissatisfied, Symbols.sentiment_neutral, Symbols.sentiment_satisfied, Symbols.sentiment_very_satisfied];
    // isReversedIcons=false (normal Qs): index 0 = very_dissatisfied (worst)
    // isReversedIcons=true (Q3/4/26):   index 0 = very_satisfied (no pain = good), cambiar orden
    final idx = widget.isReversedIcons
        ? (icons.length - 1 - widget.optionIndex).clamp(0, icons.length - 1)
        : widget.optionIndex.clamp(0, icons.length - 1);
    return icons[idx];
  }

  @override
  Widget build(BuildContext context) {
    final color = _optionColor;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: OutlinedContainer(
          backgroundColor: widget.isSelected ? _kWhoqolColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(14),
          borderColor: widget.isSelected ? _kWhoqolColor : LightModeColors.lightOutline.withValues(alpha: 0.4),
          borderWidth: widget.isSelected ? 2.5 : 1.5,
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: widget.isSelected ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.isSelected ? color : color.withValues(alpha: 0.35), width: widget.isSelected ? 2 : 1.5),
                ),
                child: Center(child: Icon(_icon, color: color, size: 24, fill: widget.isSelected ? 1 : 0)),
              ),
              const Gap(10),
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: widget.isSelected ? _kWhoqolColor : _kWhoqolColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('${widget.score}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.isSelected ? Colors.white : _kWhoqolColor))),
              ),
              const Gap(10),
              Expanded(
                child: Text(widget.label, style: TextStyle(fontSize: 15, height: 1.4, fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal, color: widget.isSelected ? _kWhoqolColor : LightModeColors.lightOnSurface)),
              ),
              if (widget.isSelected) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(material.Icons.check_circle, color: _kWhoqolColor, size: 22)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhoqolPagination extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final Map<int, int> responses;
  final ValueChanged<int> onPageChanged;

  const _WhoqolPagination({required this.currentIndex, required this.totalQuestions, required this.responses, required this.onPageChanged});

  static const _answered = Color(0xFF16A34A);
  static const _unanswered = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final answered = responses.length;
    final unanswered = totalQuestions - answered;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Dot(color: _answered, label: '$answered respondidas'),
            const Gap(16),
            _Dot(color: _unanswered, label: '$unanswered sin responder'),
          ],
        ),
        const Gap(10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: List.generate(totalQuestions, (i) {
            final qNum = i + 1;
            final isAnswered = responses.containsKey(qNum);
            final isCurrent = i == currentIndex;
            final bg = isAnswered ? _answered : _unanswered;
            return GestureDetector(
              onTap: () => onPageChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isCurrent ? bg : bg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bg, width: isCurrent ? 2.5 : 1.5),
                ),
                child: Center(child: Text('$qNum', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isCurrent ? Colors.white : bg))),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const Gap(5),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const Gap(10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

