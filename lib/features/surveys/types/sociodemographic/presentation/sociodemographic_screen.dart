import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_screen.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_fields.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_questions.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/presentation/sociodemographic_controller.dart';
import 'package:ssapp/shared/models/patient_model.dart';

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
      _preloadConsentFields();
    }
  }

  Future<void> _preloadConsentFields() async {
    final patientService = context.read<PatientService>();
    PatientModel? patient = patientService.patients
        .where((p) => p.patientId == widget.patientId)
        .firstOrNull;
    patient ??= await patientService.getPatientById(widget.patientId);

    if (!mounted || patient == null) return;

    if (_controller.intAnswer(SociodemographicFieldIds.sexo) == null) {
      final sexValue = switch (patient.gender.toUpperCase()) {
        'F' => 0,
        'M' => 1,
        'O' => 2,
        _ => null,
      };
      if (sexValue != null) {
        _controller.setIntAnswer(SociodemographicFieldIds.sexo, sexValue);
      }
    }

    if (_controller.intAnswer(SociodemographicFieldIds.edad) == null) {
      _controller.setIntAnswer(SociodemographicFieldIds.edad, patient.age);
      _controller.setTextAnswer(SociodemographicFieldIds.edad, patient.age.toString());
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
