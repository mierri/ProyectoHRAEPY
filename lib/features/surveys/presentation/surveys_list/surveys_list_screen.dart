import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/presentation/surveys_list/components/filters_section.dart';
import 'package:ssapp/features/surveys/presentation/surveys_list/components/stats_section.dart';
import 'package:ssapp/features/surveys/presentation/surveys_list/components/survey_card.dart';
import 'package:ssapp/shared/utils/theme.dart';

class SurveysListScreen extends StatefulWidget {
  const SurveysListScreen({super.key});

  @override
  State<SurveysListScreen> createState() => _SurveysListScreenState();
}

class _SurveysListScreenState extends State<SurveysListScreen> {
  bool _isLoading = true;
  String _filterType = 'all';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      context.read<SurveyService>().loadSurveys(),
      context.read<PatientService>().loadPatients(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> all) {
    const typeIdMap = {
      'bdi': 1, 'bai': 2, 'whoqol': 3, 'sf36': 5, 'assist': 6,
      'gds': 7, 'lawton': 8, 'osteoporosis': 9, 'katz': 10,
      'iciqsf': 11, 'ghq12': 12, 'phq9': 13,
    };
    var result = all;
    if (typeIdMap.containsKey(_filterType)) {
      result = result.where((s) => (s['survey_type'] ?? 1) == typeIdMap[_filterType]).toList();
    }
    if (_filterStatus == 'synced')  result = result.where((s) => s['synced'] == true).toList();
    if (_filterStatus == 'pending') result = result.where((s) => s['synced'] != true).toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final surveys = _filtered(surveyService.surveys);
    final stats = surveyService.getStatistics();

    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Encuestas Aplicadas'),
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
              onPressed: _loadData,
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _SurveysLayout(
              stats: stats,
              surveys: surveys,
              filterType: _filterType,
              filterStatus: _filterStatus,
              onFilterTypeChanged: (v) => setState(() => _filterType = v),
              onFilterStatusChanged: (v) => setState(() => _filterStatus = v),
            ),
    );
  }
}

class _SurveysLayout extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> surveys;
  final String filterType;
  final String filterStatus;
  final ValueChanged<String> onFilterTypeChanged;
  final ValueChanged<String> onFilterStatusChanged;

  const _SurveysLayout({
    required this.stats,
    required this.surveys,
    required this.filterType,
    required this.filterStatus,
    required this.onFilterTypeChanged,
    required this.onFilterStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SurveysStatsSection(stats: stats),
      const Divider(height: 1),
      SurveysFiltersSection(
        filterType: filterType,
        filterStatus: filterStatus,
        onFilterTypeChanged: onFilterTypeChanged,
        onFilterStatusChanged: onFilterStatusChanged,
      ),
      const Divider(height: 1),
      Expanded(
        child: surveys.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: surveys.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SurveyListCard(survey: surveys[i]),
                ),
              ),
      ),
    ]);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(material.Icons.inbox_outlined, size: 64, color: LightModeColors.lightOutline),
        const Gap(16),
        const Text('No hay encuestas').muted(),
        const Gap(8),
        const Text('Las encuestas aplicadas aparecerán aquí').small().muted(),
      ]),
    );
  }
}
