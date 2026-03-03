import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/utils/theme.dart';

class ConsentFormScreen extends StatefulWidget {
  final String? surveyType;

  const ConsentFormScreen({super.key, this.surveyType});

  @override
  State<ConsentFormScreen> createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends State<ConsentFormScreen> {
  final _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'Masculino';
  bool _consentGiven = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
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

  Color _getSurveyColor() {
    switch (widget.surveyType) {
      case 'bai':
        return LightModeColors.lightTertiary;
      case 'bdi':
      default:
        return LightModeColors.lightPrimary;
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Por favor ingrese el nombre completo');
      return;
    }
    if (_dateOfBirth == null) {
      _showError('Por favor seleccione la fecha de nacimiento');
      return;
    }
    if (!_consentGiven) {
      _showError('Debe aceptar el consentimiento informado para continuar');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final patientService = context.read<PatientService>();
      final patient = await patientService.createPatient(
        name: _nameController.text.trim(),
        birthDate: _dateOfBirth!,
        gender: _gender,
      );

      if (!mounted) return;

      if (patient != null) {
        // Show instructions dialog before starting the survey
        if (mounted) {
          await _showInstructionsDialog(
            context,
            surveyType: widget.surveyType ?? 'bdi',
            surveyColor: _getSurveyColor(),
            onContinue: () {
              context.push('/survey/${patient.patientId}?surveyType=${widget.surveyType ?? "bdi"}');
            },
          );
        }
      } else {
        _showError('No se pudo crear el registro del paciente. Por favor intente nuevamente.');
      }
    } catch (e) {
      if (mounted) {
        _showError('Ocurrió un error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static Future<void> _showInstructionsDialog(
    BuildContext context, {
    required String surveyType,
    required Color surveyColor,
    required VoidCallback onContinue,
  }) async {
    final isBai = surveyType == 'bai';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.all(24),
          decoration: material.BoxDecoration(
            color: material.Colors.white,
            borderRadius: material.BorderRadius.circular(20),
            boxShadow: [
              material.BoxShadow(
                color: material.Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const material.Offset(0, 8),
              ),
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
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: surveyColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          material.Icons.help_outline_rounded,
                          color: surveyColor,
                          size: 28,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Instrucciones',
                            ).textLarge().bold(),
                            Text(
                              isBai
                                  ? 'Inventario de Ansiedad de Beck (BAI)'
                                  : 'Inventario de Depresión de Beck (BDI-II)',
                              style: TextStyle(
                                fontSize: 13,
                                color: surveyColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  // Explanation text
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surveyColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: surveyColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      isBai
                          ? 'A continuación encontrará una lista de síntomas. Por favor, indique cuánto le ha molestado cada síntoma durante la última semana, incluyendo hoy.'
                          : 'Este cuestionario consta de 21 grupos de afirmaciones. Por favor, lea con cuidado cada grupo y elija la que mejor describe cómo se ha sentido durante las últimas dos semanas, incluyendo hoy.',
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                  const Gap(20),
                  // Scale explanation title
                  const Text('¿Qué significa cada opción?').medium().semiBold(),
                  const Gap(12),
                  // Scale items
                  if (isBai) ...[
                    _ScaleItem(
                      icon: Symbols.sentiment_very_satisfied,
                      label: 'En absoluto',
                      description: 'No me ha afectado nada o casi nada.',
                      color: const Color(0xFF16A34A),
                    ),
                    const Gap(8),
                    _ScaleItem(
                      icon: Symbols.sentiment_satisfied,
                      label: 'Levemente',
                      description: 'Me ha afectado un poco, pero no me ha perturbado mucho.',
                      color: const Color(0xFF65A30D),
                    ),
                    const Gap(8),
                    _ScaleItem(
                      icon: Symbols.sentiment_dissatisfied,
                      label: 'Moderadamente',
                      description: 'Me ha afectado bastante y fue muy desagradable.',
                      color: const Color(0xFFF59E0B),
                    ),
                    const Gap(8),
                    _ScaleItem(
                      icon: Symbols.sentiment_very_dissatisfied,
                      label: 'Severamente',
                      description: 'Apenas podía soportarlo.',
                      color: const Color(0xFFDC2626),
                    ),
                  ] else ...[
                    _ScaleItem(
                      icon: Symbols.sentiment_very_satisfied,
                      label: 'Opción 0',
                      description: 'No lo experimento o no me aplica en este momento.',
                      color: const Color(0xFF16A34A),
                    ),
                    const Gap(8),
                    _ScaleItem(
                      icon: Symbols.sentiment_satisfied,
                      label: 'Opción 1',
                      description: 'Lo experimento algunas veces o de manera leve.',
                      color: const Color(0xFF65A30D),
                    ),
                    const Gap(8),
                    _ScaleItem(
                      icon: Symbols.sentiment_dissatisfied,
                      label: 'Opción 2',
                      description: 'Lo experimento con más frecuencia o de forma notable.',
                      color: const Color(0xFFF59E0B),
                    ),
                    const Gap(8),
                    _ScaleItem(
                      icon: Symbols.sentiment_very_dissatisfied,
                      label: 'Opción 3',
                      description: 'Lo experimento casi siempre o de manera muy intensa.',
                      color: const Color(0xFFDC2626),
                    ),
                  ],
                  const Gap(20),
                  // Tip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        material.Icons.lightbulb_outline,
                        color: surveyColor,
                        size: 20,
                      ),
                      const Gap(8),
                      const Expanded(
                        child: Text(
                          'No hay respuestas correctas o incorrectas. Responda lo más honestamente posible según cómo se ha sentido.',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () {
                        material.Navigator.of(ctx).pop();
                        onContinue();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Comenzar encuesta'),
                          Gap(8),
                          Icon(material.Icons.arrow_forward, size: 18),
                        ],
                      ),
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
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Consentimiento Informado'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => material.Navigator.of(context).pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConsentInfoCard(surveyType: widget.surveyType),
            const Gap(24),

            const Text('Datos del Paciente').textLarge().bold(),
            const Gap(16),

            // Nombre completo
            const Text('Nombre completo').medium(),
            const Gap(5),
            TextField(
              controller: _nameController,
              placeholder: const Text('Nombre completo'),
            ),
            const Gap(16),

            // Fecha de nacimiento
            const Text('Fecha de Nacimiento').medium(),
            const Gap(5),
            DatePicker(
              value: _dateOfBirth,
              mode: PromptMode.dialog,
              placeholder: const Text('Seleccione una fecha'),
              stateBuilder: (date) {
                if (date.isAfter(DateTime.now())) {
                  return DateState.disabled;
                }
                return DateState.enabled;
              },
              onChanged: (value) {
                setState(() {
                  _dateOfBirth = value;
                });
              },
            ),
            const Gap(16),

            // Sexo - usando Radio buttons simples
            const Text('Sexo').medium(),
            const Gap(5),
            Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _gender = 'Masculino'),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Radio(
                            value: _gender == 'Masculino',
                          ),
                          const Gap(8),
                          const Text('Masculino'),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                GestureDetector(
                  onTap: () => setState(() => _gender = 'Femenino'),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          Radio(
                            value: _gender == 'Femenino',
                          ),
                          const Gap(8),
                          const Text('Femenino'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),

            // Checkbox de consentimiento
            GestureDetector(
              onTap: () => setState(() => _consentGiven = !_consentGiven),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    state: _consentGiven ? CheckboxState.checked : CheckboxState.unchecked,
                    onChanged: (state) => setState(() => _consentGiven = state == CheckboxState.checked),
                  ),
                  const Gap(8),
                  Expanded(
                    child: const Text(
                      'Acepto participar voluntariamente en esta evaluación y consiento el uso de mis datos para fines de investigación.',
                    ).small(),
                  ),
                ],
              ),
            ),
            const Gap(32),

            // Botón de submit
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _isLoading ? null : _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? _getSurveyColor().withValues(alpha: 0.5)
                        : _getSurveyColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(8),
                            const Text(
                              'Procesando...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Continuar con la encuesta',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConsentInfoCard extends StatelessWidget {
  final String? surveyType;

  const ConsentInfoCard({super.key, this.surveyType});

  String _getSurveyDescription() {
    switch (surveyType) {
      case 'bai':
        return 'Este cuestionario evalúa síntomas de ansiedad mediante el Inventario de Ansiedad de Beck (BAI). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'bdi':
      default:
        return 'Este cuestionario evalúa síntomas de depresión mediante el Inventario de Depresión de Beck (BDI-II). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
    }
  }

  Color _getSurveyColor() {
    switch (surveyType) {
      case 'bai':
        return LightModeColors.lightTertiary;
      case 'bdi':
      default:
        return LightModeColors.lightPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSurveyColor();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  material.Icons.info_outline,
                  color: color,
                ),
                const Gap(8),
                const Text('Información Importante').semiBold(),
              ],
            ),
            const Gap(16),
            Text(_getSurveyDescription()).muted(),
            const Gap(16),
            const Text(
              '• Su participación es completamente voluntaria\n'
              '• Toda la información será tratada con confidencialidad\n'
              '• Los resultados serán utilizados para mejorar la atención psicológica',
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}

/// A single scale row used in the instructions dialog
class _ScaleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;

  const _ScaleItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 26, fill: 1),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const Gap(2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

