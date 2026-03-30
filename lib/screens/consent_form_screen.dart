import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/models/patient_model.dart';
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
  String _gender = 'M'; // Masculino
  bool _consentGiven = false;
  bool _isLoading = false;
  PatientModel? _selectedPatient;
  List<PatientModel> _availablePatients = [];
  bool _isLoadingPatients = false;

  @override
  void initState() {
    super.initState();
    _loadAvailablePatients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailablePatients() async {
    setState(() => _isLoadingPatients = true);
    try {
      final patientService = context.read<PatientService>();
      setState(() {
        _availablePatients = patientService.patients;
      });
    } catch (e) {
      print('Error loading patients: $e');
    } finally {
      setState(() => _isLoadingPatients = false);
    }
  }

  void _selectPatient(PatientModel patient) {
    setState(() {
      _selectedPatient = patient;
      _nameController.text = patient.name;
      _dateOfBirth = patient.birthDate;
      _gender = patient.gender;
    });
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
      case 'moca':
        return LightModeColors.lightSecondary;
      case 'gds':
        return const Color(0xFF0EA5E9);
      case 'lawton':
        return const Color(0xFF14B8A6);
      case 'whoqol':
        return const Color(0xFF7C3AED);
      case 'sf36':
        return const Color(0xFF06B6D4);
      case 'assist':
        return LightModeColors.lightSecondary;
      case 'bdi':
      default:
        return LightModeColors.lightPrimary;
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Por favor ingrese el nombre completo o seleccione un paciente');
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

      // Si ya existe el paciente seleccionado, usarlo; si no, crear uno nuevo
      PatientModel? patient;
      if (_selectedPatient != null) {
        patient = _selectedPatient;
      } else {
        patient = await patientService.createPatient(
          name: _nameController.text.trim(),
          birthDate: _dateOfBirth!,
          gender: _gender,
        );
      }

      if (!mounted) return;

      if (patient != null) {

        final resolvedSurveyType = widget.surveyType ?? 'bdi';
        final patientId = patient.patientId;

        if (mounted) {
          final shouldContinue = await _showInstructionsDialog(
            context,
            surveyType: resolvedSurveyType,
            surveyColor: _getSurveyColor(),
          );
          if (shouldContinue && mounted) {
            context.push('/survey/$patientId?surveyType=$resolvedSurveyType');
          }
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

  static Future<bool> _showInstructionsDialog(
    BuildContext context, {
    required String surveyType,
    required Color surveyColor,
  }) async {
    final isBai = surveyType == 'bai';
    final isMoca = surveyType == 'moca';
    final isGds = surveyType == 'gds';
    final isLawton = surveyType == 'lawton';
    final isWhoqol = surveyType == 'whoqol';
    final isSf36 = surveyType == 'sf36';
    final isAssist = surveyType == 'assist';

    String surveyTitle;
    String surveyInstructions;
    if (isBai) {
      surveyTitle = 'Inventario de Ansiedad de Beck (BAI)';
      surveyInstructions = 'A continuación encontrará una lista de síntomas. Por favor, indique cuánto le ha molestado cada síntoma durante la última semana, incluyendo hoy.';
    } else if (isMoca) {
      surveyTitle = 'Evaluación Cognitiva Montreal (MoCA)';
      surveyInstructions = 'A continuación se le presentarán una serie de tareas y preguntas que evalúan diferentes áreas de su funcionamiento cognitivo. Siga las instrucciones de cada actividad con atención. No hay respuestas buenas o malas, simplemente haga su mejor esfuerzo.';
    } else if (isGds) {
      surveyTitle = 'Escala de Depresión Geriátrica (GDS-15)';
      surveyInstructions = 'Este cuestionario consta de 15 preguntas con respuesta Sí o No. Responda según cómo se ha sentido recientemente. No hay respuestas correctas o incorrectas.';
    } else if (isLawton) {
      surveyTitle = 'Escala de Lawton (AIVD)';
      surveyInstructions = 'Este cuestionario evalúa su nivel de independencia en actividades instrumentales de la vida diaria. Seleccione la opción que mejor describa su capacidad actual en cada actividad.';
    } else if (isWhoqol) {
      surveyTitle = 'Cuestionario de Calidad de Vida (WHOQOL-BREF)';
      surveyInstructions = 'Este cuestionario le pregunta cómo se ha sentido acerca de su calidad de vida, su salud y otros aspectos de su vida durante las dos últimas semanas. Por favor, responda todas las preguntas. Si no está seguro/a de qué respuesta dar a una pregunta, escoja la que le parezca más apropiada.';
    } else if (isSf36) {
      surveyTitle = 'Encuesta de Salud de 36 Items (SF-36)';
      surveyInstructions = 'Este cuestionario evalúa diferentes aspectos de su salud y bienestar. Por favor, responda cada pregunta según cómo se ha sentido o qué ha podido hacer durante las últimas cuatro semanas. No hay respuestas correctas o incorrectas, simplemente elija la opción que mejor describa su situación.';
    } else if (isAssist) {
      surveyTitle = 'OMS-ASSIST V3.0';
      surveyInstructions = 'Este cuestionario detecta riesgo asociado al consumo de tabaco, alcohol y otras sustancias. Primero se registra consumo alguna vez en la vida y luego frecuencia/problemas en los últimos 3 meses para cada sustancia seleccionada. Responda con la mayor precisión posible.';
    } else {
      surveyTitle = 'Inventario de Depresión de Beck (BDI-II)';
      surveyInstructions = 'Este cuestionario consta de 21 grupos de afirmaciones. Por favor, lea con cuidado cada grupo y elija la que mejor describe cómo se ha sentido durante las últimas dos semanas, incluyendo hoy.';
    }

    final result = await showDialog<bool>(
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
                            const Text('Instrucciones').textLarge().bold(),
                            Text(
                              surveyTitle,
                              style: TextStyle(fontSize: 13, color: surveyColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surveyColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: surveyColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      surveyInstructions,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                  if (!isMoca) ...[
                    const Gap(20),
                    const Text('¿Qué significa cada opción?').medium().semiBold(),
                    const Gap(12),
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
                    ] else if (isGds) ...[
                      _ScaleItem(
                        icon: Symbols.check_circle,
                        label: 'Sí / No',
                        description: 'Seleccione la opción que mejor refleje su situación actual.',
                        color: const Color(0xFF0EA5E9),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.calculate,
                        label: 'Puntaje total (0–15)',
                        description: 'Cada pregunta suma 0 o 1 según la clave de corrección de GDS-15.',
                        color: const Color(0xFF0284C7),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.rule,
                        label: 'Interpretación',
                        description: '0–4: Normal | 5–15: Síntomas depresivos.',
                        color: const Color(0xFF0369A1),
                      ),
                    ] else if (isLawton) ...[
                      _ScaleItem(
                        icon: Symbols.check_circle,
                        label: 'Capacidad actual',
                        description: 'Seleccione la opción que mejor describa su independencia en cada actividad.',
                        color: const Color(0xFF14B8A6),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.calculate,
                        label: 'Puntaje total (0–8)',
                        description: 'Cada item aporta 1 punto si la actividad se realiza con independencia.',
                        color: const Color(0xFF0F766E),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.rule,
                        label: 'Interpretación',
                        description: '8: Independencia total | 0–7: Deterioro funcional.',
                        color: const Color(0xFF115E59),
                      ),
                    ] else if (isWhoqol) ...[
                      _ScaleItem(
                        icon: Symbols.sentiment_very_satisfied,
                        label: '1 — Nada / Muy insatisfecho/a / Nunca',
                        description: 'La situación descrita no aplica o está completamente ausente.',
                        color: const Color(0xFF16A34A),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.sentiment_satisfied,
                        label: '2 — Un poco / Insatisfecho/a / Raramente',
                        description: 'La situación aplica de manera mínima o poco frecuente.',
                        color: const Color(0xFF65A30D),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.sentiment_neutral,
                        label: '3 — Lo normal / Moderado / Medianamente',
                        description: 'La situación aplica de forma moderada o es más o menos frecuente.',
                        color: const Color(0xFFF59E0B),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.sentiment_dissatisfied,
                        label: '4 — Bastante / Satisfecho/a / Frecuentemente',
                        description: 'La situación aplica bastante o con frecuencia.',
                        color: const Color(0xFFEA580C),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.sentiment_very_dissatisfied,
                        label: '5 — Extremadamente / Muy satisfecho/a / Siempre',
                        description: 'La situación aplica en el máximo grado posible.',
                        color: const Color(0xFFDC2626),
                      ),
                    ] else if (isAssist) ...[
                      _ScaleItem(
                        icon: Symbols.check_circle,
                        label: 'Frecuencia en 3 meses',
                        description: 'Nunca / 1-2 veces / Cada mes / Cada semana / A diario.',
                        color: const Color(0xFF0EA5E9),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.rule,
                        label: 'Puntaje por sustancia',
                        description: 'Se suma P2+P3+P4+P5+P6+P7 (tabaco no incluye P5).',
                        color: const Color(0xFF0284C7),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.warning,
                        label: 'Vía inyectada',
                        description: 'Se registra aparte como advertencia clínica, no suma al puntaje por sustancia.',
                        color: const Color(0xFFDC2626),
                      ),
                    ] else ...[
                      _ScaleItem(
                        icon: Symbols.sentiment_very_satisfied,
                        label: 'Opción 1',
                        description: 'No lo experimento o no me aplica en este momento.',
                        color: const Color(0xFF16A34A),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.sentiment_satisfied,
                        label: 'Opción 2',
                        description: 'Lo experimento algunas veces o de manera leve.',
                        color: const Color(0xFF65A30D),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.sentiment_dissatisfied,
                        label: 'Opción 3',
                        description: 'Lo experimento con más frecuencia o de forma notable.',
                        color: const Color(0xFFF59E0B),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.sentiment_very_dissatisfied,
                        label: 'Opción 4',
                        description: 'Lo experimento casi siempre o de manera muy intensa.',
                        color: const Color(0xFFDC2626),
                      ),
                    ],
                  ],
                  const Gap(20),
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
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () {
                        material.Navigator.of(ctx).pop(true);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Comenzar'),
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
    return result ?? false;
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

            const Text('Seleccionar paciente existente o crear nuevo').medium(),
            const Gap(8),
            _isLoadingPatients
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: LightModeColors.lightOutline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _getSurveyColor(),
                          ),
                        ),
                        const Gap(12),
                        const Text('Cargando pacientes...'),
                      ],
                    ),
                  )
                : Select<PatientModel?>(
                    value: _selectedPatient,
                    onChanged: (patient) {
                      if (patient != null) {
                        _selectPatient(patient);
                      } else {
                        setState(() {
                          _selectedPatient = null;
                          _nameController.clear();
                          _dateOfBirth = null;
                        });
                      }
                    },
                    itemBuilder: (context, patient) {
                      if (patient == null) {
                        return const Text('Crear nuevo paciente');
                      }
                      return Text('${patient.name} (${patient.age} años)');
                    },
                    popup: SelectPopup(
                      items: SelectItemList(
                        children: [
                          const SelectItemButton(
                            value: null,
                            child: Text('Crear nuevo paciente'),
                          ),
                          ..._availablePatients.map((patient) {
                            return SelectItemButton(
                              value: patient,
                              child: Text('${patient.name} (${patient.age} años)'),
                            );
                          }),
                        ],
                      ),
                    ).call,
                    placeholder: const Text('Seleccionar o crear paciente'),
                  ),
            const Gap(16),

            if (_selectedPatient == null) ...[
              const Text('Nombre completo').medium(),
              const Gap(5),
              TextField(
                controller: _nameController,
                placeholder: const Text('Nombre completo'),
              ),
              const Gap(16),
            ],

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

            const Text('Sexo').medium(),
            const Gap(8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _GenderOption(
                  label: 'Masculino',
                  code: 'M',
                  isSelected: _gender == 'M',
                  icon: material.Icons.male,
                  onTap: () => setState(() => _gender = 'M'),
                ),
                _GenderOption(
                  label: 'Femenino',
                  code: 'F',
                  isSelected: _gender == 'F',
                  icon: material.Icons.female,
                  onTap: () => setState(() => _gender = 'F'),
                ),
                _GenderOption(
                  label: 'Otro',
                  code: 'O',
                  isSelected: _gender == 'O',
                  icon: material.Icons.transgender,
                  onTap: () => setState(() => _gender = 'O'),
                ),
                _GenderOption(
                  label: 'Prefiero no decir',
                  code: 'N',
                  isSelected: _gender == 'N',
                  icon: material.Icons.help_outline,
                  onTap: () => setState(() => _gender = 'N'),
                ),
              ],
            ),
            const Gap(16),

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

class _GenderOption extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OutlinedContainer(
        backgroundColor: isSelected ? LightModeColors.lightPrimary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        borderColor: isSelected
            ? LightModeColors.lightPrimary
            : LightModeColors.lightOutline.withValues(alpha: 0.5),
        borderWidth: isSelected ? 2 : 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? LightModeColors.lightPrimary : LightModeColors.lightOnSurface,
            ),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
                color: isSelected ? LightModeColors.lightPrimary : LightModeColors.lightOnSurface,
              ),
            ),
            if (isSelected) ...[
              const Gap(8),
              Icon(
                material.Icons.check_circle,
                size: 18,
                color: LightModeColors.lightPrimary,
              ),
            ],
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
      case 'gds':
        return 'Este cuestionario evalúa síntomas depresivos en personas mayores mediante la Escala de Depresión Geriátrica de 15 items (GDS-15). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'lawton':
        return 'Este cuestionario evalúa la independencia en actividades instrumentales de la vida diaria mediante la Escala de Lawton (AIVD). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'moca':
        return 'Esta evaluación cognitiva evalúa diferentes dominios cognitivos mediante la Evaluación Cognitiva Montreal (MoCA). Evalúa atención, concentración, funciones ejecutivas, memoria, lenguaje, habilidades visuoconstructivas, pensamiento conceptual, cálculo y orientación. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'whoqol':
        return 'Este cuestionario evalúa la calidad de vida en cuatro dominios: salud física, salud psicológica, relaciones sociales y ambiente, mediante el instrumento WHOQOL-BREF de la Organización Mundial de la Salud. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'sf36':
        return 'Este cuestionario evalúa diferentes aspectos de la salud y el bienestar mediante la Encuesta de Salud de 36 Items (SF-36). Evalúa funcionamiento físico, rol físico, dolor corporal, salud general, vitalidad, funcionamiento social, rol emocional y salud mental. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'assist':
        return 'Este cuestionario evalúa riesgo asociado al consumo de tabaco, alcohol y otras sustancias mediante el instrumento OMS-ASSIST V3.0. Los resultados orientan el nivel de intervención (sin intervención, intervención breve o tratamiento intensivo). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
      case 'bdi':
      default:
        return 'Este cuestionario evalúa síntomas de depresión mediante el Inventario de Depresión de Beck (BDI-II). Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
    }
  }

  Color _getSurveyColor() {
    switch (surveyType) {
      case 'bai':
        return LightModeColors.lightTertiary;
      case 'moca':
        return LightModeColors.lightSecondary;
      case 'gds':
        return const Color(0xFF0EA5E9);
      case 'lawton':
        return const Color(0xFF14B8A6);
      case 'whoqol':
        return const Color(0xFF7C3AED);
      case 'sf36':
        return const Color(0xFF06B6D4);
      case 'assist':
        return LightModeColors.lightSecondary;
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

