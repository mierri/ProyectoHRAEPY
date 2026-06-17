import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_screen.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_questions.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/presentation/specialty_consultation_attendance_controller.dart';

const _kColor = Color(0xFFB45309);

class SpecialtyConsultationAttendanceScreen extends StatefulWidget {
  final int patientId;

  const SpecialtyConsultationAttendanceScreen({super.key, required this.patientId});

  @override
  State<SpecialtyConsultationAttendanceScreen> createState() =>
      _SpecialtyConsultationAttendanceScreenState();
}

class _SpecialtyConsultationAttendanceScreenState
    extends State<SpecialtyConsultationAttendanceScreen> {
  late SpecialtyConsultationAttendanceController _controller;
  bool _initialized = false;
  bool _prefilledPatientData = false;

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
      _controller = SpecialtyConsultationAttendanceController(
        patientId: widget.patientId,
        surveyService: context.read<SurveyService>(),
        investigationId: _fromInvestigationId(),
      );
      _controller.addListener(_rebuild);
      _initialized = true;
    }
    if (!_prefilledPatientData) {
      _prefilledPatientData = true;
      _prefillPatientData();
    }
  }

  Future<void> _prefillPatientData() async {
    final patientService = context.read<PatientService>();
    final matches = patientService.patients
        .where((p) => p.patientId == widget.patientId)
        .toList();
    var patient = matches.isNotEmpty ? matches.first : null;

    patient ??= await patientService.getPatientById(widget.patientId);

    if (!mounted || patient == null) return;
    _controller.preloadPatientData(patient);
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
      questions: specialtyConsultationAttendanceQuestions,
      controller: _controller,
      color: _kColor,
      onComplete: (ctx, investigationId) {
        if (investigationId != null) {
          ctx.go(
            '/investigations/$investigationId/apply'
            '?completedSurvey=specialty_consultation_attendance&patientId=${widget.patientId}',
          );
        } else {
          ctx.go('/new-survey');
        }
      },
    );
  }
}
