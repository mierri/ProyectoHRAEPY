import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/shared/providers/font_size_provider.dart';

class FontSizeButton extends StatelessWidget {
  const FontSizeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FontSizeProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SizeBtn(
          label: 'A−',
          enabled: provider.canDecrease,
          onTap: provider.decrease,
        ),
        _SizeBtn(
          label: 'A+',
          enabled: provider.canIncrease,
          onTap: provider.increase,
        ),
      ],
    );
  }
}

class _SizeBtn extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SizeBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF6B7280)
                  : const Color(0xFFD1D5DB),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: enabled
                  ? const Color(0xFF374151)
                  : const Color(0xFFD1D5DB),
            ),
          ),
        ),
      ),
    );
  }
}
