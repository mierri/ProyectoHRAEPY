import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/apply_consent_card/view.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/apply_header/view.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/apply_patient_picker/view.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_apply_screen/components/survey_launch_card/view.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_type_config.dart';

class InvestigationApplyScreen extends StatefulWidget {
  final int investigationId;

  const InvestigationApplyScreen({
    super.key,
    required this.investigationId,
  });

  @override
  State<InvestigationApplyScreen> createState() => _InvestigationApplyScreenState();
}

class _InvestigationApplyScreenState extends State<InvestigationApplyScreen> {
  bool _isLoading = true;
  int? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      context.read<InvestigationService>().loadInvestigations(),
      context.read<PatientService>().loadPatients(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  void _launchSurvey(BuildContext context, String surveyType) {
    final patientId = _selectedPatientId;
    if (patientId == null) {
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Selecciona un participante antes de aplicar una encuesta.').small(),
          ),
        ),
        location: ToastLocation.bottomCenter,
      );
      return;
    }

    context.push('/survey/$patientId?surveyType=$surveyType');
  }

  @override
  Widget build(BuildContext context) {
    final investigation = context.watch<InvestigationService>().byId(widget.investigationId);
    final patients = context.watch<PatientService>().patients;

    return Scaffold(
      headers: [
        ApplyInvestigationHeader(investigationTitle: investigation?.investigationName ?? 'Investigacion'),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : investigation == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(material.Icons.science_outlined, size: 64),
                        const Gap(12),
                        const Text('No se encontro la investigacion').semiBold(),
                        const Gap(8),
                        OutlineButton(onPressed: () => context.pop(), child: const Text('Volver')),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ApplyConsentCard(consentText: investigation.formConsent),
                      const Gap(16),
                      const Text('Selecciona un participante').semiBold(),
                      const Gap(8),
                      ApplyPatientPicker(
                        patients: patients,
                        selectedPatientId: _selectedPatientId,
                        onSelected: (patientId) => setState(() => _selectedPatientId = patientId),
                      ),
                      const Gap(16),
                      const Text('Encuestas de la investigacion').semiBold(),
                      const Gap(8),
                      for (final survey in _surveyItems(investigation)) ...[
                        SurveyLaunchCard(
                          title: survey.title,
                          description: survey.description,
                          itemCount: survey.itemCount,
                          enabled: _selectedPatientId != null,
                          onTap: () => _launchSurvey(context, survey.surveyType),
                        ),
                        const Gap(10),
                      ],
                    ],
                  ),
                ),
    );
  }

  List<_SurveyLaunchItem> _surveyItems(InvestigationModel investigation) {
    return investigation.surveyTypeIds.map((id) {
      final surveyType = InvestigationService.surveyTypeToRouteCode[id] ?? 'bdi';
      return _SurveyLaunchItem(
        surveyType: surveyType,
        title: InvestigationService.surveyTypes[id] ?? 'Tipo $id',
        description: SurveyTypeConfig.descriptionFor(surveyType),
        itemCount: SurveyTypeConfig.itemCountFor(surveyType),
      );
    }).toList();
  }
}

class _SurveyLaunchItem {
  final String surveyType;
  final String title;
  final String description;
  final int itemCount;

  const _SurveyLaunchItem({
    required this.surveyType,
    required this.title,
    required this.description,
    required this.itemCount,
  });
}



