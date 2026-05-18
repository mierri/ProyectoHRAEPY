import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_screen.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_questions.dart';
import 'package:ssapp/features/surveys/types/social_determinants/presentation/social_determinants_controller.dart';

const _kColor = Color(0xFF7C3AED);

class SocialDeterminantsScreen extends StatefulWidget {
  final int patientId;

  const SocialDeterminantsScreen({super.key, required this.patientId});

  @override
  State<SocialDeterminantsScreen> createState() => _SocialDeterminantsScreenState();
}

class _SocialDeterminantsScreenState extends State<SocialDeterminantsScreen> {
  late SocialDeterminantsController _controller;
  bool _initialized = false;

  int? _fromInvestigationId() {
    final params = GoRouterState.of(context).uri.queryParameters;
    final raw = params['fromInvestigation'] ??
        params['from_investigation'] ??
        params['fromInvestigationId'] ??
        params['from_investigation_id'];
    return int.tryParse(raw ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _controller = SocialDeterminantsController(
        patientId: widget.patientId,
        surveyService: context.read<SurveyService>(),
        investigationId: _fromInvestigationId(),
      );
      _controller.addListener(_rebuild);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.removeListener(_rebuild);
      _controller.dispose();
    }
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FormSurveyScreen(
      questions: socialDeterminantsQuestions,
      controller: _controller,
      color: _kColor,
      onComplete: (ctx, investigationId) {
        if (investigationId != null) {
          ctx.go(
            '/investigations/$investigationId/apply'
            '?completedSurvey=social_determinants&patientId=${widget.patientId}',
          );
        } else {
          ctx.go('/new-survey');
        }
      },
    );
  }
}
