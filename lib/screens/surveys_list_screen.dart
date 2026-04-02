import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/toast_helper.dart';


class SurveysListScreen extends StatefulWidget {
  const SurveysListScreen({super.key});

  @override
  State<SurveysListScreen> createState() => _SurveysListScreenState();
}

class _SurveysListScreenState extends State<SurveysListScreen> {
  bool _isLoading = true;
  String _filterType = 'all';   // 'all' | 'bdi' | 'bai' | 'gds' | 'lawton' | 'katz' | 'iciqsf' | 'moca' | 'whoqol' | 'sf36' | 'assist'
  String _filterStatus = 'all'; // 'all' | 'synced' | 'pending'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final surveyService = context.read<SurveyService>();
    final patientService = context.read<PatientService>();
    await Future.wait([
      surveyService.loadSurveys(),
      patientService.loadPatients(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _filteredSurveys(List<Map<String, dynamic>> all) {
    var result = all;
    const _typeIdMap = {'bdi': 1, 'bai': 2, 'whoqol': 3, 'moca': 4, 'sf36': 5, 'assist': 6, 'gds': 7, 'lawton': 8, 'osteoporosis': 9, 'katz': 10, 'iciqsf': 11};
    if (_typeIdMap.containsKey(_filterType)) {
      final typeId = _typeIdMap[_filterType]!;
      result = result.where((s) => (s['survey_type'] ?? 1) == typeId).toList();
    }
    if (_filterStatus == 'synced')  result = result.where((s) => s['synced'] == true).toList();
    if (_filterStatus == 'pending') result = result.where((s) => s['synced'] != true).toList();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final surveys = _filteredSurveys(surveyService.surveys);
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
          : _NarrowLayout(
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

class _NarrowLayout extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> surveys;
  final String filterType;
  final String filterStatus;
  final ValueChanged<String> onFilterTypeChanged;
  final ValueChanged<String> onFilterStatusChanged;

  const _NarrowLayout({
    required this.stats,
    required this.surveys,
    required this.filterType,
    required this.filterStatus,
    required this.onFilterTypeChanged,
    required this.onFilterStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatsSection(stats: stats),
        const Divider(height: 1),
        _FiltersSection(
          filterType: filterType,
          filterStatus: filterStatus,
          onFilterTypeChanged: onFilterTypeChanged,
          onFilterStatusChanged: onFilterStatusChanged,
        ),
        const Divider(height: 1),
        Expanded(
          child: surveys.isEmpty
              ? const _EmptyState()
              : _SurveyList(surveys: surveys),
        ),
      ],
    );
  }
}


class _StatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      (material.Icons.assignment,   'Total',         '${stats['total']}',   LightModeColors.lightPrimary),
      (material.Icons.cloud_done,   'Sincronizadas', '${stats['synced']}',  LightModeColors.lightTertiary),
      (material.Icons.cloud_upload, 'Pendientes',    '${stats['pending']}', LightModeColors.lightSecondary),
    ];

    Widget card((IconData, String, String, Color) item) => _StatCard(
          icon: item.$1, label: item.$2, value: item.$3, color: item.$4);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas').medium(),
          const Gap(12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: card(items[0])),
                const Gap(10),
                Expanded(child: card(items[1])),
                const Gap(10),
                Expanded(child: card(items[2])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersSection extends StatelessWidget {
  final String filterType;
  final String filterStatus;
  final ValueChanged<String> onFilterTypeChanged;
  final ValueChanged<String> onFilterStatusChanged;

  const _FiltersSection({
    required this.filterType,
    required this.filterStatus,
    required this.onFilterTypeChanged,
    required this.onFilterStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final typeDropdown = _FilterDropdown(
      label: 'Tipo de encuesta',
      options: const [
        _FilterOption(value: 'all', label: 'Todas'),
        _FilterOption(value: 'bdi', label: 'BDI-II'),
        _FilterOption(value: 'bai', label: 'BAI'),
        _FilterOption(value: 'gds', label: 'GDS-15'),
        _FilterOption(value: 'lawton', label: 'Lawton AIVD'),
          _FilterOption(value: 'katz', label: 'Katz ABVD'),
        _FilterOption(value: 'iciqsf', label: 'ICIQ-SF'),
        _FilterOption(value: 'moca', label: 'MoCA'),
        _FilterOption(value: 'whoqol', label: 'WHOQOL-BREF'),
        _FilterOption(value: 'sf36', label: 'SF-36'),
        _FilterOption(value: 'assist', label: 'ASSIST V3.0'),
        _FilterOption(value: 'osteoporosis', label: 'Osteoporosis'),
      ],
      selected: filterType == 'all' ? null : filterType,
      hint: 'Todas',
      onChanged: (v) => onFilterTypeChanged(v ?? 'all'),
    );

    final statusDropdown = _FilterDropdown(
      label: 'Estado',
      options: const [
        _FilterOption(value: 'all', label: 'Todas'),
        _FilterOption(value: 'synced', label: 'Sincronizadas'),
        _FilterOption(value: 'pending', label: 'Pendientes'),
      ],
      selected: filterStatus == 'all' ? null : filterStatus,
      hint: 'Todas',
      onChanged: (v) => onFilterStatusChanged(v ?? 'all'),
    );


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: typeDropdown),
          const Gap(10),
          Expanded(child: statusDropdown),
        ],
      ),
    );
  }
}

class _FilterOption {
  final String value;
  final String label;
  const _FilterOption({required this.value, required this.label});
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<_FilterOption> options;
  final String? selected;
  final String hint;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.options,
    required this.selected,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).small(),
        const Gap(6),
        Select<String>(
          value: selected,
          onChanged: onChanged,
          itemBuilder: (context, item) {
            final match = options.where((o) => o.value == item).toList();
            return Text(match.isNotEmpty ? match.first.label : item);
          },
          popup: SelectPopup(
            items: SelectItemList(
              children: [
                for (final opt in options)
                  SelectItemButton(
                    value: opt.value == 'all' ? null : opt.value,
                    child: Text(opt.label),
                  ),
              ],
            ),
          ).call,
          placeholder: Text(hint, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

class _SurveyList extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;

  const _SurveyList({required this.surveys});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: surveys.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SurveyCard(survey: surveys[index]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(material.Icons.inbox_outlined, size: 64, color: LightModeColors.lightOutline),
          const Gap(16),
          const Text('No hay encuestas').muted(),
          const Gap(8),
          const Text('Las encuestas aplicadas aparecerán aquí').small().muted(),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: color.withValues(alpha: 0.05),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: LightModeColors.lightOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  final Map<String, dynamic> survey;

  const _SurveyCard({required this.survey});

  Color get _surveyColor {
    switch (survey['survey_type'] as int? ?? 1) {
      case 1: return LightModeColors.lightPrimary;
      case 2: return LightModeColors.lightTertiary;
      case 3: return const Color(0xFF7C3AED); // WHOQOL - violeta
      case 4: return const Color(0xFF0EA5E9); // MoCA - celeste
      case 5: return const Color(0xFF06B6D4); // SF-36 - cyan
      case 6: return LightModeColors.lightSecondary; // ASSIST
      case 7: return const Color(0xFF0EA5E9); // GDS-15 - celeste
      case 8: return const Color(0xFF14B8A6); // Lawton AIVD - teal
      case 9: return const Color(0xFF145374); // Osteoporosis
        case 10: return const Color(0xFF0D9488); // Katz ABVD
      case 11: return const Color(0xFF2563EB); // ICIQ-SF
      default: return LightModeColors.lightPrimary;
    }
  }

  String get _surveyTypeName {
    switch (survey['survey_type'] as int? ?? 1) {
      case 1: return 'BDI-II';
      case 2: return 'BAI';
      case 3: return 'WHOQOL-BREF';
      case 4: return 'MoCA';
      case 5: return 'SF-36';
      case 6: return 'ASSIST';
      case 7: return 'GDS-15';
      case 8: return 'Lawton AIVD';
      case 9: return 'Osteoporosis';
        case 10: return 'Katz ABVD';
      case 11: return 'ICIQ-SF';
      default: return 'Encuesta';
    }
  }

  int get _expectedResponses {
    switch (survey['survey_type'] as int? ?? 1) {
      case 3: return 26; // WHOQOL
      case 4: return 0;  // MoCA no usa responses table del mismo modo
      case 5: return 36; // SF-36
      case 7: return 15; // GDS-15
      case 8: return 8;  // Lawton
      case 9: return 7;  // Osteoporosis
        case 10: return 6; // Katz
      case 11: return 4; // ICIQ-SF
      default: return 21; // BDI / BAI
    }
  }

  int get _score {
    final responses = survey['responses'] as List?;
    if (responses == null || responses.isEmpty) return 0;
    final type = survey['survey_type'] as int? ?? 1;
    if (type == 11) {
      return responses.fold<int>(0, (s, r) {
        final qId = r['question_id'] as int? ?? 0;
        if (qId == 4) return s;
        return s + (r['answer_value'] as int? ?? 0);
      });
    }
    return responses.fold<int>(0, (s, r) => s + (r['answer_value'] as int? ?? 0));
  }

  String _level(int score, int type) {
    if (type == 1) { // BDI
      if (score <= 13) return 'Mínima';
      if (score <= 19) return 'Leve';
      if (score <= 28) return 'Moderada';
      return 'Grave';
    }
    if (type == 2) { // BAI
      if (score <= 7)  return 'Mínima';
      if (score <= 15) return 'Leve';
      if (score <= 25) return 'Moderada';
      return 'Severa';
    }
    if (type == 3) return 'WHOQOL'; // WHOQOL - no single score
    if (type == 4) return 'MoCA';   // MoCA
    if (type == 5) return 'SF-36';  // SF-36
    if (type == 7) return score <= 4 ? 'Normal' : 'Síntomas depresivos';
    if (type == 8) return score == 8 ? 'Independencia total' : 'Deterioro funcional';
    if (type == 9) return 'Puntaje: $score'; // Osteoporosis - just show score
    if (type == 10) return score == 6 ? 'Independencia total' : 'Dependencia en algun grado';
    if (type == 11) {
      if (score == 0) return 'Sin incontinencia';
      if (score <= 5) return 'Leve';
      if (score <= 12) return 'Moderada';
      return 'Severa';
    }
    return '';
  }

  Color _levelColor(int score, int type) {
    if (type == 1) {
      if (score <= 13) return LightModeColors.lightTertiary;
      if (score <= 19) return const Color(0xFFFFA726);
      if (score <= 28) return const Color(0xFFFF7043);
      return LightModeColors.lightError;
    }
    if (type == 2) {
      if (score <= 7)  return LightModeColors.lightTertiary;
      if (score <= 15) return const Color(0xFFFFA726);
      if (score <= 25) return const Color(0xFFFF7043);
      return LightModeColors.lightError;
    }
    if (type == 3) return const Color(0xFF7C3AED);
    if (type == 4) return const Color(0xFF0EA5E9);
    if (type == 5) return const Color(0xFF06B6D4); // SF-36 cyan
    if (type == 7) return score <= 4 ? LightModeColors.lightTertiary : LightModeColors.lightError;
    if (type == 8) return score == 8 ? LightModeColors.lightTertiary : const Color(0xFFF59E0B);
    if (type == 9) return const Color(0xFF145374);
    if (type == 10) return score == 6 ? LightModeColors.lightTertiary : const Color(0xFFF59E0B);
    if (type == 11) {
      if (score == 0) return LightModeColors.lightTertiary;
      if (score <= 5) return const Color(0xFFFBBF24);
      if (score <= 12) return const Color(0xFFF97316);
      return LightModeColors.lightError;
    }

    return LightModeColors.lightPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final patientService = context.watch<PatientService>();
    final patientId = survey['patient_id'] as int?;
    final patientName = patientId == null
        ? 'Sin paciente'
        : () {
            try {
              return patientService.patients
                  .firstWhere((p) => p.patientId == patientId)
                  .name;
            } catch (_) {
              return 'Paciente no encontrado';
            }
          }();

    final createdAt    = DateTime.parse(survey['created_at']);
    final isSynced     = survey['synced'] == true;
    final responses    = survey['responses'] as List?;
    final totalResp    = responses?.length ?? 0;
    final surveyType   = survey['survey_type'] as int? ?? 1;
    final expected     = _expectedResponses;
    final isComplete   = surveyType == 4 ? true : (expected == 0 ? true : totalResp >= expected);
    final score        = _score;
    final level        = _level(score, surveyType);
    final levelColor   = _levelColor(score, surveyType);
    final surveyColor  = _surveyColor;
    final respLabel    = surveyType == 4
        ? 'MoCA'
        : (isComplete ? 'Completa' : '$totalResp/$expected respuestas');

    return GestureDetector(
      onTap: isComplete
          ? () => showCenteredToast(
                context,
                title: 'Resultados',
                subtitle: 'Score: $score - $level',
                icon: material.Icons.analytics,
                iconColor: levelColor,
                location: ToastLocation.bottomCenter,
              )
          : null,
      child: OutlinedContainer(
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(16),
        borderColor: surveyColor.withValues(alpha: 0.3),
        borderWidth: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: surveyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(material.Icons.assignment, color: surveyColor, size: 22),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_surveyTypeName).semiBold(),
                          const Gap(8),
                          _SyncBadge(isSynced: isSynced),
                        ],
                      ),
                      const Gap(2),
                      Text(patientName).small().muted(),
                    ],
                  ),
                ),
                if (isComplete) _ScoreBadge(score: score, level: level, color: levelColor),
              ],
            ),
            const Gap(10),
            const Divider(height: 1),
            const Gap(10),

            Row(
              children: [
                Icon(material.Icons.calendar_today, size: 13, color: LightModeColors.lightOnSurfaceVariant),
                const Gap(5),
                Text(DateFormat('dd/MMM/yyyy HH:mm').format(createdAt)).small().muted(),
                const Spacer(),
                Icon(
                  isComplete ? material.Icons.check_circle : material.Icons.hourglass_empty,
                  size: 13,
                  color: isComplete ? LightModeColors.lightTertiary : LightModeColors.lightOnSurfaceVariant,
                ),
                const Gap(5),
                Text(respLabel).small().muted(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool isSynced;
  const _SyncBadge({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    final color = isSynced ? LightModeColors.lightTertiary : LightModeColors.lightSecondary;
    final icon  = isSynced ? material.Icons.cloud_done : material.Icons.cloud_upload;
    final label = isSynced ? 'Sincronizada' : 'Pendiente';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const Gap(3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  final String level;
  final Color color;
  const _ScoreBadge({required this.score, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$score', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

