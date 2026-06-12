import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_service.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/presentation/dynamic_survey/dynamic_survey_controller.dart';
import 'package:ssapp/features/surveys/shared/form/form_survey_screen.dart';

class DynamicSurveyScreen extends StatefulWidget {
  final int patientId;
  final int customSurveyId;
  final int? investigationId;

  const DynamicSurveyScreen({
    super.key,
    required this.patientId,
    required this.customSurveyId,
    this.investigationId,
  });

  @override
  State<DynamicSurveyScreen> createState() => _DynamicSurveyScreenState();
}

class _DynamicSurveyScreenState extends State<DynamicSurveyScreen> {
  DynamicSurveyController? _controller;
  CustomSurveyDefinition? _definition;
  bool _loading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _load();
    }
  }

  Future<void> _load() async {
    final service = context.read<CustomSurveyService>();
    var definition = service.getById(widget.customSurveyId);
    if (definition == null) {
      await service.loadAll();
      definition = service.getById(widget.customSurveyId);
    }
    if (!mounted) return;
    if (definition != null) {
      _controller = DynamicSurveyController(
        definition: definition,
        patientId: widget.patientId,
        surveyService: context.read<SurveyService>(),
        investigationId: widget.investigationId,
      );
      _controller!.addListener(_rebuild);
      _definition = definition;
    }
    setState(() {
      _loading = false;
    });
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_rebuild);
    _controller?.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_definition == null || _controller == null) {
      return const Scaffold(
        child: Center(child: Text('Encuesta no encontrada')),
      );
    }

    return FormSurveyScreen(
      questions: _definition!.toFormQuestions(),
      controller: _controller!,
      color: _parseColor(_definition!.colorHex),
      onComplete: (ctx, investigationId) {
        if (investigationId != null) {
          ctx.go(
            '/investigations/$investigationId/apply?completedSurvey=custom&patientId=${widget.patientId}',
          );
        } else {
          ctx.go('/new-survey');
        }
      },
    );
  }
}
