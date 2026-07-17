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

  // Memoización de lista filtrada
  List<PatientModel>? _cachedFiltered;
  List<PatientModel>? _cachedSource;
  String? _cachedQuery;

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
    try {
      await Future.wait([
        context.read<PatientService>().loadPatients(),
        context.read<SurveyService>().loadSurveys(),
      ]);
    } finally {
      // Garantiza que el spinner no quede pegado si algo inesperado falla:
      // antes, una excepción no capturada dejaba _isLoading en true para siempre.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<PatientModel> _filtered(List<PatientModel> all) {
    if (identical(_cachedSource, all) &&
        _cachedQuery == _searchQuery &&
        _cachedFiltered != null) {
      return _cachedFiltered!;
    }
    final q = _searchQuery.toLowerCase();
    final result = q.isEmpty
        ? all
        : all.where((p) => p.name.toLowerCase().contains(q)).toList();
    _cachedSource = all;
    _cachedQuery = _searchQuery;
    _cachedFiltered = result;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Solo reconstruye cuando cambia la lista de pacientes, no en cualquier notify
    final allPatients = context.select<PatientService, List<PatientModel>>(
      (s) => s.patients,
    );
    // Mapa patientId→count calculado O(M) una sola vez; cada card ya no itera
    final surveyCounts = context.select<SurveyService, Map<int, int>>((s) {
      final counts = <int, int>{};
      for (final survey in s.surveys) {
        if ((survey['responses'] as List?)?.isNotEmpty == true) {
          final pid = survey['patient_id'] as int?;
          if (pid != null) counts[pid] = (counts[pid] ?? 0) + 1;
        }
      }
      return counts;
    });
    final patients = _filtered(allPatients);

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
                        separatorBuilder: (_, i) => const Gap(12),
                        itemBuilder: (_, i) => RepaintBoundary(
                          child: PatientCard(
                            patient: patients[i],
                            surveyCount: surveyCounts[patients[i].patientId] ?? 0,
                          ),
                        ),
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
