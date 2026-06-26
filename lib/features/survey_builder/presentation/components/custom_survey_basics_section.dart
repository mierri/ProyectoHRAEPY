import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/presentation/components/custom_survey_editor_colors.dart';

class CustomSurveyBasicsSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String colorHex;
  final bool isActive;
  final VoidCallback onPickColor;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDescriptionChanged;

  const CustomSurveyBasicsSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.colorHex,
    required this.isActive,
    required this.onPickColor,
    required this.onColorSelected,
    required this.onActiveChanged,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = parseCustomSurveyColor(colorHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Titulo de la encuesta').semiBold(),
        const Gap(8),
        TextField(
          controller: titleController,
          placeholder: const Text('Ej. Escala de bienestar emocional'),
          onChanged: onTitleChanged,
        ),
        const Gap(16),
        Text('Descripcion').semiBold(),
        const Gap(8),
        TextField(
          controller: descriptionController,
          placeholder: const Text('Explica para que sirve o cuando debe aplicarse'),
          onChanged: onDescriptionChanged,
        ),
        const Gap(18),
        OutlinedContainer(
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apariencia y estado').semiBold(),
              const Gap(12),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).colorScheme.foreground,
                        width: 2,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(child: Text(colorHex).muted()),
                  OutlineButton(
                    onPressed: onPickColor,
                    child: const Text('Elegir color'),
                  ),
                ],
              ),
              const Gap(12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: customSurveyColorPresets.map((hex) {
                  final color = parseCustomSurveyColor(hex);
                  final selected = hex == colorHex;
                  return GestureDetector(
                    onTap: () => onColorSelected(hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.foreground
                              : color.withValues(alpha: 0.28),
                          width: selected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Gap(18),
              Row(
                children: [
                  Expanded(child: Text('Encuesta activa').semiBold()),
                  Switch(
                    value: isActive,
                    onChanged: onActiveChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
