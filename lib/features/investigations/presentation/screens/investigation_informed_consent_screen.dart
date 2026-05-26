import 'package:flutter/material.dart' as material show Icons, Colors, Navigator;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

const _kVoluntaryLabel =
    'Mi participación es voluntaria. He sido informado que puedo negarme a participar o '
    'terminar mi participación en cualquier momento del estudio sin que sufra penalidad '
    'alguna o pérdida de beneficios.';

const _kReadLabel =
    'He leído y entendido toda la información que me han dado sobre mi participación en '
    'el estudio. He tenido la oportunidad para discutirlo y hacer preguntas. Todas las '
    'preguntas han sido respondidas a mi satisfacción.';

class InvestigationInformedConsentScreen extends StatefulWidget {
  final String consentText;
  final List<String> customCheckboxLabels;

  const InvestigationInformedConsentScreen({
    super.key,
    required this.consentText,
    this.customCheckboxLabels = const [],
  });

  @override
  State<InvestigationInformedConsentScreen> createState() =>
      _InvestigationInformedConsentScreenState();
}

class _InvestigationInformedConsentScreenState
    extends State<InvestigationInformedConsentScreen> {
  bool _voluntaryChecked = false;
  bool _readChecked = false;
  late List<bool> _customChecked;

  final _emailController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _customChecked = List.filled(widget.customCheckboxLabels.length, false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  bool get _allChecked =>
      _voluntaryChecked &&
      _readChecked &&
      _customChecked.every((c) => c);

  bool get _canContinue =>
      _allChecked &&
      _emailController.text.trim().isNotEmpty &&
      _phone1Controller.text.trim().isNotEmpty;

  void _onContinue() {
    if (!_canContinue) return;
    material.Navigator.of(context).pop({
      'email': _emailController.text.trim(),
      'phone1': _phone1Controller.text.trim(),
      'phone2': _phone2Controller.text.trim(),
    });
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto largo del investigador
            if (widget.consentText.trim().isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(material.Icons.description_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary),
                          const Gap(8),
                          Expanded(
                            child: Text('Información del estudio').semiBold(),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Text(widget.consentText, style: const TextStyle(height: 1.6)).small().muted(),
                    ],
                  ),
                ),
              ),
              const Gap(20),
            ],

            // Checkboxes obligatorios fijos
            const Text('Declaración de consentimiento').semiBold(),
            const Gap(12),
            _ConsentCheckboxRow(
              label: _kVoluntaryLabel,
              checked: _voluntaryChecked,
              onChanged: (v) => setState(() => _voluntaryChecked = v),
            ),
            const Gap(10),
            _ConsentCheckboxRow(
              label: _kReadLabel,
              checked: _readChecked,
              onChanged: (v) => setState(() => _readChecked = v),
            ),

            // Checkboxes personalizados del investigador
            for (int i = 0; i < widget.customCheckboxLabels.length; i++) ...[
              const Gap(10),
              _ConsentCheckboxRow(
                label: widget.customCheckboxLabels[i],
                checked: _customChecked[i],
                onChanged: (v) => setState(() => _customChecked[i] = v),
              ),
            ],

            const Gap(28),

            // Datos de contacto
            const Text('Datos de contacto').semiBold(),
            const Gap(4),
            const Text('Esta información se usará únicamente para fines del estudio.')
                .small()
                .muted(),
            const Gap(12),

            const Text('Correo electrónico *').medium(),
            const Gap(5),
            TextField(
              controller: _emailController,
              placeholder: const Text('ejemplo@correo.com'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
            ),
            const Gap(12),

            const Text('Teléfono *').medium(),
            const Gap(5),
            TextField(
              controller: _phone1Controller,
              placeholder: const Text('Número de teléfono'),
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
            ),
            const Gap(12),

            const Text('Teléfono alternativo (opcional)').medium(),
            const Gap(5),
            TextField(
              controller: _phone2Controller,
              placeholder: const Text('Número de teléfono alternativo'),
              keyboardType: TextInputType.phone,
            ),

            const Gap(32),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _canContinue ? _onContinue : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _canContinue
                        ? LightModeColors.lightPrimary
                        : LightModeColors.lightPrimary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      color: material.Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            if (!_allChecked) ...[
              const Gap(8),
              const Text(
                'Debes marcar todos los checkboxes para continuar.',
              ).small().muted(),
            ] else if (_emailController.text.trim().isEmpty ||
                _phone1Controller.text.trim().isEmpty) ...[
              const Gap(8),
              const Text(
                'El correo y el teléfono son obligatorios.',
              ).small().muted(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConsentCheckboxRow extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _ConsentCheckboxRow({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            state: checked ? CheckboxState.checked : CheckboxState.unchecked,
            onChanged: (state) => onChanged(state == CheckboxState.checked),
          ),
          const Gap(10),
          Expanded(
            child: Text(label).small(),
          ),
        ],
      ),
    );
  }
}
