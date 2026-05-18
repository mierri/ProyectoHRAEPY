import 'package:shadcn_flutter/shadcn_flutter.dart';

class SurveyScaleField extends StatelessWidget {
  final String label;
  final String? helperText;
  final int? value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const SurveyScaleField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.min = 1,
    this.max = 5,
  });

  @override
  Widget build(BuildContext context) {
    final options = List<int>.generate(max - min + 1, (index) => min + index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).medium(),
        if (helperText != null) ...[
          const Gap(4),
          Text(helperText!).muted(),
        ],
        const Gap(8),
        Wrap(
          spacing: 8,
          children: options
              .map(
                (option) => Toggle(
                  value: value == option,
                  onChanged: (_) => onChanged(option),
                  child: Text('$option'),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

