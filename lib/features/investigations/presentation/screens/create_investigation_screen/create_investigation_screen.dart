import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/presentation/screens/create_investigation_screen/components/components.dart';
import 'package:ssapp/features/investigations/presentation/screens/create_investigation_screen/create_flow_step.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

class CreateInvestigationScreen extends StatefulWidget {
  final int? investigationId;

  const CreateInvestigationScreen({
    super.key,
    this.investigationId,
  });

  @override
  State<CreateInvestigationScreen> createState() => _CreateInvestigationScreenState();
}

class _CreateInvestigationScreenState extends State<CreateInvestigationScreen> {
  static const List<CreateFlowStep> _steps = [
    CreateFlowStep.details,
    CreateFlowStep.surveys,
    CreateFlowStep.consent,
    CreateFlowStep.review,
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _consentController = TextEditingController();

  final List<int> _selectedSurveyTypeIds = [];
  List<String> _consentCheckboxes = [];

  CreateFlowStep _currentStep = CreateFlowStep.details;
  bool _isLoading = false;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.investigationId != null;

  int get _currentIndex => _steps.indexOf(_currentStep);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChanged);
    _consentController.addListener(_onFormChanged);
    _bootstrapInitialValues();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _consentController.removeListener(_onFormChanged);
    _nameController.dispose();
    _consentController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _bootstrapInitialValues() {
    if (!_isEditMode) return;
    _loadExistingInvestigation();
  }

  Future<void> _loadExistingInvestigation() async {
    setState(() => _isLoading = true);

    final service = context.read<InvestigationService>();
    await service.loadInvestigations();
    final investigation = service.byId(widget.investigationId!);

    if (investigation != null) {
      _nameController.text = investigation.investigationName;
      _consentController.text = investigation.formConsent;
      _selectedSurveyTypeIds
        ..clear()
        ..addAll(investigation.surveyTypeIds);
      setState(() => _consentCheckboxes = List<String>.from(investigation.consentCheckboxes));
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case CreateFlowStep.details:
        return _nameController.text.trim().length >= 3;
      case CreateFlowStep.surveys:
        return _selectedSurveyTypeIds.isNotEmpty;
      case CreateFlowStep.consent:
        return _consentController.text.trim().length >= 20;
      case CreateFlowStep.review:
        return true;
    }
  }

  void _goNext() {
    if (_currentIndex >= _steps.length - 1) return;
    setState(() => _currentStep = _steps[_currentIndex + 1]);
  }

  void _goBack() {
    if (_currentIndex <= 0) return;
    setState(() => _currentStep = _steps[_currentIndex - 1]);
  }

  void _toggleSurvey(int surveyTypeId) {
    setState(() {
      if (_selectedSurveyTypeIds.contains(surveyTypeId)) {
        _selectedSurveyTypeIds.remove(surveyTypeId);
      } else {
        _selectedSurveyTypeIds.add(surveyTypeId);
      }
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    final service = context.read<InvestigationService>();

    final createdOrUpdated = _isEditMode
        ? await service.updateInvestigation(
            investigationId: widget.investigationId!,
            investigationName: _nameController.text.trim(),
            formConsent: _consentController.text.trim(),
            surveyTypeIds: List<int>.from(_selectedSurveyTypeIds),
            consentCheckboxes: List<String>.from(_consentCheckboxes),
          )
        : await service.createInvestigation(
            investigationName: _nameController.text.trim(),
            formConsent: _consentController.text.trim(),
            surveyTypeIds: List<int>.from(_selectedSurveyTypeIds),
            consentCheckboxes: List<String>.from(_consentCheckboxes),
          );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (createdOrUpdated == null) {
      showCenteredToast(
        context,
        title: 'No se pudo guardar la investigacion',
        subtitle: 'Intenta nuevamente.',
        icon: material.Icons.error_outline,
        iconColor: Theme.of(context).colorScheme.destructive,
        location: ToastLocation.topCenter,
      );
      return;
    }

    showCenteredToast(
      context,
      title: _isEditMode ? 'Investigacion actualizada' : 'Investigacion creada',
      subtitle: _isEditMode ? 'Los cambios se guardaron correctamente.' : 'Ya aparece en el listado.',
      icon: _isEditMode ? material.Icons.check_circle_outline : material.Icons.celebration_outlined,
      iconColor: LightModeColors.lightPrimary,
      location: ToastLocation.topCenter,
    );

    context.go('/investigations/${createdOrUpdated.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        CreateInvestigationHeader(
          isEditMode: _isEditMode,
          currentStep: _currentStep,
          currentStepIndex: _currentIndex,
          totalSteps: _steps.length,
          onBackStep: _goBack,
        ),
      ],
      footers: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: CreateInvestigationActions(
            isFirstStep: _currentIndex == 0,
            isLastStep: _currentIndex == _steps.length - 1,
            canProceed: _canProceed,
            isSubmitting: _isSubmitting,
            isEditMode: _isEditMode,
            onCancel: () => context.pop(),
            onBack: _goBack,
            onContinue: _goNext,
            onSubmit: _submit,
          ),
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CreateStepTabs(
              steps: _steps,
              currentStep: _currentStep,
              onSelectStep: (step) => setState(() => _currentStep = step),
            ),
            const Gap(16),
            _StepBody(
              step: _currentStep,
              nameController: _nameController,
              consentController: _consentController,
              selectedSurveyTypeIds: _selectedSurveyTypeIds,
              onToggleSurvey: _toggleSurvey,
              consentCheckboxes: _consentCheckboxes,
              onCheckboxesChanged: (labels) => setState(() => _consentCheckboxes = labels),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  final CreateFlowStep step;
  final TextEditingController nameController;
  final TextEditingController consentController;
  final List<int> selectedSurveyTypeIds;
  final ValueChanged<int> onToggleSurvey;
  final List<String> consentCheckboxes;
  final ValueChanged<List<String>> onCheckboxesChanged;

  const _StepBody({
    required this.step,
    required this.nameController,
    required this.consentController,
    required this.selectedSurveyTypeIds,
    required this.onToggleSurvey,
    required this.consentCheckboxes,
    required this.onCheckboxesChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case CreateFlowStep.details:
        return InvestigationDetailsStep(nameController: nameController);
      case CreateFlowStep.surveys:
        return InvestigationSurveysStep(
          selectedSurveyTypeIds: selectedSurveyTypeIds,
          onToggleSurvey: onToggleSurvey,
        );
      case CreateFlowStep.consent:
        return InvestigationConsentStep(
          consentController: consentController,
          checkboxLabels: consentCheckboxes,
          onCheckboxesChanged: onCheckboxesChanged,
        );
      case CreateFlowStep.review:
        return InvestigationReviewStep(
          name: nameController.text.trim(),
          consent: consentController.text.trim(),
          selectedSurveyTypeIds: selectedSurveyTypeIds,
          consentCheckboxes: consentCheckboxes,
        );
    }
  }
}




