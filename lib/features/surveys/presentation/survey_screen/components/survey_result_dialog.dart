import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

/// Dialog content showing the survey score and interpretation.
class SurveyResultDialogContent extends StatelessWidget {
  final int totalScore;
  final String interpretation;
  final String severityLevel;
  final Color levelColor;
  final String surveyType;
  final dynamic riskResult;
  final double? weight;
  final double? height;
  final VoidCallback onDismiss;

  const SurveyResultDialogContent({
    super.key,
    required this.totalScore,
    required this.interpretation,
    required this.severityLevel,
    required this.levelColor,
    required this.surveyType,
    required this.onDismiss,
    this.riskResult,
    this.weight,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(material.Icons.analytics, color: LightModeColors.lightPrimary, size: 32),
                const Gap(12),
                const Expanded(child: Text('Resultado de la Encuesta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
              ]),
              const Gap(24),
              _ScoreCard(score: totalScore, level: severityLevel, color: levelColor),
              if (surveyType == 'osteoporosis' && riskResult != null && (weight != null || height != null)) ...[
                const Gap(20),
                _AnthropometricCard(riskResult: riskResult, weight: weight, height: height, color: levelColor),
              ],
              const Gap(20),
              _InterpretationBox(text: interpretation),
              const Gap(16),
              Text(
                'Nota: Este resultado es orientativo. Para un diagnóstico profesional, consulte con un especialista en salud mental.',
                style: TextStyle(fontSize: 11, color: LightModeColors.lightOnSurfaceVariant, fontStyle: FontStyle.italic),
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(onPressed: onDismiss, child: const Text('OK')),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final String level;
  final Color color;
  const _ScoreCard({required this.score, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(children: [
          Text('Puntuación Total', style: TextStyle(fontSize: 13, color: LightModeColors.lightOnSurfaceVariant)),
          const Gap(8),
          Text('$score', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color)),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text(level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}

class _AnthropometricCard extends StatelessWidget {
  final dynamic riskResult;
  final double? weight;
  final double? height;
  final Color color;
  const _AnthropometricCard({required this.riskResult, required this.weight, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Datos Antropométricos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        const Gap(12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _DataPoint(label: 'Peso',       value: weight != null ? '${weight!.toStringAsFixed(2)} kg' : 'N/A', color: color),
          _DataPoint(label: 'Altura',     value: height != null ? '${height!.toStringAsFixed(2)} m'  : 'N/A', color: color),
          _DataPoint(label: 'IMC',        value: riskResult.bmi.toStringAsFixed(2),  color: color),
          _DataPoint(label: 'Grupo Edad', value: riskResult.ageGroup.toString(),      color: color),
        ]),
      ]),
    );
  }
}

class _DataPoint extends StatelessWidget {
  final String label, value;
  final Color color;
  const _DataPoint({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: TextStyle(fontSize: 12, color: LightModeColors.lightOnSurfaceVariant)),
      const Gap(6),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ]);
  }
}

class _InterpretationBox extends StatelessWidget {
  final String text;
  const _InterpretationBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: LightModeColors.lightSurfaceVariant, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(material.Icons.info_outline, size: 20, color: LightModeColors.lightPrimary),
          const Gap(8),
          const Text('Interpretación', style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        const Gap(8),
        Text(text, style: const TextStyle(height: 1.5)),
      ]),
    );
  }
}
