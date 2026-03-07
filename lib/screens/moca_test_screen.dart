import 'dart:async';
import 'package:flutter/material.dart' as material show Icons, Navigator;
import 'package:signature/signature.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/models/moca_questions.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/widgets/drawing_canvas.dart';

class MocaTestScreen extends StatefulWidget {
  final int patientId;

  const MocaTestScreen({super.key, required this.patientId});

  @override
  State<MocaTestScreen> createState() => _MocaTestScreenState();
}

class _MocaTestScreenState extends State<MocaTestScreen> {
  int _currentSectionIndex = 0;
  final Map<String, dynamic> _results = {};
  bool _isLoading = false;

  List<String> _memoryTrial1 = [];
  List<String> _memoryTrial2 = [];
  Set<String> _delayedRecallWords = {};
  Set<String> _categoryRecallWords = {};
  Set<String> _multipleChoiceRecallWords = {};

  int _fluencyTimer = 60;
  Timer? _fluencyTimerInstance;
  bool _fluencyStarted = false;
  List<String> _fluencyWords = [];

  late SignatureController _trailMakingController;
  late SignatureController _cubeController;
  late SignatureController _clockController;

  MocaSection get _currentSection => MocaTest.sections[_currentSectionIndex];

  double get _progress => (_currentSectionIndex + 1) / MocaTest.sections.length;

  @override
  void initState() {
    super.initState();
    _trailMakingController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
    );
    _cubeController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
    );
    _clockController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
    );
  }

  @override
  void dispose() {
    _fluencyTimerInstance?.cancel();
    _trailMakingController.dispose();
    _cubeController.dispose();
    _clockController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(
          leading: Icon(
            material.Icons.error_outline,
            color: LightModeColors.lightError,
          ),
          title: const Text('Error'),
          subtitle: Text(message),
          trailing: OutlineButton(
            size: ButtonSize.small,
            onPressed: () => overlay.close(),
            child: const Text('Cerrar'),
          ),
          trailingAlignment: Alignment.center,
        ),
      ),
      location: ToastLocation.bottomCenter,
    );
  }

  void _nextSection() {
    if (_currentSectionIndex < MocaTest.sections.length - 1) {
      setState(() {
        _currentSectionIndex++;
      });
    } else {
      _finishTest();
    }
  }

  void _previousSection() {
    if (_currentSectionIndex > 0) {
      setState(() {
        _currentSectionIndex--;
      });
    }
  }

  Future<void> _finishTest() async {
    setState(() => _isLoading = true);

    try {
      int totalScore = _calculateTotalScore();

      // TODO: implementar back

      if (!mounted) return;

      _showResults(totalScore);
    } catch (e) {
      if (mounted) {
        _showError('Error al procesar los resultados: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _calculateTotalScore() {
    int score = 0;

    for (var entry in _results.entries) {
      if (entry.value is int) {
        score += entry.value as int;
      } else if (entry.value is bool && entry.value == true) {
        score += 1;
      }
    }

    return score;
  }

  void _showResults(int score) {
    final interpretation = MocaTest.interpretScore(score);
    final description = MocaTest.getScoreDescription(score);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evaluación Completada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puntaje Total: $score/${MocaTest.maxScore}').textLarge().bold(),
            const Gap(8),
            Text('Interpretación: $interpretation').medium(),
            const Gap(16),
            Text(description).small().muted(),
            const Gap(16),
            Text('Nota: Los resultados se guardarán cuando se implemente el soporte de base de datos.')
                .small()
                .muted(),
          ],
        ),
        actions: [
          PrimaryButton(
            onPressed: () {
              material.Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    );
  }

  void _startFluencyTimer() {
    setState(() {
      _fluencyStarted = true;
      _fluencyTimer = 60;
    });

    _fluencyTimerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_fluencyTimer > 0) {
        setState(() {
          _fluencyTimer--;
        });
      } else {
        timer.cancel();
        _showError('Tiempo terminado');
      }
    });
  }

  void _stopFluencyTimer() {
    _fluencyTimerInstance?.cancel();
    setState(() {
      _fluencyStarted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('MoCA - Evaluación Cognitiva Montreal'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => material.Navigator.of(context).pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sección ${_currentSectionIndex + 1} de ${MocaTest.sections.length}')
                        .small()
                        .muted(),
                    Text('${(_progress * 100).toInt()}% Completado').small().muted(),
                  ],
                ),
                const Gap(8),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: LightModeColors.lightSecondary.withValues(alpha: 0.2),
                  color: LightModeColors.lightSecondary,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildSectionContent(),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentSectionIndex > 0)
                  Expanded(
                    child: OutlineButton(
                      onPressed: _previousSection,
                      child: const Text('Anterior'),
                    ),
                  ),
                if (_currentSectionIndex > 0) const Gap(16),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    onPressed: _isLoading ? null : _nextSection,
                    child: Text(
                      _currentSectionIndex < MocaTest.sections.length - 1
                          ? 'Siguiente'
                          : 'Finalizar Evaluación',
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

  Widget _buildSectionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LightModeColors.lightSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_currentSection.maxPoints} ${_currentSection.maxPoints == 1 ? "punto" : "puntos"}',
                        style: TextStyle(
                          color: LightModeColors.lightSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(_currentSection.title).textLarge().bold(),
                    ),
                  ],
                ),
                const Gap(8),
                Text(_currentSection.description).muted(),
              ],
            ),
          ),
        ),
        const Gap(24),

        if (_currentSection.instructions != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    material.Icons.info_outline,
                    color: LightModeColors.lightSecondary,
                    size: 20,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(_currentSection.instructions!).small(),
                  ),
                ],
              ),
            ),
          ),
          const Gap(24),
        ],

        _buildQuestionWidget(),
      ],
    );
  }

  Widget _buildQuestionWidget() {
    switch (_currentSection.type) {
      case MocaQuestionType.trailMaking:
        return _buildTrailMakingWidget();
      case MocaQuestionType.visuoconstructiveCube:
        return _buildCubeDrawingWidget();
      case MocaQuestionType.visuoconstructiveClock:
        return _buildClockDrawingWidget();
      case MocaQuestionType.naming:
        return _buildNamingWidget();
      case MocaQuestionType.memory:
        return _buildMemoryWidget();
      case MocaQuestionType.digitsForward:
        return _buildDigitsForwardWidget();
      case MocaQuestionType.digitsBackward:
        return _buildDigitsBackwardWidget();
      case MocaQuestionType.vigilance:
        return _buildVigilanceWidget();
      case MocaQuestionType.serialSubtraction:
        return _buildSerialSubtractionWidget();
      case MocaQuestionType.sentenceRepetition:
        return _buildSentenceRepetitionWidget();
      case MocaQuestionType.fluency:
        return _buildFluencyWidget();
      case MocaQuestionType.abstraction:
        return _buildAbstractionWidget();
      case MocaQuestionType.delayedRecall:
        return _buildDelayedRecallWidget();
      case MocaQuestionType.orientation:
        return _buildOrientationWidget();
    }
  }

  Widget _buildTrailMakingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TrailMakingCanvas(controller: _trailMakingController),
        const Gap(24),
        const Text('Evaluación del Trazo:').medium().semiBold(),
        const Gap(8),
        _buildCheckboxOption(
          'trailMaking',
          'Trazo correcto',
          'El paciente completó el trazo siguiendo el patrón 1-A-2-B-3-C-4-D-5-E sin cruces',
          _results['trailMaking'] ?? false,
        ),
      ],
    );
  }

  Widget _buildCubeDrawingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CubeDrawingCanvas(controller: _cubeController),
        const Gap(24),
        const Text('Evaluación del Dibujo:').medium().semiBold(),
        const Gap(8),
        _buildCheckboxOption(
          'cubeDrawing',
          'Dibujo correcto',
          'El dibujo es tridimensional con todas las líneas dibujadas y conectadas correctamente',
          _results['cubeDrawing'] ?? false,
        ),
      ],
    );
  }

  Widget _buildClockDrawingWidget() {
    final key = 'clockDrawing';
    final contour = _results['${key}_contour'] ?? false;
    final numbers = _results['${key}_numbers'] ?? false;
    final hands = _results['${key}_hands'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClockDrawingCanvas(controller: _clockController),
        const Gap(24),
        const Text('Evalúe cada componente del reloj:').medium().semiBold(),
        const Gap(16),

        _buildCheckboxOption(
          '${key}_contour',
          'Contorno',
          'El contorno del reloj está dibujado (circular o cuadrado)',
          contour,
        ),
        const Gap(8),

        _buildCheckboxOption(
          '${key}_numbers',
          'Números',
          'Todos los números del reloj están presentes y correctamente posicionados',
          numbers,
        ),
        const Gap(8),

        _buildCheckboxOption(
          '${key}_hands',
          'Manecillas',
          'Dos manecillas indicando 10:10, con la hora más corta que los minutos',
          hands,
        ),
        const Gap(16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LightModeColors.lightSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text('Puntaje: ${(contour ? 1 : 0) + (numbers ? 1 : 0) + (hands ? 1 : 0)}/3')
                  .semiBold(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNamingWidget() {
    final animalImages = [
      {
        'name': 'León',
        'asset': 'assets/images/moca/leon.jpg',
        'alternates': 'Solo león',
      },
      {
        'name': 'Caballo',
        'asset': 'assets/images/moca/caballo.jpg',
        'alternates': 'Yegua, potro, poni',
      },
      {
        'name': 'Pato',
        'asset': 'assets/images/moca/pato.jpg',
        'alternates': 'Pato macho, ánade',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Muestre cada imagen al paciente y pídale que la nombre:')
            .medium()
            .semiBold(),
        const Gap(16),

        ...animalImages.asMap().entries.map((entry) {
          final index = entry.key;
          final animal = entry.value;
          final key = 'naming_$index';
          final isCorrect = _results[key] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Animal image
                    Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 260),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: LightModeColors.lightSecondary.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              animal['asset'] as String,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      material.Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: LightModeColors.lightSecondary.withValues(alpha: 0.5),
                                    ),
                                    const Gap(8),
                                    Text(
                                      animal['name'] as String,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: LightModeColors.lightSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Center(
                      child: Column(
                        children: [
                          Text('Respuesta esperada: ${animal['name']}')
                              .medium()
                              .semiBold(),
                          const Gap(4),
                          Text('Alternativas: ${animal['alternates']}')
                              .small()
                              .muted(),
                        ],
                      ),
                    ),
                    const Gap(16),
                    _buildCheckboxOption(
                      key,
                      'Nombrado correctamente',
                      'El paciente nombró este animal correctamente',
                      isCorrect,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMemoryWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Primer Intento - Marque las palabras recordadas:').medium().semiBold(),
        const Gap(16),

        ...MocaTest.memoryWords.map((word) {
          final isRecalled = _memoryTrial1.contains(word);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isRecalled) {
                    _memoryTrial1.remove(word);
                  } else {
                    _memoryTrial1.add(word);
                  }
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Checkbox(
                        state: isRecalled ? CheckboxState.checked : CheckboxState.unchecked,
                        onChanged: (state) {
                          setState(() {
                            if (state == CheckboxState.checked) {
                              _memoryTrial1.add(word);
                            } else {
                              _memoryTrial1.remove(word);
                            }
                          });
                        },
                      ),
                      const Gap(12),
                      Text(word).medium(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const Gap(24),
        const Divider(),
        const Gap(24),

        const Text('Segundo Intento - Marque las palabras recordadas:').medium().semiBold(),
        const Gap(16),

        ...MocaTest.memoryWords.map((word) {
          final isRecalled = _memoryTrial2.contains(word);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isRecalled) {
                    _memoryTrial2.remove(word);
                  } else {
                    _memoryTrial2.add(word);
                  }
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Checkbox(
                        state: isRecalled ? CheckboxState.checked : CheckboxState.unchecked,
                        onChanged: (state) {
                          setState(() {
                            if (state == CheckboxState.checked) {
                              _memoryTrial2.add(word);
                            } else {
                              _memoryTrial2.remove(word);
                            }
                          });
                        },
                      ),
                      const Gap(12),
                      Text(word).medium(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const Gap(16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(material.Icons.info_outline, size: 16, color: LightModeColors.lightSecondary),
                const Gap(8),
                Expanded(
                  child: const Text('Esta sección no otorga puntos. Se evaluará en el recuerdo diferido.')
                      .small()
                      .muted(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDigitsForwardWidget() {
    return _buildTextInputScore(
      'digitsForward',
      'Secuencia: ${_currentSection.metadata!['sequence']}',
      'Respuesta del paciente:',
      _currentSection.metadata!['sequence'] as String,
    );
  }

  Widget _buildDigitsBackwardWidget() {
    return _buildTextInputScore(
      'digitsBackward',
      'Secuencia: ${_currentSection.metadata!['sequence']} (debe responder al revés)',
      'Respuesta del paciente:',
      _currentSection.metadata!['correctAnswer'] as String,
    );
  }

  Widget _buildVigilanceWidget() {
    return _buildBinaryScoreWidget(
      'vigilance',
      'Letras: ${_currentSection.metadata!['letters']}',
      'El paciente cometió 0 o 1 errores',
    );
  }

  Widget _buildSerialSubtractionWidget() {
    final correctAnswers = _currentSection.metadata!['correctAnswers'] as List<int>;
    final key = 'serialSubtraction';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingrese las respuestas del paciente:').medium().semiBold(),
        const Gap(8),
        Text('Secuencia correcta: ${correctAnswers.join(" → ")}').small().muted(),
        const Gap(16),

        ...List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              placeholder: Text('Respuesta ${index + 1}'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _results['${key}_$index'] = value;
                });
              },
            ),
          );
        }),

        const Gap(16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Criterios de puntuación:').small().semiBold(),
                const Gap(4),
                const Text('• 0 puntos: Ninguna resta correcta').small(),
                const Text('• 1 punto: Una resta correcta').small(),
                const Text('• 2 puntos: Dos o tres restas correctas').small(),
                const Text('• 3 puntos: Cuatro o cinco restas correctas').small(),
              ],
            ),
          ),
        ),
        const Gap(16),

        const Text('Puntaje obtenido:').medium().semiBold(),
        const Gap(8),

        ...List.generate(4, (score) {
          final isSelected = _results[key] == score;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _results[key] = score;
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Radio(value: isSelected),
                      const Gap(12),
                      Text('$score ${score == 1 ? "punto" : "puntos"}'),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSentenceRepetitionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...(_currentSection.options ?? []).asMap().entries.map((entry) {
          final index = entry.key;
          final sentence = entry.value;
          final key = 'sentenceRepetition_$index';
          final isCorrect = _results[key] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('"$sentence"').medium(),
                  ),
                ),
                const Gap(8),
                _buildCheckboxOption(
                  key,
                  'Repetición exacta',
                  'El paciente repitió la oración sin errores',
                  isCorrect,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFluencyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_fluencyStarted && _fluencyWords.isEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    material.Icons.timer,
                    size: 48,
                    color: LightModeColors.lightSecondary,
                  ),
                  const Gap(16),
                  const Text('Presione el botón para iniciar el cronómetro de 60 segundos')
                      .textCenter(),
                  const Gap(16),
                  PrimaryButton(
                    onPressed: _startFluencyTimer,
                    child: const Text('Iniciar Cronómetro'),
                  ),
                ],
              ),
            ),
          ),
        ],

        if (_fluencyStarted) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('$_fluencyTimer segundos restantes')
                      .textLarge()
                      .bold()
                      .textCenter(),
                  const Gap(16),
                  LinearProgressIndicator(
                    value: _fluencyTimer / 60,
                    backgroundColor: Colors.red.withValues(alpha: 0.2),
                    color: Colors.red,
                  ),
                  const Gap(16),
                  OutlineButton(
                    onPressed: _stopFluencyTimer,
                    child: const Text('Detener'),
                  ),
                ],
              ),
            ),
          ),
          const Gap(16),
        ],

        if (!_fluencyStarted && _fluencyWords.isEmpty) ...[
          const Gap(16),
        ],

        const Text('Palabras dichas (opcional - para referencia):').medium().semiBold(),
        const Gap(8),
        TextField(
          placeholder: const Text('Escriba las palabras separadas por comas'),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _fluencyWords = value.split(',').map((w) => w.trim()).where((w) => w.isNotEmpty).toList();
            });
          },
        ),
        const Gap(16),

        const Text('Cantidad de palabras válidas:').medium().semiBold(),
        const Gap(8),
        TextField(
          placeholder: const Text('Número de palabras'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final count = int.tryParse(value);
            setState(() {
              _results['fluency'] = count != null && count >= 11 ? 1 : 0;
              _results['fluencyCount'] = count;
            });
          },
        ),
        const Gap(16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(material.Icons.info_outline, size: 16, color: LightModeColors.lightSecondary),
                const Gap(8),
                Expanded(
                  child: const Text('Se otorga 1 punto si el paciente dice 11 palabras o más en 60 segundos')
                      .small()
                      .muted(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAbstractionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...MocaTest.abstractionPairs.asMap().entries.map((entry) {
          final index = entry.key;
          final pair = entry.value;
          final words = pair['words'] as List;
          final correctAnswers = pair['correctAnswers'] as List;
          final key = 'abstraction_$index';
          final isCorrect = _results[key] ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${words[0]} - ${words[1]}').textLarge().semiBold(),
                        const Gap(8),
                        Text('Respuestas correctas: ${correctAnswers.join(", ")}')
                            .small()
                            .muted(),
                      ],
                    ),
                  ),
                ),
                const Gap(8),
                _buildCheckboxOption(
                  key,
                  'Respuesta correcta',
                  'El paciente dio una categoría válida',
                  isCorrect,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDelayedRecallWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recuerdo Espontáneo:').medium().semiBold(),
        const Gap(8),
        const Text('Marque las palabras que el paciente recuerde sin ayuda:').small().muted(),
        const Gap(16),

        ...MocaTest.memoryWords.map((word) {
          final isRecalled = _delayedRecallWords.contains(word);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isRecalled) {
                    _delayedRecallWords.remove(word);
                  } else {
                    _delayedRecallWords.add(word);
                    // Si ya está en recall espontáneo, quitar de las otras categorías
                    _categoryRecallWords.remove(word);
                    _multipleChoiceRecallWords.remove(word);
                  }
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Checkbox(
                        state: isRecalled ? CheckboxState.checked : CheckboxState.unchecked,
                        onChanged: (state) {
                          setState(() {
                            if (state == CheckboxState.checked) {
                              _delayedRecallWords.add(word);
                              _categoryRecallWords.remove(word);
                              _multipleChoiceRecallWords.remove(word);
                            } else {
                              _delayedRecallWords.remove(word);
                            }
                          });
                        },
                      ),
                      const Gap(12),
                      Text(word).medium(),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const Gap(24),
        const Text('Recuerdo con Pista de Categoría:').medium().semiBold(),
        const Gap(8),
        const Text('Para palabras NO recordadas espontáneamente:').small().muted(),
        const Gap(16),

        ...MocaTest.memoryWords.where((w) => !_delayedRecallWords.contains(w)).map((word) {
          final isRecalled = _categoryRecallWords.contains(word);
          final hint = MocaTest.categoryHints[word];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isRecalled) {
                    _categoryRecallWords.remove(word);
                  } else {
                    _categoryRecallWords.add(word);
                    _multipleChoiceRecallWords.remove(word);
                  }
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            state: isRecalled ? CheckboxState.checked : CheckboxState.unchecked,
                            onChanged: (state) {
                              setState(() {
                                if (state == CheckboxState.checked) {
                                  _categoryRecallWords.add(word);
                                  _multipleChoiceRecallWords.remove(word);
                                } else {
                                  _categoryRecallWords.remove(word);
                                }
                              });
                            },
                          ),
                          const Gap(12),
                          Expanded(child: Text(word).medium()),
                        ],
                      ),
                      const Gap(4),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text('Pista: $hint').small().muted(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const Gap(24),
        const Text('Recuerdo con Elección Múltiple:').medium().semiBold(),
        const Gap(8),
        const Text('Para palabras NO recordadas con pista de categoría:').small().muted(),
        const Gap(16),

        ...MocaTest.memoryWords
            .where((w) => !_delayedRecallWords.contains(w) && !_categoryRecallWords.contains(w))
            .map((word) {
          final isRecalled = _multipleChoiceRecallWords.contains(word);
          final choices = MocaTest.multipleChoiceHints[word];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isRecalled) {
                    _multipleChoiceRecallWords.remove(word);
                  } else {
                    _multipleChoiceRecallWords.add(word);
                  }
                });
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            state: isRecalled ? CheckboxState.checked : CheckboxState.unchecked,
                            onChanged: (state) {
                              setState(() {
                                if (state == CheckboxState.checked) {
                                  _multipleChoiceRecallWords.add(word);
                                } else {
                                  _multipleChoiceRecallWords.remove(word);
                                }
                              });
                            },
                          ),
                          const Gap(12),
                          Expanded(child: Text(word).medium()),
                        ],
                      ),
                      const Gap(4),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: Text('Opciones: ${choices?.join(", ")}').small().muted(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const Gap(24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LightModeColors.lightSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Resumen de Puntuación:').semiBold(),
              const Gap(8),
              Text('Recuerdo espontáneo: ${_delayedRecallWords.length} palabras (${_delayedRecallWords.length} puntos)'),
              Text('Con pista de categoría: ${_categoryRecallWords.length} palabras (0 puntos adicionales)'),
              Text('Con elección múltiple: ${_multipleChoiceRecallWords.length} palabras (0 puntos adicionales)'),
              const Gap(8),
              const Divider(),
              const Gap(8),
              Text('MIS (Memory Index Score): ${MocaTest.calculateMIS(
                spontaneousRecall: _delayedRecallWords.length,
                categoryRecall: _categoryRecallWords.length,
                multipleChoiceRecall: _multipleChoiceRecallWords.length,
              )}/15').semiBold(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrientationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxOption(
          'orientation_date',
          'Fecha (día del mes)',
          'El paciente indicó la fecha correcta',
          _results['orientation_date'] ?? false,
        ),
        const Gap(8),

        _buildCheckboxOption(
          'orientation_month',
          'Mes',
          'El paciente indicó el mes correcto',
          _results['orientation_month'] ?? false,
        ),
        const Gap(8),

        _buildCheckboxOption(
          'orientation_year',
          'Año',
          'El paciente indicó el año correcto',
          _results['orientation_year'] ?? false,
        ),
        const Gap(8),

        _buildCheckboxOption(
          'orientation_day',
          'Día de la semana',
          'El paciente indicó el día correcto',
          _results['orientation_day'] ?? false,
        ),
        const Gap(8),

        _buildCheckboxOption(
          'orientation_place',
          'Lugar',
          'El paciente indicó el lugar correcto (hospital, clínica, etc.)',
          _results['orientation_place'] ?? false,
        ),
        const Gap(8),

        _buildCheckboxOption(
          'orientation_city',
          'Ciudad',
          'El paciente indicó la ciudad correcta',
          _results['orientation_city'] ?? false,
        ),
      ],
    );
  }

  Widget _buildBinaryScoreWidget(String key, String criteria, String description) {
    final isCorrect = _results[key] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(criteria).medium(),
          ),
        ),
        const Gap(16),

        GestureDetector(
          onTap: () {
            setState(() {
              _results[key] = true;
            });
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Radio(value: isCorrect == true),
                  const Gap(12),
                  Expanded(child: const Text('Correcto (1 punto)').medium()),
                ],
              ),
            ),
          ),
        ),
        const Gap(8),

        GestureDetector(
          onTap: () {
            setState(() {
              _results[key] = false;
            });
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Radio(value: isCorrect == false && _results.containsKey(key)),
                  const Gap(12),
                  Expanded(child: const Text('Incorrecto (0 puntos)').medium()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(String key, String title, String description, bool value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _results[key] = !value;
        });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                state: value ? CheckboxState.checked : CheckboxState.unchecked,
                onChanged: (state) {
                  setState(() {
                    _results[key] = state == CheckboxState.checked;
                  });
                },
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title).medium().semiBold(),
                    const Gap(4),
                    Text(description).small().muted(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputScore(String key, String info, String placeholder, String correctAnswer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(info).medium(),
          ),
        ),
        const Gap(16),

        TextField(
          placeholder: Text(placeholder),
          onChanged: (value) {
            setState(() {
              _results['${key}_answer'] = value;
              _results[key] = value.trim().toLowerCase() == correctAnswer.toLowerCase() ? 1 : 0;
            });
          },
        ),
        const Gap(16),

        if (_results.containsKey('${key}_answer'))
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_results[key] == 1
                      ? Colors.green
                      : Colors.red)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _results[key] == 1 ? material.Icons.check_circle : material.Icons.cancel,
                  color: _results[key] == 1 ? Colors.green : Colors.red,
                  size: 20,
                ),
                const Gap(8),
                Text(
                  _results[key] == 1 ? 'Correcto (1 punto)' : 'Incorrecto (0 puntos)',
                ).medium(),
              ],
            ),
          ),
      ],
    );
  }
}

