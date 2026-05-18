import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

class SurveySingleChoiceField extends StatelessWidget {
  final String label;
  final String? helperText;
  final int? value;
  final List<SurveyChoice> options;
  final ValueChanged<int> onChanged;

  const SurveySingleChoiceField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).medium(),
        if (helperText != null) ...[
          const Gap(4),
          Text(helperText!).muted(),
        ],
        const Gap(8),
        RadioGroup<int>(
          value: value,
          onChanged: onChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options
                .map(
                  (option) => RadioItem<int>(
                    value: option.value,
                    trailing: Text(option.label),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

