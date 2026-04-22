import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/features/surveys/presentation/consent_controller.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/widgets/tts/consent_tts_cards.dart';
import 'package:ssapp/shared/services/tts/survey_tts_text_builder.dart';
import 'package:ssapp/shared/widgets/tts/tts_button.dart';

// Responsabilidad: renderizar el formulario de consentimiento y delegar su logica al controller.
class ConsentFormScreen extends StatefulWidget {
  final String? surveyType;
  // Si se provee, mostrará este texto de consentimiento en lugar del texto por defecto.
  final String? consentText;
  // Si es false, al enviar el consent form la pantalla no hará la navegacion hacia la encuesta;
  // en su lugar retornará los datos al llamador para que este maneje el flujo (usado por investigaciones).
  final bool autoNavigate;
  // Mostrar o esconder la sección de selección/creación de paciente
  final bool showPatientSection;
  // Mostrar o esconder la casilla de consentimiento (cuando solo se quiere pedir datos antropométricos)
  final bool showConsentSection;
  // Opcional: preseleccionar un paciente por su id cuando la lista de pacientes esté cargada.
  final int? initialPatientId;

  const ConsentFormScreen({
    super.key,
    this.surveyType,
    this.consentText,
    this.autoNavigate = true,
    this.showPatientSection = true,
    this.showConsentSection = true,
    this.initialPatientId,
  });

  @override
  State<ConsentFormScreen> createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends State<ConsentFormScreen> {
  late final ConsentFormController _controller;

  // Osteoporosis fields
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _imcController = TextEditingController();
  final _nameController = TextEditingController();

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {
      _imcController.text = _controller.imcText;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ConsentFormController(surveyType: widget.surveyType);
    _controller.addListener(_onControllerChanged);

    // Cargar pacientes y si se proporcionó initialPatientId, preseleccionarlo.
    _controller.loadAvailablePatients(context.read<PatientService>()).then((_) {
      if (widget.initialPatientId != null) {
        final patients = context.read<PatientService>().patients;
        final matches = patients.where((p) => p.patientId == widget.initialPatientId).toList();
        if (matches.isNotEmpty) {
          final patient = matches.first;
          _controller.selectPatient(patient);
          _nameController.text = _controller.name;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _nameController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _imcController.dispose();
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

  Future<void> _submit() async {
    try {
      final patientService = context.read<PatientService>();
      final patientId = await _controller.submit(
        patientService,
        requireConsent: widget.showConsentSection,
        requirePatient: widget.showPatientSection,
      );

      if (!mounted) return;

      bool shouldContinue = true;
      if (widget.surveyType != null) {
        shouldContinue = await _showInstructionsDialog(
          context,
          surveyType: _controller.resolvedSurveyType,
          surveyColor: SurveyTypeConfig.colorFor(_controller.resolvedSurveyType),
        );
      }

      if (!shouldContinue) return;

      // Si autoNavigate está activo (comportamiento por defecto), navegamos hacia la encuesta.
      if (widget.autoNavigate) {
        if (_controller.resolvedSurveyType == 'osteoporosis') {
          context.push(
            '/survey/$patientId?surveyType=${_controller.resolvedSurveyType}&weight=${_controller.weight ?? ''}&height=${_controller.height ?? ''}&imc=${_controller.imc ?? ''}',
          );
        } else {
          context.push('/survey/$patientId?surveyType=${_controller.resolvedSurveyType}');
        }
      } else {
        // En modo no-auto navegacion, retornamos los datos al llamador para que haga link de participante
        // y gestione la navegacion (uso en flujo de investigaciones).
        final result = {
          'patientId': patientId,
          'surveyType': _controller.resolvedSurveyType,
          'weight': _controller.weight,
          'height': _controller.height,
          'imc': _controller.imc,
        };
        material.Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (!mounted) return;
      final rawMessage = e.toString();
      final message = rawMessage.startsWith('Exception: ')
          ? rawMessage.replaceFirst('Exception: ', '')
          : 'Ocurrió un error: $rawMessage';
      _showError(message);
    }
  }

  static Future<bool> _showInstructionsDialog(
      BuildContext context, {
        required String surveyType,
        required Color surveyColor,
      }) async {
    final instruction = SurveyTypeConfig.instructionFor(surveyType);
    final variant = instruction.variant;
    final isBai = variant == SurveyInstructionVariant.bai;
    final isMoca = variant == SurveyInstructionVariant.moca;
    final isGds = variant == SurveyInstructionVariant.gds;
    final isLawton = variant == SurveyInstructionVariant.lawton;
    final isKatz = variant == SurveyInstructionVariant.katz;
    final isIciqSf = variant == SurveyInstructionVariant.iciqSf;
    final isWhoqol = variant == SurveyInstructionVariant.whoqol;
    final isAssist = variant == SurveyInstructionVariant.assist;
    final isOsteoporosis = variant == SurveyInstructionVariant.osteoporosis;

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
                              instruction.title,
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
                      instruction.instructions,
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
                    ] else if (isOsteoporosis) ...[
                      _ScaleItem(
                        icon: Symbols.check_circle,
                        label: 'Sí / No',
                        description: 'Marque con una X la respuesta correspondiente para cada pregunta.',
                        color: const Color(0xFF145374),
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
                    ] else if (isKatz) ...[
                      _ScaleItem(
                        icon: Symbols.check_circle,
                        label: 'Independiente = 1',
                        description: 'Independencia total o con minima ayuda.',
                        color: const Color(0xFF0D9488),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.warning,
                        label: 'Dependiente = 0',
                        description: 'Requiere ayuda o supervision significativa.',
                        color: const Color(0xFFF59E0B),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.rule,
                        label: 'Resultado y clasificacion',
                        description: 'Puntaje 0–6 y clasificacion Katz A–H segun patron de dependencia.',
                        color: const Color(0xFF115E59),
                      ),
                    ] else if (isIciqSf) ...[
                      _ScaleItem(
                        icon: Symbols.calculate,
                        label: 'Puntaje total (0–21)',
                        description: 'Se calcula como P1 + P2 + P3. La pregunta 4 no suma.',
                        color: const Color(0xFF2563EB),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.rule,
                        label: 'Interpretacion',
                        description: '0: Sin incontinencia | >0: Presencia de incontinencia con severidad.',
                        color: const Color(0xFF1D4ED8),
                      ),
                      const Gap(8),
                      _ScaleItem(
                        icon: Symbols.list_alt,
                        label: 'Pregunta 4 (multiple)',
                        description: 'Permite seleccionar varias situaciones para orientar el tipo clinico.',
                        color: const Color(0xFF1E40AF),
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
    final osteoporosisAgeInvalid = _controller.osteoporosisAgeInvalid;
    final surveyColor = SurveyTypeConfig.colorFor(widget.surveyType);
    return Scaffold(
      headers: [
        AppBar(
          title: Text(widget.showPatientSection ? 'Consentimiento Informado' : 'Datos antropométricos'),
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
            if (widget.consentText != null && widget.consentText!.trim().isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(material.Icons.info_outline, color: surveyColor),
                          const Gap(8),
                          const Text('Consentimiento Informado').semiBold(),
                          TtsButton(
                            text: SurveyTtsTextBuilder.consent(widget.consentText!),
                          ),
                        ],
                      ),
                      const Gap(16),
                      Text(widget.consentText!).muted(),
                    ],
                  ),
                ),
              )
            else
              ConsentInfoTtsCard(surveyType: widget.surveyType),
            const Gap(24),

            if (widget.showPatientSection) ...[
              const Text('Datos del Paciente').textLarge().bold(),
              const Gap(16),

              const Text('Seleccionar paciente existente o crear nuevo').medium(),
              const Gap(8),
              _controller.isLoadingPatients
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
                        color: surveyColor,
                      ),
                    ),
                    const Gap(12),
                    const Text('Cargando pacientes...'),
                  ],
                ),
              )
                  : Select<PatientModel?>(
                value: _controller.selectedPatient,
                onChanged: (patient) {
                  if (patient != null) {
                    _controller.selectPatient(patient);
                    _nameController.text = _controller.name;
                  } else {
                    _controller.clearSelectedPatient();
                    _nameController.clear();
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
                      ..._controller.availablePatients.map((patient) {
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

              if (_controller.selectedPatient == null) ...[
                const Text('Nombre completo').medium(),
                const Gap(5),
                TextField(
                  controller: _nameController,
                  placeholder: const Text('Nombre completo'),
                  onChanged: _controller.onNameChanged,
                ),
                const Gap(16),
              ],

              const Text('Fecha de Nacimiento').medium(),
              const Gap(5),
              DatePicker(
                value: _controller.dateOfBirth,
                mode: PromptMode.dialog,
                placeholder: const Text('Seleccione una fecha'),
                stateBuilder: (date) {
                  if (date.isAfter(DateTime.now())) {
                    return DateState.disabled;
                  }
                  return DateState.enabled;
                },
                onChanged: (value) {
                  _controller.onDateOfBirthChanged(value);
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
                    isSelected: _controller.gender == 'M',
                    icon: material.Icons.male,
                    onTap: () => _controller.onGenderChanged('M'),
                  ),
                  _GenderOption(
                    label: 'Femenino',
                    code: 'F',
                    isSelected: _controller.gender == 'F',
                    icon: material.Icons.female,
                    onTap: () => _controller.onGenderChanged('F'),
                  ),
                  _GenderOption(
                    label: 'Otro',
                    code: 'O',
                    isSelected: _controller.gender == 'O',
                    icon: material.Icons.transgender,
                    onTap: () => _controller.onGenderChanged('O'),
                  ),
                  _GenderOption(
                    label: 'Prefiero no decir',
                    code: 'N',
                    isSelected: _controller.gender == 'N',
                    icon: material.Icons.help_outline,
                    onTap: () => _controller.onGenderChanged('N'),
                  ),
                ],
              ),
              const Gap(16),
            ],

            // Osteoporosis: Peso, Talla, IMC
            if (_controller.isOsteoporosisSurvey) ...[
              const Text('Peso (Kg)').medium(),
              const Gap(5),
              TextField(
                controller: _pesoController,
                keyboardType: TextInputType.number,
                placeholder: const Text('Ejemplo: 70'),
                onChanged: (value) {
                  _controller.onWeightChanged(value);
                  _imcController.text = _controller.imcText;
                },
              ),
              const Gap(12),
              const Text('Talla (mts)').medium(),
              const Gap(5),
              TextField(
                controller: _tallaController,
                keyboardType: TextInputType.number,
                placeholder: const Text('Ejemplo: 1.65'),
                onChanged: (value) {
                  _controller.onHeightChanged(value);
                  _imcController.text = _controller.imcText;
                },
              ),
              const Gap(12),
              const Text('IMC').medium(),
              const Gap(5),
              TextField(
                controller: _imcController,
                keyboardType: TextInputType.number,
                placeholder: const Text('Ejemplo: 25.7'),
                readOnly: true,
              ),
              const Gap(8),
              if (_controller.osteoporosisWarning != null) ...[
                Text(
                  _controller.osteoporosisWarning!,
                  style: const TextStyle(color: material.Colors.red, fontWeight: FontWeight.w600),
                ),
                const Gap(8),
              ],
            ],

            if (widget.showConsentSection)
              GestureDetector(
                onTap: () => _controller.onConsentChanged(!_controller.consentGiven),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      state: _controller.consentGiven ? CheckboxState.checked : CheckboxState.unchecked,
                      onChanged: (state) => _controller.onConsentChanged(state == CheckboxState.checked),
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

            if (osteoporosisAgeInvalid) ...[
              const Gap(8),
              Text(
                'Solo disponible para pacientes de 50 años o más.',
                style: TextStyle(color: material.Colors.red, fontWeight: FontWeight.bold),
              ),
              const Gap(8),
            ],
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: (_controller.isLoading || osteoporosisAgeInvalid) ? null : _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (_controller.isLoading || osteoporosisAgeInvalid)
                        ? surveyColor.withValues(alpha: 0.5)
                        : surveyColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _controller.isLoading
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

  @override
  Widget build(BuildContext context) {
    final color = SurveyTypeConfig.colorFor(surveyType);

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
            Text(SurveyTypeConfig.descriptionFor(surveyType)).muted(),
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
