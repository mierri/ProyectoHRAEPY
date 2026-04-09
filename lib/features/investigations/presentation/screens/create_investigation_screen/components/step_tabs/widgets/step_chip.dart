import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class StepChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const StepChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final background = selected
        ? colorScheme.primary
        : completed
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.muted;

    final foreground = selected
        ? colorScheme.primaryForeground
        : completed
            ? colorScheme.primary
            : colorScheme.mutedForeground;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(completed ? material.Icons.check : icon, size: 14, color: foreground),
            const Gap(6),
            Text(label, style: TextStyle(color: foreground, fontSize: 12)).semiBold(),
          ],
        ),
      ),
    );
  }
}


