import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SurveyTextField extends StatelessWidget {
  final String label;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;

  const SurveyTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.helperText,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
