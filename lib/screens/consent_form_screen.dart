import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ssapp/models/patient_model.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:provider/provider.dart';

class ConsentFormScreen extends StatefulWidget {
  final String? surveyType;

  const ConsentFormScreen({super.key, this.surveyType});

  @override
  State<ConsentFormScreen> createState() => _ConsentFormScreenState();
}

class _ConsentFormScreenState extends State<ConsentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maritalStatusController = TextEditingController();
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();

  DateTime? _dateOfBirth;
  Gender _gender = Gender.male;
  bool _consentGiven = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _maritalStatusController.dispose();
    _occupationController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona la fecha de nacimiento')),
      );
      return;
    }
    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe aceptar el consentimiento informado')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final patientService = context.read<PatientService>();
    final patient = await patientService.createPatient(
      name: _nameController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      gender: _gender,
    );

    if (!mounted) return;

    context.push('/survey/${patient.id}?surveyType=${widget.surveyType ?? "bdi"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consentimiento Informado'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConsentInfoCard(surveyType: widget.surveyType),
                SizedBox(height: AppSpacing.xl),
                Text('Datos del Paciente', style: context.textStyles.titleLarge),
                SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      _dateOfBirth == null
                          ? 'Seleccionar fecha'
                          : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
                      style: context.textStyles.bodyMedium,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<Gender>(
                  initialValue: _gender,
                  decoration: InputDecoration(
                    labelText: 'Sexo',
                    prefixIcon: Icon(Icons.wc, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: Gender.male, child: Text('Masculino')),
                    DropdownMenuItem(value: Gender.female, child: Text('Femenino')),
                    DropdownMenuItem(value: Gender.other, child: Text('Otro')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _gender = value);
                  },
                ),
                SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  value: _consentGiven,
                  onChanged: (value) => setState(() => _consentGiven = value ?? false),
                  title: Text(
                    'Acepto participar voluntariamente en esta evaluación y consiento el uso de mis datos para fines de investigación.',
                    style: context.textStyles.bodyMedium,
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            'Continuar con la encuesta',
                            style: context.textStyles.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Información Importante',
                style: context.textStyles.titleMedium?.semiBold.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            _getSurveyDescription(),
            style: context.textStyles.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '• Su participación es completamente voluntaria\n• Toda la información será tratada con confidencialidad\n• Los resultados serán utilizados para mejorar la atención psicológica',
            style: context.textStyles.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

