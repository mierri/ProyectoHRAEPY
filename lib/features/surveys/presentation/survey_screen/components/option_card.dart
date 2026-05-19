import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/shared/utils/theme.dart';

class SurveyOptionCard extends StatefulWidget {
  final SurveyOption option;
  final bool isSelected;
  final IconData faceIcon;
  final Color faceColor;
  final Color surveyColor;
  final VoidCallback onTap;

  const SurveyOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.faceIcon,
    required this.faceColor,
    required this.surveyColor,
    required this.onTap,
  });

  @override
  State<SurveyOptionCard> createState() => _SurveyOptionCardState();
}

class _SurveyOptionCardState extends State<SurveyOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: OutlinedContainer(
          backgroundColor: widget.isSelected ? widget.surveyColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          borderColor: widget.isSelected
              ? widget.surveyColor
              : LightModeColors.lightOutline.withValues(alpha: 0.5),
          borderWidth: widget.isSelected ? 2.5 : 1.5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.faceColor.withValues(alpha: 0.15)
                      : widget.faceColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected ? widget.faceColor : widget.faceColor.withValues(alpha: 0.4),
                    width: widget.isSelected ? 2 : 1.5,
                  ),
                ),
                child: Center(child: Icon(widget.faceIcon, color: widget.faceColor, size: 26, fill: widget.isSelected ? 1 : 0)),
              ),
              const Gap(12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    widget.option.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: widget.isSelected ? widget.surveyColor.withValues(alpha: 0.9) : LightModeColors.lightOnSurface,
                    ),
                  ),
                ),
              ),
              if (widget.isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 6),
                  child: Icon(material.Icons.check_circle, color: widget.surveyColor, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
