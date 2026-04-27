import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen.dart';

class Phq9Screen extends StatelessWidget {
  final int patientId;

  const Phq9Screen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return SurveyScreen(patientId: patientId, surveyType: 'phq9');
  }
}

