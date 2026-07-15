import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/presentation/survey_screen/survey_screen.dart';

class FantasticMexaScreen extends StatelessWidget {
  final int patientId;

  const FantasticMexaScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return SurveyScreen(patientId: patientId, surveyType: 'fantastic_mexa');
  }
}
