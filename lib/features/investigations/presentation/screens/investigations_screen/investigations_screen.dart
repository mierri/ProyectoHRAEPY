import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigations_screen/components/components.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';

class InvestigationsScreen extends StatefulWidget {
  const InvestigationsScreen({super.key});

  @override
  State<InvestigationsScreen> createState() => _InvestigationsScreenState();
}

class _InvestigationsScreenState extends State<InvestigationsScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<InvestigationModel> _filtered(List<InvestigationModel> investigations) {
    if (_searchQuery.trim().isEmpty) return investigations;

    final query = _searchQuery.trim().toLowerCase();
    return investigations.where((investigation) {
      return investigation.investigationName.toLowerCase().contains(query) ||
          investigation.id.toString().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allInvestigations = context.watch<InvestigationService>().investigations;

    return Scaffold(
      headers: [
        InvestigationsHeader(isLoading: _isLoading, onRefresh: _loadData),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : InvestigationsContent(
              investigations: _filtered(allInvestigations),
              searchQuery: _searchQuery,
              searchController: _searchController,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onClearSearch: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
    );
  }
}

