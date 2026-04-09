import 'package:shadcn_flutter/shadcn_flutter.dart';

class TabChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TabChip({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return selected
        ? PrimaryButton(
            size: ButtonSize.small,
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14),
                const Gap(6),
                Text(label).small(),
              ],
            ),
          )
        : OutlineButton(
            size: ButtonSize.small,
            onPressed: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14),
                const Gap(6),
                Text(label).small(),
              ],
            ),
          );
  }
}

