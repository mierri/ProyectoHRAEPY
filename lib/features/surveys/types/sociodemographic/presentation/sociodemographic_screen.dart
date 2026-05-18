import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_screen.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_questions.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/presentation/sociodemographic_controller.dart';

const _kColor = Color(0xFF0891B2);

class SociodemographicScreen extends StatefulWidget {
  final int patientId;

  const SociodemographicScreen({super.key, required this.patientId});

  @override
  State<SociodemographicScreen> createState() => _SociodemographicScreenState();
}

class _SociodemographicScreenState extends State<SociodemographicScreen> {
  late SociodemographicController _controller;
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
      _controller = SociodemographicController(
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
      questions: sociodemographicQuestions,
      controller: _controller,
      color: _kColor,
      onComplete: (ctx, investigationId) {
        if (investigationId != null) {
          ctx.go(
            '/investigations/$investigationId/apply'
            '?completedSurvey=sociodemographic&patientId=${widget.patientId}',
          );
        } else {
          ctx.go('/new-survey');
        }
      },
    );
  }
}
