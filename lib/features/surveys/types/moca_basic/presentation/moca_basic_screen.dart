import 'dart:convert';

import 'package:flutter/material.dart' as material show Icons;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/presentation/survey_controller.dart';
import 'package:ssapp/features/surveys/shared/form/survey_text_field.dart';
import 'package:ssapp/features/surveys/shared/widgets/survey_form_dialogs.dart';
import 'package:ssapp/features/surveys/types/moca_basic/domain/moca_basic_fields.dart';
import 'package:ssapp/features/surveys/types/moca_basic/presentation/moca_basic_controller.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';
import 'package:ssapp/shared/widgets/font_size_button.dart';

const _kColor = Color(0xFF0F766E);

class MocaBasicScreen extends StatefulWidget {
  final int patientId;

  const MocaBasicScreen({super.key, required this.patientId});

  @override
  State<MocaBasicScreen> createState() => _MocaBasicScreenState();
}

class _MocaBasicScreenState extends State<MocaBasicScreen> {
  late MocaBasicController _controller;
  bool _initialized = false;
  final Map<int, TextEditingController> _textControllers = {};

  int? _fromInvestigationId() {
    final params = GoRouterState.of(context).uri.queryParameters;
    final raw = params['fromInvestigation'] ??
        params['from_investigation'] ??
        params['fromInvestigationId'] ??
        params['from_investigation_id'];
    return int.tryParse(raw ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _controller = MocaBasicController(
        patientId: widget.patientId,
        surveyService: context.read<SurveyService>(),
        investigationId: _fromInvestigationId(),
      );
      _controller.addListener(_rebuild);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    if (_initialized) {
      _controller.removeListener(_rebuild);
      _controller.dispose();
    }
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  TextEditingController _tcFor(int fieldId, {String initial = ''}) {
    final existing = _textControllers[fieldId];
    if (existing != null) {
      if (existing.text != initial) {
        existing.text = initial;
      }
      return existing;
    }
    final controller = TextEditingController(text: initial);
    _textControllers[fieldId] = controller;
    return controller;
  }

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Center(
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
                  'Salir del MoCA 8.1?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const Gap(12),
                const Text('Se perdera el progreso no guardado.'),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
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
    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveSurvey() async {
    if (_controller.isSaving) return;

    final missing = _controller.missingRequiredLabels();
    if (missing.isNotEmpty) {
      showCenteredToast(
        context,
        title: 'Faltan campos',
        subtitle: missing.take(3).join(', '),
        icon: material.Icons.error_outline,
        iconColor: LightModeColors.lightError,
        location: ToastLocation.topCenter,
      );
      return;
    }

    showSurveyFormSavingDialog(context);
    final SurveySaveResult result = await _controller.saveSurvey();
    if (mounted) Navigator.of(context).pop();

    if (!result.success) {
      if (!mounted) return;
      showCenteredToast(
        context,
        title: 'Error',
        subtitle: result.error ?? 'No se pudo guardar el MoCA 8.1.',
        icon: material.Icons.error_outline,
        iconColor: LightModeColors.lightError,
        location: ToastLocation.topCenter,
      );
      return;
    }

    if (!mounted) return;
    showSurveyFormCompletionDialog(
      context,
      wasSynced: result.wasSynced,
      onContinue: () {
        if (_controller.investigationId != null) {
          context.go(
            '/investigations/${_controller.investigationId}/apply'
            '?completedSurvey=moca_basic&patientId=${widget.patientId}',
          );
        } else {
          context.go('/new-survey');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('MoCA 8.1'),
          subtitle: const Text('Paciente + doctor en tableta'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: _confirmExit,
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: const [
            FontSizeButton(),
          ],
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
                  _HeroCard(),
                  const Gap(20),
                  _SectionCard(
                    number: '1',
                    title: 'Visoespacial / ejecutivo',
                    description:
                        'Cuando el paciente necesite interactuar con la tableta, use estas actividades. El doctor registra la puntuacion oficial debajo de cada una.',
                    children: [
                      _PatientTaskCard(
                        title: 'Trazado alternante',
                        instruction:
                            'Paciente: una los circulos siguiendo el patron 1-A-2-B-3-C-4-D-5-E.',
                        child: _DrawingTask(
                          controller: _controller,
                          drawingFieldId: MocaBasicFieldIds.trailDrawing,
                          backgroundPainter: const _TrailStimulusPainter(),
                          height: 260,
                        ),
                      ),
                      const Gap(16),
                      _BooleanScoreRow(
                        label: 'Doctor: trazado correcto',
                        value: _controller.intAnswer(MocaBasicFieldIds.trailCorrect),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.trailCorrect, value),
                      ),
                      const Gap(20),
                      _PatientTaskCard(
                        title: 'Copia del cubo',
                        instruction:
                            'Paciente: observe el cubo modelo y copielo en el recuadro en blanco.',
                        child: _CubeTask(
                          controller: _controller,
                        ),
                      ),
                      const Gap(16),
                      _BooleanScoreRow(
                        label: 'Doctor: cubo correcto',
                        value: _controller.intAnswer(MocaBasicFieldIds.cubeCorrect),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.cubeCorrect, value),
                      ),
                      const Gap(20),
                      _PatientTaskCard(
                        title: 'Dibujo del reloj',
                        instruction:
                            'Paciente: dibuje un reloj, coloque todos los numeros y marque las 11:10.',
                        child: _DrawingTask(
                          controller: _controller,
                          drawingFieldId: MocaBasicFieldIds.clockDrawing,
                          height: 280,
                        ),
                      ),
                      const Gap(16),
                      _BooleanScoreRow(
                        label: 'Doctor: contorno correcto',
                        value: _controller.intAnswer(MocaBasicFieldIds.clockContour),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.clockContour, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Doctor: numeros correctos',
                        value: _controller.intAnswer(MocaBasicFieldIds.clockNumbers),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.clockNumbers, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Doctor: manecillas correctas',
                        value: _controller.intAnswer(MocaBasicFieldIds.clockHands),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.clockHands, value),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '2',
                    title: 'Denominacion',
                    description:
                        'Paciente: nombre los animales mostrados. Doctor: registre uno por uno.',
                    children: [
                      const _AnimalStimulusRow(),
                      const Gap(16),
                      _BooleanScoreRow(
                        label: 'Leon',
                        value: _controller.intAnswer(MocaBasicFieldIds.namingLion),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.namingLion, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Rinoceronte',
                        value: _controller.intAnswer(MocaBasicFieldIds.namingRhino),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.namingRhino, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Camello',
                        value: _controller.intAnswer(MocaBasicFieldIds.namingCamel),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.namingCamel, value),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '3',
                    title: 'Memoria inmediata',
                    description:
                        'Doctor: lea la lista de palabras segun el protocolo oficial. No muestre las palabras al paciente.',
                    children: [
                      const _DoctorOnlyNotice(
                        title: 'Palabras del ensayo',
                        body:
                            'Diga en voz alta estas cinco palabras al paciente: ROSTRO, SEDA, TEMPLO, CLAVEL, ROJO. Registre cuantas repite correctamente en el ensayo 1 y en el ensayo 2. Estos datos no suman al puntaje total.',
                      ),
                      const Gap(16),
                      SurveyTextField(
                        label: 'Ensayo 1 (0 a 5)',
                        controller: _tcFor(
                          MocaBasicFieldIds.memoryTrial1,
                          initial: _controller.intAnswer(MocaBasicFieldIds.memoryTrial1)?.toString() ?? '',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _controller.setIntAnswer(
                          MocaBasicFieldIds.memoryTrial1,
                          int.tryParse(value),
                        ),
                      ),
                      const Gap(16),
                      SurveyTextField(
                        label: 'Ensayo 2 (0 a 5)',
                        controller: _tcFor(
                          MocaBasicFieldIds.memoryTrial2,
                          initial: _controller.intAnswer(MocaBasicFieldIds.memoryTrial2)?.toString() ?? '',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _controller.setIntAnswer(
                          MocaBasicFieldIds.memoryTrial2,
                          int.tryParse(value),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '4',
                    title: 'Atencion',
                    description:
                        'Doctor: administre digitos, vigilancia con la letra A y restas seriadas. Capture la puntuacion oficial.',
                    children: [
                      _BooleanScoreRow(
                        label: 'Digitos hacia delante',
                        value: _controller.intAnswer(MocaBasicFieldIds.digitsForward),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.digitsForward, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Digitos hacia atras',
                        value: _controller.intAnswer(MocaBasicFieldIds.digitsBackward),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.digitsBackward, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Vigilancia con letra A',
                        value: _controller.intAnswer(MocaBasicFieldIds.vigilance),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.vigilance, value),
                      ),
                      const Gap(16),
                      SurveyTextField(
                        label: 'Restas correctas en serie del 7 (0 a 5)',
                        helperText: 'Capture cuantas restas consecutivas fueron correctas.',
                        controller: _tcFor(
                          MocaBasicFieldIds.serialSevensCorrect,
                          initial: _controller.intAnswer(MocaBasicFieldIds.serialSevensCorrect)?.toString() ?? '',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _controller.setIntAnswer(
                          MocaBasicFieldIds.serialSevensCorrect,
                          int.tryParse(value),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '5',
                    title: 'Lenguaje',
                    description:
                        'Doctor: aplique repeticion de frases y fluidez fonemica con la letra F.',
                    children: [
                      _BooleanScoreRow(
                        label: 'Frase 1 correcta',
                        value: _controller.intAnswer(MocaBasicFieldIds.sentence1),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.sentence1, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Frase 2 correcta',
                        value: _controller.intAnswer(MocaBasicFieldIds.sentence2),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.sentence2, value),
                      ),
                      const Gap(16),
                      SurveyTextField(
                        label: 'Palabras con F en 60 segundos',
                        helperText: 'La app dara 1 punto si produce 11 o mas palabras validas.',
                        controller: _tcFor(
                          MocaBasicFieldIds.fluencyWords,
                          initial: _controller.intAnswer(MocaBasicFieldIds.fluencyWords)?.toString() ?? '',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _controller.setIntAnswer(
                          MocaBasicFieldIds.fluencyWords,
                          int.tryParse(value),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '6',
                    title: 'Abstraccion',
                    description: 'Doctor: marque cada relacion correctamente identificada.',
                    children: [
                      _BooleanScoreRow(
                        label: 'Tren y bicicleta',
                        value: _controller.intAnswer(MocaBasicFieldIds.abstractionTrainBicycle),
                        onChanged: (value) => _controller.setIntAnswer(
                          MocaBasicFieldIds.abstractionTrainBicycle,
                          value,
                        ),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Reloj y regla',
                        value: _controller.intAnswer(MocaBasicFieldIds.abstractionWatchRuler),
                        onChanged: (value) => _controller.setIntAnswer(
                          MocaBasicFieldIds.abstractionWatchRuler,
                          value,
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '7',
                    title: 'Recuerdo diferido',
                    description:
                        'Doctor: marque las palabras recuperadas espontaneamente, sin pistas.',
                    children: [
                      _BooleanScoreRow(
                        label: 'ROSTRO',
                        value: _controller.intAnswer(MocaBasicFieldIds.delayedRostro),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.delayedRostro, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'SEDA',
                        value: _controller.intAnswer(MocaBasicFieldIds.delayedSeda),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.delayedSeda, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'TEMPLO',
                        value: _controller.intAnswer(MocaBasicFieldIds.delayedTemplo),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.delayedTemplo, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'CLAVEL',
                        value: _controller.intAnswer(MocaBasicFieldIds.delayedClavel),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.delayedClavel, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'ROJO',
                        value: _controller.intAnswer(MocaBasicFieldIds.delayedRojo),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.delayedRojo, value),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '8',
                    title: 'Orientacion',
                    description: 'Doctor: marque cada respuesta exacta.',
                    children: [
                      _BooleanScoreRow(
                        label: 'Fecha',
                        value: _controller.intAnswer(MocaBasicFieldIds.orientationDate),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.orientationDate, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Mes',
                        value: _controller.intAnswer(MocaBasicFieldIds.orientationMonth),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.orientationMonth, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Anio',
                        value: _controller.intAnswer(MocaBasicFieldIds.orientationYear),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.orientationYear, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Dia de la semana',
                        value: _controller.intAnswer(MocaBasicFieldIds.orientationDay),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.orientationDay, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Lugar',
                        value: _controller.intAnswer(MocaBasicFieldIds.orientationPlace),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.orientationPlace, value),
                      ),
                      const Gap(12),
                      _BooleanScoreRow(
                        label: 'Ciudad',
                        value: _controller.intAnswer(MocaBasicFieldIds.orientationCity),
                        onChanged: (value) =>
                            _controller.setIntAnswer(MocaBasicFieldIds.orientationCity, value),
                      ),
                    ],
                  ),
                  const Gap(20),
                  _SectionCard(
                    number: '9',
                    title: 'Ajuste educativo',
                    description:
                        'La app suma +1 punto si el total es menor de 30 y el paciente tiene 12 anios o menos de estudios.',
                    children: [
                      _BooleanScoreRow(
                        label: '12 anios o menos de estudios',
                        value: _controller.intAnswer(MocaBasicFieldIds.education12OrLess),
                        onChanged: (value) => _controller.setIntAnswer(
                          MocaBasicFieldIds.education12OrLess,
                          value,
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  SurfaceCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Puntaje estimado actual')
                                    .semiBold()
                                    .large(),
                                const Gap(6),
                                Text(
                                  '${_controller.computeScore(_controller.buildResponseModelsWithText()) ?? 0}/30',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: _kColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PrimaryButton(
                            onPressed: _controller.isSaving ? null : _saveSurvey,
                            child: Text(_controller.isSaving ? 'Guardando...' : 'Guardar MoCA 8.1'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kColor, _kColor.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Montreal Cognitive Assessment 8.1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(10),
          Text(
            'Esta version combina actividades del paciente en la tableta con captura del doctor. Toda la aplicacion del instrumento y el registro del resultado se realizan dentro de esta pantalla.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final List<Widget> children;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: _kColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title).semiBold().large(),
                      const Gap(4),
                      Text(description).muted(),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _PatientTaskCard extends StatelessWidget {
  final String title;
  final String instruction;
  final Widget child;

  const _PatientTaskCard({
    required this.title,
    required this.instruction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      backgroundColor: _kColor.withValues(alpha: 0.06),
      borderColor: _kColor.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(material.Icons.touch_app_outlined, color: _kColor),
              Gap(8),
              Text('Paciente en tableta', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Gap(12),
          Text(title).semiBold(),
          const Gap(6),
          Text(instruction).muted(),
          const Gap(16),
          child,
        ],
      ),
    );
  }
}

class _DoctorOnlyNotice extends StatelessWidget {
  final String title;
  final String body;

  const _DoctorOnlyNotice({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      backgroundColor: const Color(0xFFFEF3C7),
      borderColor: const Color(0xFFF59E0B),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(material.Icons.visibility_off_outlined, color: Color(0xFFB45309)),
              Gap(8),
              Text('Solo para el doctor', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const Gap(10),
          Text(title).semiBold(),
          const Gap(6),
          Text(body),
        ],
      ),
    );
  }
}

class _BooleanScoreRow extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  const _BooleanScoreRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const Gap(12),
        _ChoicePill(
          label: 'Si',
          selected: value == 1,
          color: _kColor,
          onTap: () => onChanged(1),
        ),
        const Gap(8),
        _ChoicePill(
          label: 'No',
          selected: value == 0,
          color: LightModeColors.lightError,
          onTap: () => onChanged(0),
        ),
      ],
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : LightModeColors.lightOutline,
            width: selected ? 2 : 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : LightModeColors.lightOnSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AnimalStimulusRow extends StatelessWidget {
  const _AnimalStimulusRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        final children = const [
          _AnimalCard(emoji: '\u{1F981}'),
          _AnimalCard(emoji: '\u{1F98F}'),
          _AnimalCard(emoji: '\u{1F42A}'),
        ];
        if (isCompact) {
          return Column(
            children: [
              children[0],
              const Gap(12),
              children[1],
              const Gap(12),
              children[2],
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: children[0]),
            const Gap(12),
            Expanded(child: children[1]),
            const Gap(12),
            Expanded(child: children[2]),
          ],
        );
      },
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final String emoji;

  const _AnimalCard({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 56),
        ),
      ),
    );
  }
}

class _CubeTask extends StatelessWidget {
  final MocaBasicController controller;

  const _CubeTask({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;
        if (compact) {
          return Column(
            children: [
              const SizedBox(
                height: 180,
                child: CustomPaint(
                  painter: _CubeModelPainter(),
                  child: SizedBox.expand(),
                ),
              ),
              const Gap(16),
              _DrawingTask(
                controller: controller,
                drawingFieldId: MocaBasicFieldIds.cubeDrawing,
                height: 220,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: SizedBox(
                height: 220,
                child: CustomPaint(
                  painter: _CubeModelPainter(),
                  child: SizedBox.expand(),
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: _DrawingTask(
                controller: controller,
                drawingFieldId: MocaBasicFieldIds.cubeDrawing,
                height: 220,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DrawingTask extends StatelessWidget {
  final MocaBasicController controller;
  final int drawingFieldId;
  final CustomPainter? backgroundPainter;
  final double height;

  const _DrawingTask({
    required this.controller,
    required this.drawingFieldId,
    this.backgroundPainter,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return _DrawingPad(
      height: height,
      initialData: controller.textAnswer(drawingFieldId),
      backgroundPainter: backgroundPainter,
      onChanged: (serialized) => controller.setTextAnswer(drawingFieldId, serialized),
    );
  }
}

class _DrawingPad extends StatefulWidget {
  final String? initialData;
  final ValueChanged<String> onChanged;
  final CustomPainter? backgroundPainter;
  final double height;

  const _DrawingPad({
    required this.initialData,
    required this.onChanged,
    this.backgroundPainter,
    required this.height,
  });

  @override
  State<_DrawingPad> createState() => _DrawingPadState();
}

class _DrawingPadState extends State<_DrawingPad> {
  List<List<Offset>> _strokes = [];

  @override
  void initState() {
    super.initState();
    _strokes = _deserialize(widget.initialData);
  }

  @override
  void didUpdateWidget(covariant _DrawingPad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialData != widget.initialData) {
      _strokes = _deserialize(widget.initialData);
    }
  }

  void _push() {
    widget.onChanged(_serialize(_strokes));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LightModeColors.lightOutline),
          ),
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _strokes = [..._strokes, [details.localPosition]];
              });
              _push();
            },
            onPanUpdate: (details) {
              setState(() {
                if (_strokes.isEmpty) {
                  _strokes = [[details.localPosition]];
                } else {
                  _strokes.last = [..._strokes.last, details.localPosition];
                }
              });
              _push();
            },
            child: CustomPaint(
              painter: _DrawingPadPainter(
                strokes: _strokes,
                backgroundPainter: widget.backgroundPainter,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        const Gap(10),
        Align(
          alignment: Alignment.centerRight,
          child: OutlineButton(
            onPressed: () {
              setState(() => _strokes = []);
              _push();
            },
            child: const Text('Limpiar dibujo'),
          ),
        ),
      ],
    );
  }

  static String _serialize(List<List<Offset>> strokes) {
    if (strokes.isEmpty) return '';
    final data = strokes
        .map(
          (stroke) => stroke
              .map((point) => {'x': point.dx, 'y': point.dy})
              .toList(),
        )
        .where((stroke) => stroke.isNotEmpty)
        .toList();
    if (data.isEmpty) return '';
    return jsonEncode(data);
  }

  static List<List<Offset>> _deserialize(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (stroke) => (stroke as List<dynamic>)
                .map(
                  (point) => Offset(
                    (point['x'] as num).toDouble(),
                    (point['y'] as num).toDouble(),
                  ),
                )
                .toList(),
          )
          .where((stroke) => stroke.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class _DrawingPadPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final CustomPainter? backgroundPainter;

  const _DrawingPadPainter({
    required this.strokes,
    this.backgroundPainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    backgroundPainter?.paint(canvas, size);

    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.5, strokePaint..style = PaintingStyle.fill);
        strokePaint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPadPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.backgroundPainter != backgroundPainter;
  }
}

class _TrailStimulusPainter extends CustomPainter {
  const _TrailStimulusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final circlePaint = Paint()
      ..color = const Color(0xFFE6FFFB)
      ..style = PaintingStyle.fill;
    final circleBorder = Paint()
      ..color = _kColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      borderPaint,
    );

    final nodes = <String, Offset>{
      '1': Offset(size.width * 0.12, size.height * 0.18),
      'A': Offset(size.width * 0.42, size.height * 0.12),
      '2': Offset(size.width * 0.74, size.height * 0.20),
      'B': Offset(size.width * 0.25, size.height * 0.44),
      '3': Offset(size.width * 0.55, size.height * 0.40),
      'C': Offset(size.width * 0.84, size.height * 0.42),
      '4': Offset(size.width * 0.18, size.height * 0.72),
      'D': Offset(size.width * 0.50, size.height * 0.68),
      '5': Offset(size.width * 0.82, size.height * 0.74),
      'E': Offset(size.width * 0.36, size.height * 0.88),
    };

    for (final entry in nodes.entries) {
      canvas.drawCircle(entry.value, 20, circlePaint);
      canvas.drawCircle(entry.value, 20, circleBorder);
      final painter = TextPainter(
        text: TextSpan(
          text: entry.key,
          style: const TextStyle(
            color: _kColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(
          entry.value.dx - painter.width / 2,
          entry.value.dy - painter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CubeModelPainter extends CustomPainter {
  const _CubeModelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      borderPaint,
    );

    final paint = Paint()
      ..color = _kColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final front = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.28,
      size.width * 0.34,
      size.height * 0.36,
    );
    final back = front.shift(Offset(size.width * 0.18, -size.height * 0.1));

    canvas.drawRect(front, paint);
    canvas.drawRect(back, paint);

    canvas.drawLine(front.topLeft, back.topLeft, paint);
    canvas.drawLine(front.topRight, back.topRight, paint);
    canvas.drawLine(front.bottomLeft, back.bottomLeft, paint);
    canvas.drawLine(front.bottomRight, back.bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
