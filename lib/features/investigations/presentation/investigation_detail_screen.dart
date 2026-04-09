import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/consent_section/consent_section.dart';
import 'package:ssapp/features/investigations/presentation/components/hero_card/hero_card.dart';
import 'package:ssapp/features/investigations/presentation/components/participants_section/participants_section.dart';
import 'package:ssapp/features/investigations/presentation/components/reports_section/reports_section.dart';
import 'package:ssapp/features/investigations/presentation/components/surveys_section/surveys_section.dart';
import 'package:ssapp/features/investigations/presentation/components/tab_selector/tab_selector.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/models/patient_model.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

class InvestigationDetailScreen extends StatefulWidget {
  final int investigationId;

  const InvestigationDetailScreen({
    super.key,
    required this.investigationId,
  });

  @override
  State<InvestigationDetailScreen> createState() => _InvestigationDetailScreenState();
}

class _InvestigationDetailScreenState extends State<InvestigationDetailScreen> {
  bool _isLoading = true;
  InvestigationDetailTab _selectedTab = InvestigationDetailTab.surveys;

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

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final investigationService = context.watch<InvestigationService>();
    final patientService = context.watch<PatientService>();
    final investigation = investigationService.byId(widget.investigationId);

    return Scaffold(
      headers: [
        AppBar(
          title: Text('Investigacion #${widget.investigationId}'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              variance: ButtonVariance.ghost,
              onPressed: () => context.pop(),
            ),
          ],
          trailing: [
            IconButton(
              icon: const Icon(material.Icons.edit),
              variance: ButtonVariance.ghost,
              onPressed: () {
                showCenteredToast(
                  context,
                  title: 'Edicion pendiente',
                  subtitle: 'En la siguiente iteracion agregamos edicion completa',
                  icon: material.Icons.edit,
                  iconColor: LightModeColors.lightPrimary,
                  location: ToastLocation.topCenter,
                );
              },
            ),
          ],
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : investigation == null
              ? _MissingInvestigation(id: widget.investigationId)
              : _DetailBody(
                  investigation: investigation,
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) => setState(() => _selectedTab = tab),
                  patientsById: {
                    for (final patient in patientService.patients) patient.patientId: patient,
                  },
                ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final InvestigationModel investigation;
  final InvestigationDetailTab selectedTab;
  final ValueChanged<InvestigationDetailTab> onTabChanged;
  final Map<int, PatientModel> patientsById;

  const _DetailBody({
    required this.investigation,
    required this.selectedTab,
    required this.onTabChanged,
    required this.patientsById,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InvestigationHeroCard(investigation: investigation),
          const Gap(16),
          InvestigationTabSelector(
            selected: selectedTab,
            onChanged: onTabChanged,
          ),
          const Gap(16),
          _buildSelectedSection(),
        ],
      ),
    );
  }

  Widget _buildSelectedSection() {
    switch (selectedTab) {
      case InvestigationDetailTab.surveys:
        return InvestigationSurveysSection(investigation: investigation);
      case InvestigationDetailTab.consent:
        return InvestigationConsentSection(investigation: investigation);
      case InvestigationDetailTab.participants:
        return InvestigationParticipantsSection(
          investigation: investigation,
          patientsById: patientsById,
        );
      case InvestigationDetailTab.reports:
        return InvestigationReportsSection(investigation: investigation);
    }
  }
}

class _MissingInvestigation extends StatelessWidget {
  final int id;

  const _MissingInvestigation({required this.id});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              material.Icons.science_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(12),
            Text('No se encontro la investigacion $id').semiBold(),
            const Gap(6),
            const Text('Actualiza el listado e intenta nuevamente.').small().muted(),
            const Gap(12),
            OutlineButton(
              onPressed: () => context.go('/investigations'),
              child: const Text('Volver al listado'),
            ),
          ],
        ),
      ),
    );
  }
}
