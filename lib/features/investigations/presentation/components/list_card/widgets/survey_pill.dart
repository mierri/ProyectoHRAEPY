import 'package:shadcn_flutter/shadcn_flutter.dart';

class SurveyPill extends StatelessWidget {
  final String name;
  final Color accentColor;

  const SurveyPill({
    super.key,
    required this.name,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: accentColor,
        ),
      ),
    );
  }
}

