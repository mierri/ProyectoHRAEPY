import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/surveys/domain/survey_catalog.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_screen.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_questions.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/presentation/perceived_attendance_barriers_controller.dart';

const _kColor = Color(0xFFBE123C);

class PerceivedAttendanceBarriersScreen extends StatefulWidget {
  final int patientId;

  const PerceivedAttendanceBarriersScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<PerceivedAttendanceBarriersScreen> createState() =>
      _PerceivedAttendanceBarriersScreenState();
}

class _PerceivedAttendanceBarriersScreenState
    extends State<PerceivedAttendanceBarriersScreen> {
  PerceivedAttendanceBarriersController? _controller;
  bool _includeAntecedentsSection = false;
  bool _loadingContext = true;
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
      _initialized = true;
      _prepareContext();
    }
  }

  Future<void> _prepareContext() async {
    final surveyService = context.read<SurveyService>();
    await surveyService.loadSurveys();

    final includeAntecedentsSection =
        _resolveAntecedentsSection(surveyService.surveys);
    final controller = PerceivedAttendanceBarriersController(
      patientId: widget.patientId,
      surveyService: surveyService,
      includeAntecedentsSection: includeAntecedentsSection,
      investigationId: _fromInvestigationId(),
    );
    controller.addListener(_rebuild);

    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _controller = controller;
      _includeAntecedentsSection = includeAntecedentsSection;
      _loadingContext = false;
    });
  }

  bool _resolveAntecedentsSection(List<Map<String, dynamic>> surveys) {
    final previousAttendanceSurveys = surveys
        .where(
          (survey) =>
              survey['patient_id'] == widget.patientId &&
              survey['survey_type'] ==
                  SurveyCatalog.specialtyConsultationAttendance,
        )
        .toList()
      ..sort((a, b) {
        final aDate = DateTime.tryParse('${a['created_at'] ?? ''}');
        final bDate = DateTime.tryParse('${b['created_at'] ?? ''}');
        if (aDate == null && bDate == null) {
          return 0;
        }
        if (aDate == null) {
          return 1;
        }
        if (bDate == null) {
          return -1;
        }
        return bDate.compareTo(aDate);
      });

    if (previousAttendanceSurveys.isEmpty) {
      return false;
    }

    final latestSurvey = previousAttendanceSurveys.first;
    final responses = latestSurvey['responses'] as List? ?? const [];
    for (final response in responses) {
      final questionId = response['question_id'] as int?;
      final answerValue = response['answer_value'] as int?;
      if (questionId == 8) {
        return answerValue == 0;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _controller?.removeListener(_rebuild);
    _controller?.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingContext || _controller == null) {
      return const Scaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FormSurveyScreen(
      questions: buildPerceivedAttendanceBarriersQuestions(
        includeAntecedentsSection: _includeAntecedentsSection,
      ),
      controller: _controller!,
      color: _kColor,
      onComplete: (ctx, investigationId) {
        if (investigationId != null) {
          ctx.go(
            '/investigations/$investigationId/apply'
            '?completedSurvey=perceived_attendance_barriers&patientId=${widget.patientId}',
          );
        } else {
          ctx.go('/new-survey');
        }
      },
    );
  }
}
