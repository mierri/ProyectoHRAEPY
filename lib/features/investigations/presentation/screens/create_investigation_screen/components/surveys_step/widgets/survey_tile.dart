import 'package:shadcn_flutter/shadcn_flutter.dart';

class SurveyTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const SurveyTile({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OutlinedContainer(
        borderRadius: BorderRadius.circular(12),
        borderColor: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.border,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Checkbox(
              state: selected ? CheckboxState.checked : CheckboxState.unchecked,
              onChanged: (_) => onTap(),
            ),
            const Gap(10),
            Expanded(
              child: Text(name).semiBold(),
            ),
          ],
        ),
      ),
    );
  }
}

