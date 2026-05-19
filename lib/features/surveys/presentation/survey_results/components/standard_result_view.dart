import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/patient_info_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/recommendations_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/response_details_card.dart';
import 'package:ssapp/features/surveys/presentation/survey_results/components/score_interpretation_card.dart';

/// Standard results layout: gradient score card, interpretation, recommendations, details.
class StandardResultView extends StatelessWidget {
  final String patientName;
  final DateTime createdAt;
  final int score;
  final String level;
  final Color color;
  final IconData levelIcon;
  final int surveyType;
  final String surveyFullName;
  final String recommendation;
  final List? responses;
  final VoidCallback onBack;
  final VoidCallback onHome;

  const StandardResultView({
    super.key,
    required this.patientName,
    required this.createdAt,
    required this.score,
    required this.level,
    required this.color,
    required this.levelIcon,
    required this.surveyType,
    required this.surveyFullName,
    required this.recommendation,
    required this.onBack,
    required this.onHome,
    this.responses,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PatientInfoCard(patientName: patientName, createdAt: createdAt),
        const Gap(24),
        _MainScoreCard(score: score, level: level, color: color, levelIcon: levelIcon, surveyFullName: surveyFullName),
        const Gap(32),
        ScoreInterpretationCard(surveyType: surveyType),
        const Gap(24),
        RecommendationsCard(level: level, recommendation: recommendation),
        const Gap(24),
        if (responses != null && responses!.isNotEmpty) ...[
          ResponseDetailsCard(responses: responses!, surveyType: surveyType),
          const Gap(24),
        ],
        Row(children: [
          Expanded(child: OutlineButton(
            onPressed: onBack,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(material.Icons.arrow_back, size: 20), Gap(8), Text('Volver'),
            ]),
          )),
          const Gap(12),
          Expanded(child: PrimaryButton(
            onPressed: onHome,
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(material.Icons.home, size: 20), Gap(8), Text('Inicio'),
            ]),
          )),
        ]),
      ]),
    );
  }
}

class _MainScoreCard extends StatelessWidget {
  final int score;
  final String level;
  final Color color;
  final IconData levelIcon;
  final String surveyFullName;

  const _MainScoreCard({
    required this.score, required this.level, required this.color,
    required this.levelIcon, required this.surveyFullName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        Icon(levelIcon, size: 80, color: Colors.white),
        const Gap(16),
        const Text('Puntaje Total', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500)),
        const Gap(8),
        Text('$score', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
        const Gap(16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(24)),
          child: Text(level, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white), textAlign: TextAlign.center),
        ),
        const Gap(12),
        Text(surveyFullName, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
      ]),
    );
  }
}
