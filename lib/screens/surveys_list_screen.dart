import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:ssapp/utils/toast_helper.dart';

// ─── Breakpoints ────────────────────────────────────────────────────────────
class _Breakpoints {
  static const double tablet = 600;
}

// ─── Screen ─────────────────────────────────────────────────────────────────
class SurveysListScreen extends StatefulWidget {
  const SurveysListScreen({super.key});

  @override
  State<SurveysListScreen> createState() => _SurveysListScreenState();
}

class _SurveysListScreenState extends State<SurveysListScreen> {
  bool _isLoading = true;
  String _filterType = 'all';   // 'all' | 'bdi' | 'bai'
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
    if (_filterType == 'bdi') result = result.where((s) => (s['survey_type'] ?? 1) == 1).toList();
    if (_filterType == 'bai') result = result.where((s) => (s['survey_type'] ?? 1) == 2).toList();
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
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= _Breakpoints.tablet;

                if (isWide) {
                  return _WideLayout(
                    stats: stats,
                    surveys: surveys,
                    filterType: _filterType,
                    filterStatus: _filterStatus,
                    onFilterTypeChanged: (v) => setState(() => _filterType = v),
                    onFilterStatusChanged: (v) => setState(() => _filterStatus = v),
                  );
                }

                return _NarrowLayout(
                  stats: stats,
                  surveys: surveys,
                  filterType: _filterType,
                  filterStatus: _filterStatus,
                  onFilterTypeChanged: (v) => setState(() => _filterType = v),
                  onFilterStatusChanged: (v) => setState(() => _filterStatus = v),
                );
              },
            ),
    );
  }
}

// ─── Narrow layout (mobile) ─────────────────────────────────────────────────
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

// ─── Wide layout (tablet / desktop) ─────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> surveys;
  final String filterType;
  final String filterStatus;
  final ValueChanged<String> onFilterTypeChanged;
  final ValueChanged<String> onFilterStatusChanged;

  const _WideLayout({
    required this.stats,
    required this.surveys,
    required this.filterType,
    required this.filterStatus,
    required this.onFilterTypeChanged,
    required this.onFilterStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sidebar ──────────────────────────────
        SizedBox(
          width: 260,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: LightModeColors.lightOutline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsSection(stats: stats, compact: true),
                  const Gap(24),
                  const Divider(),
                  const Gap(16),
                  _FiltersSection(
                    filterType: filterType,
                    filterStatus: filterStatus,
                    onFilterTypeChanged: onFilterTypeChanged,
                    onFilterStatusChanged: onFilterStatusChanged,
                    vertical: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Content ──────────────────────────────
        Expanded(
          child: surveys.isEmpty
              ? const _EmptyState()
              : _SurveyList(surveys: surveys, wideMode: true),
        ),
      ],
    );
  }
}

// ─── Stats section ───────────────────────────────────────────────────────────
class _StatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;
  /// When true, stacks the stat cards vertically (sidebar usage).
  final bool compact;

  const _StatsSection({required this.stats, this.compact = false});

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
      padding: compact ? EdgeInsets.zero : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas').medium(),
          const Gap(12),
          if (compact)
            // Sidebar: apiladas verticalmente, sin riesgo de apachurramiento
            Column(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: card(item),
                      ))
                  .toList(),
            )
          else
            // Mobile / inline: usa LayoutBuilder para decidir cuántas columnas
            LayoutBuilder(builder: (context, constraints) {
              // Ancho mínimo cómodo por tarjeta (ícono + número + etiqueta)
              const minCardWidth = 90.0;
              final fits3 = constraints.maxWidth >= minCardWidth * 3 + 20;

              if (fits3) {
                return IntrinsicHeight(
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
                );
              }

              // Pantallas muy estrechas: 2 + 1
              return Column(
                children: [
                  Row(children: [
                    Expanded(child: card(items[0])),
                    const Gap(10),
                    Expanded(child: card(items[1])),
                  ]),
                  const Gap(10),
                  card(items[2]),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ─── Filters section ─────────────────────────────────────────────────────────
class _FiltersSection extends StatelessWidget {
  final String filterType;
  final String filterStatus;
  final ValueChanged<String> onFilterTypeChanged;
  final ValueChanged<String> onFilterStatusChanged;
  /// When true renders filters stacked (sidebar). When false renders inline (top bar).
  final bool vertical;

  const _FiltersSection({
    required this.filterType,
    required this.filterStatus,
    required this.onFilterTypeChanged,
    required this.onFilterStatusChanged,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final typeGroup = _FilterGroup(
      label: 'Tipo',
      options: const [
        _FilterOption(value: 'all', label: 'Todas'),
        _FilterOption(value: 'bdi', label: 'BDI'),
        _FilterOption(value: 'bai', label: 'BAI'),
      ],
      selected: filterType,
      color: LightModeColors.lightPrimary,
      onChanged: onFilterTypeChanged,
    );

    final statusGroup = _FilterGroup(
      label: 'Estado',
      options: const [
        _FilterOption(value: 'all', label: 'Todas'),
        _FilterOption(value: 'synced', label: 'Sincronizadas'),
        _FilterOption(value: 'pending', label: 'Pendientes'),
      ],
      selected: filterStatus,
      color: LightModeColors.lightTertiary,
      onChanged: onFilterStatusChanged,
    );

    if (vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros').small().muted(),
          const Gap(12),
          typeGroup,
          const Gap(12),
          statusGroup,
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros').small().muted(),
          const Gap(12),
          typeGroup,
          const Gap(12),
          statusGroup,
        ],
      ),
    );
  }
}

// ─── Filter group (label + row of buttons) ───────────────────────────────────
class _FilterOption {
  final String value;
  final String label;
  const _FilterOption({required this.value, required this.label});
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final List<_FilterOption> options;
  final String selected;
  final Color color;
  final ValueChanged<String> onChanged;

  const _FilterGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).small(),
        const Gap(6),
        Row(
          children: [
            for (int i = 0; i < options.length; i++) ...[
              if (i > 0) const Gap(4),
              Expanded(
                child: _FilterButton(
                  label: options[i].label,
                  isSelected: selected == options[i].value,
                  onPressed: () => onChanged(options[i].value),
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── Survey list ─────────────────────────────────────────────────────────────
class _SurveyList extends StatelessWidget {
  final List<Map<String, dynamic>> surveys;
  final bool wideMode;

  const _SurveyList({required this.surveys, this.wideMode = false});

  @override
  Widget build(BuildContext context) {
    if (wideMode) {
      // Grid of 2 columns on wide screens
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 480,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.4,
        ),
        itemCount: surveys.length,
        itemBuilder: (context, index) => _SurveyCard(survey: surveys[index]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surveys.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SurveyCard(survey: surveys[index]),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────
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

// ─── Filter button ────────────────────────────────────────────────────────────
class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color color;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : LightModeColors.lightOutline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? color : LightModeColors.lightOnSurface,
          ),
        ),
      ),
    );
  }
}

// ─── Stat card ───────────────────────────────────────────────────────────────
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

// ─── Survey card ─────────────────────────────────────────────────────────────
class _SurveyCard extends StatelessWidget {
  final Map<String, dynamic> survey;

  const _SurveyCard({required this.survey});

  // ── Helpers ──
  Color get _surveyColor {
    return (survey['survey_type'] as int? ?? 1) == 1
        ? LightModeColors.lightPrimary
        : LightModeColors.lightTertiary;
  }

  String get _surveyTypeName {
    return (survey['survey_type'] as int? ?? 1) == 1 ? 'BDI-II' : 'BAI';
  }

  int get _score {
    final responses = survey['responses'] as List?;
    if (responses == null || responses.isEmpty) return 0;
    return responses.fold<int>(0, (s, r) => s + (r['answer_value'] as int? ?? 0));
  }

  String _level(int score, int type) {
    if (type == 1) {
      if (score <= 13) return 'Mínima';
      if (score <= 19) return 'Leve';
      if (score <= 28) return 'Moderada';
      return 'Grave';
    }
    if (score <= 7)  return 'Mínima';
    if (score <= 15) return 'Leve';
    if (score <= 25) return 'Moderada';
    return 'Severa';
  }

  Color _levelColor(int score, int type) {
    if (type == 1) {
      if (score <= 13) return LightModeColors.lightTertiary;
      if (score <= 19) return const Color(0xFFFFA726);
      if (score <= 28) return const Color(0xFFFF7043);
      return LightModeColors.lightError;
    }
    if (score <= 7)  return LightModeColors.lightTertiary;
    if (score <= 15) return const Color(0xFFFFA726);
    if (score <= 25) return const Color(0xFFFF7043);
    return LightModeColors.lightError;
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
    final isComplete   = totalResp >= 21;
    final surveyType   = survey['survey_type'] as int? ?? 1;
    final score        = _score;
    final level        = _level(score, surveyType);
    final levelColor   = _levelColor(score, surveyType);
    final surveyColor  = _surveyColor;

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
            // ── Header row ──────────────────
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

            // ── Footer row ──────────────────
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
                Text(isComplete ? 'Completa' : '$totalResp/21 respuestas').small().muted(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small reusable badge widgets ────────────────────────────────────────────
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

