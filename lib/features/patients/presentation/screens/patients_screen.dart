import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/patients/presentation/components/add_patient_dialog.dart';
import 'package:ssapp/features/patients/presentation/components/patient_card.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;

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
      context.read<PatientService>().loadPatients(),
      context.read<SurveyService>().loadSurveys(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  List<PatientModel> _filtered(List<PatientModel> all) {
    if (_searchQuery.isEmpty) return all;
    return all
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final patients = _filtered(context.watch<PatientService>().patients);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Pacientes'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => context.pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
          trailing: [
            IconButton(
              icon: const Icon(material.Icons.refresh),
              onPressed: _isLoading ? null : _loadData,
              variance: ButtonVariance.ghost,
            ),
            const Gap(8),
            PrimaryButton(
              density: ButtonDensity.icon,
              onPressed: () => showAddPatientDialog(context),
              child: const Icon(material.Icons.add),
            ),
          ],
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              _SearchBar(
                controller: _searchController,
                query: _searchQuery,
                onChanged: (v) => setState(() => _searchQuery = v),
                onClear: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
              Expanded(
                child: patients.isEmpty
                    ? _EmptyState(hasQuery: _searchQuery.isNotEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: patients.length,
                        separatorBuilder: (_, __) => const Gap(12),
                        itemBuilder: (_, i) => PatientCard(patient: patients[i]),
                      ),
              ),
            ]),
    );
  }
}

// ── Local widgets (screen-scoped) ─────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            placeholder: const Text('Buscar paciente por nombre...'),
            onChanged: onChanged,
          ),
        ),
        if (query.isNotEmpty) ...[
          const Gap(8),
          IconButton(
            icon: const Icon(material.Icons.clear),
            onPressed: onClear,
            variance: ButtonVariance.ghost,
          ),
        ],
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(material.Icons.people_outline,
            size: 80, color: Theme.of(context).colorScheme.mutedForeground),
        const Gap(16),
        Text(
          hasQuery ? 'No se encontraron resultados' : 'No hay pacientes registrados',
          style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.mutedForeground),
        ),
        const Gap(8),
        Text(hasQuery
                ? 'Intenta con otro término de búsqueda'
                : 'Agrega un nuevo paciente para comenzar')
            .muted()
            .small(),
      ]),
    );
  }
}
