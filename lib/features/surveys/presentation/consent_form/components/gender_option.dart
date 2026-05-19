import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

class GenderOption extends StatelessWidget {
  final String label;
  final String code;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const GenderOption({
    super.key,
    required this.label,
    required this.code,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OutlinedContainer(
        backgroundColor: isSelected ? LightModeColors.lightPrimary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        borderColor: isSelected
            ? LightModeColors.lightPrimary
            : LightModeColors.lightOutline.withValues(alpha: 0.5),
        borderWidth: isSelected ? 2 : 1.5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: isSelected ? LightModeColors.lightPrimary : LightModeColors.lightOnSurface),
          const Gap(8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              color: isSelected ? LightModeColors.lightPrimary : LightModeColors.lightOnSurface,
            ),
          ),
          if (isSelected) ...[
            const Gap(8),
            Icon(material.Icons.check_circle, size: 18, color: LightModeColors.lightPrimary),
          ],
        ]),
      ),
    );
  }
}
