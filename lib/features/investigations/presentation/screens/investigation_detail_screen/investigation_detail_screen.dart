import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/presentation/components/tab_selector/tab_selector.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigation_detail_screen/components/components.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';

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
        InvestigationDetailHeader(investigationId: widget.investigationId),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : investigation == null
              ? MissingInvestigationView(id: widget.investigationId)
              : InvestigationDetailContent(
                  investigation: investigation,
                  selectedTab: _selectedTab,
                  onTabChanged: (tab) => setState(() => _selectedTab = tab),
                    onApply: () => context.push('/investigations/${widget.investigationId}/apply'),
                  patientsById: {
                    for (final patient in patientService.patients) patient.patientId: patient,
                  },
                ),
    );
  }
}

