import 'package:flutter/material.dart' as material show Icons;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/providers/font_size_provider.dart';
import 'package:ssapp/shared/utils/theme.dart';

class MultiSelectOptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Color surveyColor;
  final VoidCallback onTap;

  const MultiSelectOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.surveyColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OutlinedContainer(
        backgroundColor: isSelected ? surveyColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        borderColor: isSelected ? surveyColor : LightModeColors.lightOutline.withValues(alpha: 0.5),
        borderWidth: isSelected ? 2.5 : 1.5,
        child: Row(children: [
          Icon(
            isSelected ? material.Icons.check_box : material.Icons.check_box_outline_blank,
            color: isSelected ? surveyColor : LightModeColors.lightOnSurfaceVariant,
            size: 24,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: context.watch<FontSizeProvider>().scaled(15),
                height: 1.45,
                color: isSelected ? surveyColor.withValues(alpha: 0.95) : LightModeColors.lightOnSurface,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
