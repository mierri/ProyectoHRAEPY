import 'package:flutter/material.dart' as material show Navigator, Icons;
import 'package:go_router/go_router.dart';
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
      case 'moca':
        return LightModeColors.lightSecondary;
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
        context.push('/survey/${patient.patientId}?surveyType=${widget.surveyType ?? "bdi"}');
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
      case 'moca':
        return 'Esta evaluación cognitiva evalúa diferentes dominios cognitivos mediante la Evaluación Cognitiva Montreal (MoCA). Evalúa atención, concentración, funciones ejecutivas, memoria, lenguaje, habilidades visuoconstructivas, pensamiento conceptual, cálculo y orientación. Los datos recopilados serán utilizados exclusivamente para propósitos clínicos y de investigación del Departamento de Psicología del HRAEPY.';
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

