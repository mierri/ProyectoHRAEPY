import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_screen.dart';
import 'package:ssapp/features/surveys/types/moca_blind/domain/moca_blind_questions.dart';
import 'package:ssapp/features/surveys/types/moca_blind/presentation/moca_blind_controller.dart';

const _kColor = Color(0xFF1D4ED8);

class MocaBlindScreen extends StatefulWidget {
  final int patientId;

  const MocaBlindScreen({super.key, required this.patientId});

  @override
  State<MocaBlindScreen> createState() => _MocaBlindScreenState();
}

class _MocaBlindScreenState extends State<MocaBlindScreen> {
  late MocaBlindController _controller;
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
      _controller = MocaBlindController(
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
      questions: mocaBlindQuestions,
      controller: _controller,
      color: _kColor,
      onComplete: (ctx, investigationId) {
        if (investigationId != null) {
          ctx.go(
            '/investigations/$investigationId/apply'
            '?completedSurvey=moca_blind&patientId=${widget.patientId}',
          );
        } else {
          ctx.go('/new-survey');
        }
      },
    );
  }
}
