import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/shared/form/survey_choice.dart';

class SurveyMultiChoiceField extends StatelessWidget {
  final String label;
  final String? helperText;
  final Set<int> selectedValues;
  final List<SurveyChoice> options;
  final ValueChanged<Set<int>> onChanged;
  final int? exclusiveValue;

  const SurveyMultiChoiceField({
    super.key,
    required this.label,
    required this.selectedValues,
    required this.options,
    required this.onChanged,
    this.helperText,
    this.exclusiveValue,
  });

  void _toggleValue(int value, bool selected) {
    final next = Set<int>.from(selectedValues);

    if (selected) {
      if (exclusiveValue != null && value == exclusiveValue) {
        next
          ..clear()
          ..add(value);
      } else {
        next.add(value);
        if (exclusiveValue != null) {
          next.remove(exclusiveValue);
        }
      }
    } else {
      next.remove(value);
    }

    onChanged(next);
  }

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
        ...options.map(
          (option) => Checkbox(
            state: selectedValues.contains(option.value)
                ? CheckboxState.checked
                : CheckboxState.unchecked,
            trailing: Text(option.label),
            onChanged: (state) {
              _toggleValue(option.value, state == CheckboxState.checked);
            },
          ),
        ),
      ],
    );
  }
}

