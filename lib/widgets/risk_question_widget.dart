import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Enum to define the semantic meaning of a question
enum QuestionSemantics {
  /// Risk-based question: YES is bad (showing risk), NO is good
  riskBased,

  /// Health-based question: YES is good (healthy), NO is bad (unhealthy)
  healthBased,

  /// Functional question: YES is good (independent), NO is bad (dependent)
  functionalBased,
}

/// Returns the appropriate icon for an answer based on question semantics
IconData getIconForAnswer({
  required bool answer,
  required QuestionSemantics semantics,
}) {
  switch (semantics) {
    case QuestionSemantics.riskBased:
      // YES = risk present (bad) = sad
      // NO = no risk (good) = happy
      return answer ? Symbols.sentiment_very_dissatisfied : Symbols.sentiment_very_satisfied;

    case QuestionSemantics.healthBased:
      // YES = good health (good) = happy
      // NO = bad health (bad) = sad
      return answer ? Symbols.sentiment_very_satisfied : Symbols.sentiment_very_dissatisfied;

    case QuestionSemantics.functionalBased:
      // YES = independent (good) = happy
      // NO = dependent (bad) = sad
      return answer ? Symbols.sentiment_very_satisfied : Symbols.sentiment_very_dissatisfied;
  }
}

/// Returns the fixed color for an answer (color does NOT change on selection)
Color getColorForAnswer({
  required bool answer,
  required QuestionSemantics semantics,
}) {
  switch (semantics) {
    case QuestionSemantics.riskBased:
      // YES = risk (red), NO = safe (green)
      return answer ? const Color(0xFFDC2626) : const Color(0xFF16A34A);

    case QuestionSemantics.healthBased:
      // YES = healthy (green), NO = unhealthy (red)
      return answer ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    case QuestionSemantics.functionalBased:
      // YES = independent (green), NO = dependent (amber)
      return answer ? const Color(0xFF16A34A) : const Color(0xFFFFA726);
  }
}

/// A reusable widget for YES/NO risk-based questionnaire questions
/// 
/// Displays a question with two interactive buttons (Yes/No) that:
/// - Show semantic icons based on the question meaning
/// - Have FIXED colors (don't change on selection)
/// - Are fully accessible
class RiskQuestionWidget extends StatefulWidget {
  /// The question text to display
  final String question;

  /// The semantic meaning of this question (risk-based, health-based, etc.)
  final QuestionSemantics semantics;

  /// Currently selected answer (true = Yes, false = No, null = not answered)
  final bool? selectedAnswer;

  /// Callback when answer is selected
  final ValueChanged<bool> onAnswerSelected;

  /// Optional: Custom size for icons
  final double iconSize;

  /// Optional: Custom border radius for buttons
  final double borderRadius;

  /// Optional: Semantic label for "Yes" button (accessibility)
  final String? yesSemanticLabel;

  /// Optional: Semantic label for "No" button (accessibility)
  final String? noSemanticLabel;

  const RiskQuestionWidget({
    super.key,
    required this.question,
    required this.semantics,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    this.iconSize = 32,
    this.borderRadius = 12,
    this.yesSemanticLabel,
    this.noSemanticLabel,
  });

  @override
  State<RiskQuestionWidget> createState() => _RiskQuestionWidgetState();
}

class _RiskQuestionWidgetState extends State<RiskQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            widget.question,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Answer buttons row
        Row(
          children: [
            // "Yes" button
            Expanded(
              child: _AnswerButton(
                answer: true,
                label: 'Sí',
                semanticLabel: widget.yesSemanticLabel ?? 'Respuesta: Sí',
                icon: getIconForAnswer(
                  answer: true,
                  semantics: widget.semantics,
                ),
                // Fixed color (always the same)
                color: getColorForAnswer(
                  answer: true,
                  semantics: widget.semantics,
                ),
                isSelected: widget.selectedAnswer == true,
                iconSize: widget.iconSize,
                borderRadius: widget.borderRadius,
                onTap: () => widget.onAnswerSelected(true),
              ),
            ),

            const SizedBox(width: 12),

            // "No" button
            Expanded(
              child: _AnswerButton(
                answer: false,
                label: 'No',
                semanticLabel: widget.noSemanticLabel ?? 'Respuesta: No',
                icon: getIconForAnswer(
                  answer: false,
                  semantics: widget.semantics,
                ),
                // Fixed color (always the same)
                color: getColorForAnswer(
                  answer: false,
                  semantics: widget.semantics,
                ),
                isSelected: widget.selectedAnswer == false,
                iconSize: widget.iconSize,
                borderRadius: widget.borderRadius,
                onTap: () => widget.onAnswerSelected(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual answer button widget
class _AnswerButton extends StatefulWidget {
  final bool answer;
  final String label;
  final String semanticLabel;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final double iconSize;
  final double borderRadius;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.answer,
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.iconSize,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: true,
      label: widget.semanticLabel,
      selected: widget.isSelected,
      onTap: widget.onTap,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withOpacity(0.15)
                : colorScheme.surface,
            border: Border.all(
              color: widget.color,
              width: widget.isSelected ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    if (_isPressed)
                      BoxShadow(
                        color: widget.color.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Icon(
                      widget.icon,
                      size: widget.iconSize,
                      color: widget.color,
                    ),
                    const SizedBox(height: 8),
                    // Label
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: widget.color,
                            fontWeight: widget.isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




