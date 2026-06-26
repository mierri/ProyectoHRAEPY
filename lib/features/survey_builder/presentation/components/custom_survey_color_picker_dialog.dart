import 'package:flutter/material.dart' as material
    show HSVColor, Slider, SliderTheme, RoundSliderThumbShape;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_colors.dart';

class CustomSurveyColorPickerDialog extends StatefulWidget {
  final String initialHex;

  const CustomSurveyColorPickerDialog({super.key, required this.initialHex});

  @override
  State<CustomSurveyColorPickerDialog> createState() =>
      _CustomSurveyColorPickerDialogState();
}

class _CustomSurveyColorPickerDialogState
    extends State<CustomSurveyColorPickerDialog> {
  late Color _color;
  late material.HSVColor _hsv;
  late TextEditingController _hexController;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _color = parseCustomSurveyColor(widget.initialHex);
    _hsv = material.HSVColor.fromColor(_color);
    _hexController = TextEditingController(text: customSurveyColorToHex(_color));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _updateFromColor(Color color) {
    setState(() {
      _color = color;
      _hsv = material.HSVColor.fromColor(color);
      _hexController.text = customSurveyColorToHex(color);
      _hexError = null;
    });
  }

  void _updateFromHsv(material.HSVColor hsv) {
    _updateFromColor(hsv.toColor());
  }

  void _applyHex() {
    final normalized = normalizeCustomSurveyHexInput(_hexController.text);
    if (normalized == null) {
      setState(() => _hexError = 'Usa un color hex como #0D9488');
      return;
    }
    _updateFromColor(parseCustomSurveyColor(normalized));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Elegir color').textLarge().semiBold(),
              const Gap(8),
              const Text(
                'Ajusta el color con los controles o escribe un codigo hex.',
              ).muted(),
              const Gap(20),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.foreground,
                        width: 2,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customSurveyColorToHex(_color)).semiBold(),
                        const Gap(6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: customSurveyColorPresets.map((hex) {
                            final preset = parseCustomSurveyColor(hex);
                            final selected =
                                customSurveyColorToHex(preset) ==
                                customSurveyColorToHex(_color);
                            return GestureDetector(
                              onTap: () => _updateFromColor(preset),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: preset,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.foreground
                                        : preset.withValues(alpha: 0.25),
                                    width: selected ? 3 : 1,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),
              _ColorSliderRow(
                label: 'Tono',
                value: _hsv.hue,
                max: 360,
                onChanged: (value) => _updateFromHsv(_hsv.withHue(value)),
                activeColor: _color,
              ),
              const Gap(12),
              _ColorSliderRow(
                label: 'Saturacion',
                value: _hsv.saturation,
                max: 1,
                onChanged: (value) => _updateFromHsv(_hsv.withSaturation(value)),
                activeColor: _color,
                percent: true,
              ),
              const Gap(12),
              _ColorSliderRow(
                label: 'Brillo',
                value: _hsv.value,
                max: 1,
                onChanged: (value) => _updateFromHsv(_hsv.withValue(value)),
                activeColor: _color,
                percent: true,
              ),
              const Gap(16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      placeholder: const Text('#0D9488'),
                    ),
                  ),
                  const Gap(10),
                  OutlineButton(
                    onPressed: _applyHex,
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
              if (_hexError != null) ...[
                const Gap(8),
                Text(
                  _hexError!,
                  style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                ),
              ],
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: PrimaryButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pop(customSurveyColorToHex(_color)),
                      child: const Text('Usar color'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final Color activeColor;
  final bool percent;

  const _ColorSliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.activeColor,
    this.percent = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = percent
        ? '${(value * 100).round()}%'
        : value.round().toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label).semiBold()),
            Text(displayValue).muted().small(),
          ],
        ),
        material.SliderTheme(
          data: material.SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: 0.15),
            thumbShape: const material.RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: material.Slider(
            value: value.clamp(0, max),
            min: 0,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
