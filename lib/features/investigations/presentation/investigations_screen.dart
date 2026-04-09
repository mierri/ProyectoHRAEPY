import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/data/investigation_repository.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/list_card/list_card.dart';
import 'package:ssapp/features/investigations/presentation/components/search_bar/search_bar.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

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

    final investigationService = context.read<InvestigationService>();
    final patientService = context.read<PatientService>();

    await Future.wait([
      investigationService.loadInvestigations(),
      patientService.loadPatients(),
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
    final investigationService = context.watch<InvestigationService>();
    final allInvestigations = investigationService.investigations;
    final investigations = _filtered(allInvestigations);

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Investigaciones'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              variance: ButtonVariance.ghost,
              onPressed: () => context.pop(),
            ),
          ],
          trailing: [
            IconButton(
              icon: const Icon(material.Icons.refresh),
              variance: ButtonVariance.ghost,
              onPressed: _isLoading ? null : _loadData,
            ),
          ],
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: PrimaryButton(
                    onPressed: () {
                      showCenteredToast(
                        context,
                        title: 'Proximamente',
                        subtitle: 'Creacion de investigaciones en la siguiente iteracion',
                        icon: material.Icons.science,
                        iconColor: LightModeColors.lightPrimary,
                        location: ToastLocation.topCenter,
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(material.Icons.add, size: 18),
                        Gap(8),
                        Text('Nueva investigacion'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: InvestigationsSearchBar(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Row(
                    children: [
                      const Text('Listado disponible').semiBold(),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.muted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('${investigations.length}').small().semiBold(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: investigations.isEmpty
                      ? _InvestigationsEmptyState(hasFilter: _searchQuery.trim().isNotEmpty)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          itemCount: investigations.length,
                          separatorBuilder: (context, index) => const Gap(12),
                          itemBuilder: (context, index) {
                            final investigation = investigations[index];
                            return InvestigationListCard(
                              investigation: investigation,
                              onTap: () => context.push('/investigations/${investigation.id}'),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _InvestigationsEmptyState extends StatelessWidget {
  final bool hasFilter;

  const _InvestigationsEmptyState({required this.hasFilter});

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
            Text(
              hasFilter
                  ? 'No encontramos investigaciones con ese termino'
                  : 'No hay investigaciones registradas todavia',
              textAlign: TextAlign.center,
            ).semiBold(),
            const Gap(6),
            Text(
              hasFilter
                  ? 'Prueba con otro nombre o ID.'
                  : 'Cuando crees una investigacion aparecera aqui.',
              textAlign: TextAlign.center,
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}
