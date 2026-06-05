import 'package:flutter/material.dart' as material show Icons;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';
import 'package:ssapp/shared/widgets/date_text_field.dart';

void showAddPatientDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => const _AddPatientDialogContent(),
  );
}

class _AddPatientDialogContent extends StatefulWidget {
  const _AddPatientDialogContent();

  @override
  State<_AddPatientDialogContent> createState() => _AddPatientDialogContentState();
}

class _AddPatientDialogContentState extends State<_AddPatientDialogContent> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String _gender = 'M';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showError(String title, String subtitle) {
    showCenteredToast(
      context,
      title: title,
      subtitle: subtitle,
      icon: material.Icons.warning,
      iconColor: LightModeColors.lightError,
      location: ToastLocation.topCenter,
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Campo requerido', 'Por favor ingrese el nombre del paciente');
      return;
    }
    if (_birthDate == null) {
      _showError('Campo requerido', 'Por favor seleccione la fecha de nacimiento');
      return;
    }

    final patientService = context.read<PatientService>();
    final patient = await patientService.createPatient(
      name: _nameController.text.trim(),
      gender: _gender,
      birthDate: _birthDate!,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    showCenteredToast(
      context,
      title: patient != null ? 'Paciente creado' : 'Error',
      subtitle: patient != null
          ? '${patient.name} agregado exitosamente'
          : 'No se pudo crear el paciente',
      icon: patient != null ? material.Icons.check_circle : material.Icons.error,
      iconColor: patient != null ? LightModeColors.lightTertiary : LightModeColors.lightError,
      location: ToastLocation.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Paciente'),
      content: SizedBox(
        width: 400,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nombre completo').semiBold(),
          const Gap(8),
          TextField(
            controller: _nameController,
            placeholder: const Text('Ingrese el nombre del paciente'),
          ),
          const Gap(16),
          const Text('Sexo').semiBold(),
          const Gap(8),
          _GenderSelector(
            selected: _gender,
            onChanged: (v) => setState(() => _gender = v),
          ),
          const Gap(16),
          const Text('Fecha de nacimiento').semiBold(),
          const Gap(8),
          DateTextField(
            key: ValueKey(_birthDate),
            initialValue: _birthDate,
            stateBuilder: (date) =>
                date.isAfter(DateTime.now()) ? DateState.disabled : DateState.enabled,
            onChanged: (date) => setState(() => _birthDate = date),
          ),
        ]),
      ),
      actions: [
        OutlineButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        PrimaryButton(
          onPressed: _submit,
          child: const Text('Crear Paciente'),
        ),
      ],
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  static const _options = [
    (value: 'M', label: 'Masculino', icon: material.Icons.male),
    (value: 'F', label: 'Femenino', icon: material.Icons.female),
    (value: 'O', label: 'Otro', icon: material.Icons.transgender),
  ];

  const _GenderSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.asMap().entries.map((entry) {
        final opt = entry.value;
        final isSelected = opt.value == selected;
        final btn = isSelected
            ? PrimaryButton(
                onPressed: () => onChanged(opt.value),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(opt.icon, size: 18),
                  const Gap(8),
                  Text(opt.label),
                ]),
              )
            : OutlineButton(
                onPressed: () => onChanged(opt.value),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(opt.icon, size: 18),
                  const Gap(8),
                  Text(opt.label),
                ]),
              );
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: entry.key < _options.length - 1 ? 8 : 0),
            child: btn,
          ),
        );
      }).toList(),
    );
  }
}
