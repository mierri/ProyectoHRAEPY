import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';
import 'package:ssapp/features/surveys/presentation/consent_controller.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/features/surveys/presentation/consent_form/components/consent_info_card.dart';
import 'package:ssapp/features/surveys/presentation/consent_form/components/gender_option.dart';
import 'package:ssapp/features/surveys/presentation/consent_form/components/scale_item.dart';
import 'package:ssapp/features/surveys/presentation/consent_form/components/survey_instructions_dialog.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/widgets/tts/consent_tts_cards.dart';
import 'package:ssapp/shared/services/tts/survey_tts_text_builder.dart';
import 'package:ssapp/shared/widgets/tts/tts_button.dart';
import 'package:ssapp/shared/widgets/date_text_field.dart';
import 'package:ssapp/shared/widgets/lumi/lumi_widget.dart';

// Responsabilidad: renderizar el formulario de consentimiento y delegar su logica al controller.
class ConsentFormScreen extends StatefulWidget {
  final String? surveyType;
  // Si se provee, mostrará este texto de consentimiento en lugar del texto por defecto.
  final String? consentText;
  final bool autoNavigate;
  final bool showPatientSection;
  final bool showConsentSection;
  final int? initialPatientId;
  // Cuando true, el texto de consentimiento se muestra colapsado con un "ver más"
  // y los checkboxes aparecen en modo solo-lectura (ya aceptados en la pantalla anterior).
  final bool collapseConsent;
  final List<String> readOnlyCheckboxLabels;

  const ConsentFormScreen({
    super.key,
    this.surveyType,
    this.consentText,
    this.autoNavigate = true,
    this.showPatientSection = true,
    this.showConsentSection = true,
    this.initialPatientId,
    this.collapseConsent = false,
    this.readOnlyCheckboxLabels = const [],
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

  bool _consentExpanded = false;

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
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SurveyInstructionsDialog(
        surveyType: surveyType,
        surveyColor: surveyColor,
        onStart: () => material.Navigator.of(ctx).pop(true),
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
            if (!widget.collapseConsent && widget.showConsentSection)
              Center(
                child: LumiWidget(
                  variant: LumiVariant.deciding,
                  size: 150,
                ),
              ),
            if (!widget.collapseConsent && widget.showConsentSection)
              const Gap(16),
            if (widget.consentText != null && widget.consentText!.trim().isNotEmpty)
              widget.collapseConsent
                  ? _CollapsibleConsentCard(
                      consentText: widget.consentText!,
                      isExpanded: _consentExpanded,
                      onToggle: () => setState(() => _consentExpanded = !_consentExpanded),
                      checkboxLabels: widget.readOnlyCheckboxLabels,
                    )
                  : Card(
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
              LumiHeaderRow(
                variant: LumiVariant.consent,
                lumiSize: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Datos del Paciente').textLarge().bold(),
                    const Gap(4),
                    Text(
                      'Completa los datos antes de iniciar la evaluación',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
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
              DateTextField(
                key: ValueKey(_controller.dateOfBirth),
                initialValue: _controller.dateOfBirth,
                stateBuilder: (date) =>
                    date.isAfter(DateTime.now()) ? DateState.disabled : DateState.enabled,
                onChanged: _controller.onDateOfBirthChanged,
              ),
              const Gap(16),

              const Text('Sexo').medium(),
              const Gap(8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  GenderOption(
                    label: 'Masculino',
                    code: 'M',
                    isSelected: _controller.gender == 'M',
                    icon: material.Icons.male,
                    onTap: () => _controller.onGenderChanged('M'),
                  ),
                  GenderOption(
                    label: 'Femenino',
                    code: 'F',
                    isSelected: _controller.gender == 'F',
                    icon: material.Icons.female,
                    onTap: () => _controller.onGenderChanged('F'),
                  ),
                  GenderOption(
                    label: 'Otro',
                    code: 'O',
                    isSelected: _controller.gender == 'O',
                    icon: material.Icons.transgender,
                    onTap: () => _controller.onGenderChanged('O'),
                  ),
                  GenderOption(
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

            if (widget.showConsentSection && !widget.collapseConsent)
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

class _CollapsibleConsentCard extends StatelessWidget {
  final String consentText;
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<String> checkboxLabels;

  const _CollapsibleConsentCard({
    required this.consentText,
    required this.isExpanded,
    required this.onToggle,
    required this.checkboxLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(material.Icons.fact_check_outlined,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const Gap(8),
                Expanded(child: Text('Consentimiento Informado').semiBold()),
                GestureDetector(
                  onTap: onToggle,
                  child: Text(
                    isExpanded ? 'ver menos' : 'ver más',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const Gap(12),
              Text(consentText, style: const TextStyle(height: 1.6)).small().muted(),
              if (checkboxLabels.isNotEmpty) ...[
                const Gap(12),
                for (final label in checkboxLabels) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        state: CheckboxState.checked,
                        onChanged: null,
                      ),
                      const Gap(8),
                      Expanded(child: Text(label).small().muted()),
                    ],
                  ),
                  const Gap(6),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
