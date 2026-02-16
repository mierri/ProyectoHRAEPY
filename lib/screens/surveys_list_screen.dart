import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';

class SurveysListScreen extends StatefulWidget {
  const SurveysListScreen({super.key});

  @override
  State<SurveysListScreen> createState() => _SurveysListScreenState();
}

class _SurveysListScreenState extends State<SurveysListScreen> {
  bool _isLoading = true;
  String _filterType = 'all'; // 'all', 'bdi', 'bai'
  String _filterStatus = 'all'; // 'all', 'synced', 'pending'

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

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredSurveys(List<Map<String, dynamic>> surveys) {
    var filtered = surveys;

    // Filtrar por tipo
    if (_filterType == 'bdi') {
      filtered = filtered.where((s) => (s['survey_type'] ?? 1) == 1).toList();
    } else if (_filterType == 'bai') {
      filtered = filtered.where((s) => (s['survey_type'] ?? 1) == 2).toList();
    }

    // Filtrar por estado de sincronización
    if (_filterStatus == 'synced') {
      filtered = filtered.where((s) => s['synced'] == true).toList();
    } else if (_filterStatus == 'pending') {
      filtered = filtered.where((s) => s['synced'] != true).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final surveys = _getFilteredSurveys(surveyService.surveys);
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
          : Column(
              children: [
                // Estadísticas generales
                _buildStatisticsSection(stats),
                const Divider(height: 1),

                // Filtros
                _buildFiltersSection(),
                const Divider(height: 1),

                // Lista de encuestas
                Expanded(
                  child: surveys.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: surveys.length,
                          itemBuilder: (context, index) {
                            final survey = surveys[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _SurveyCard(survey: survey),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatisticsSection(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estadísticas Generales').medium(),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: material.Icons.assignment,
                  label: 'Total',
                  value: '${stats['total']}',
                  color: LightModeColors.lightPrimary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _StatCard(
                  icon: material.Icons.cloud_done,
                  label: 'Sincronizadas',
                  value: '${stats['synced']}',
                  color: LightModeColors.lightTertiary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _StatCard(
                  icon: material.Icons.cloud_upload,
                  label: 'Pendientes',
                  value: '${stats['pending']}',
                  color: LightModeColors.lightSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros').small().muted(),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tipo').small(),
                    const Gap(4),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterButton(
                            label: 'Todas',
                            isSelected: _filterType == 'all',
                            onPressed: () => setState(() => _filterType = 'all'),
                            color: LightModeColors.lightPrimary,
                          ),
                        ),
                        const Gap(4),
                        Expanded(
                          child: _FilterButton(
                            label: 'BDI',
                            isSelected: _filterType == 'bdi',
                            onPressed: () => setState(() => _filterType = 'bdi'),
                            color: LightModeColors.lightPrimary,
                          ),
                        ),
                        const Gap(4),
                        Expanded(
                          child: _FilterButton(
                            label: 'BAI',
                            isSelected: _filterType == 'bai',
                            onPressed: () => setState(() => _filterType = 'bai'),
                            color: LightModeColors.lightPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado').small(),
                    const Gap(4),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterButton(
                            label: 'Todas',
                            isSelected: _filterStatus == 'all',
                            onPressed: () => setState(() => _filterStatus = 'all'),
                            color: LightModeColors.lightTertiary,
                          ),
                        ),
                        const Gap(4),
                        Expanded(
                          child: _FilterButton(
                            label: 'Sincronizadas',
                            isSelected: _filterStatus == 'synced',
                            onPressed: () => setState(() => _filterStatus = 'synced'),
                            color: LightModeColors.lightTertiary,
                          ),
                        ),
                        const Gap(4),
                        Expanded(
                          child: _FilterButton(
                            label: 'Pendientes',
                            isSelected: _filterStatus == 'pending',
                            onPressed: () => setState(() => _filterStatus = 'pending'),
                            color: LightModeColors.lightTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            material.Icons.inbox_outlined,
            size: 64,
            color: LightModeColors.lightOutline,
          ),
          const Gap(16),
          const Text('No hay encuestas').muted(),
          const Gap(8),
          const Text('Las encuestas aplicadas aparecerán aquí').small().muted(),
        ],
      ),
    );
  }
}

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
      child: Container(
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
      padding: const EdgeInsets.all(12),
      backgroundColor: color.withValues(alpha: 0.05),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const Gap(8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Gap(4),
          Text(label).small().muted().textCenter(),
        ],
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  final Map<String, dynamic> survey;

  const _SurveyCard({required this.survey});

  Color _getSurveyColor() {
    final surveyType = survey['survey_type'] as int? ?? 1;
    switch (surveyType) {
      case 1:
        return LightModeColors.lightPrimary;
      case 2:
        return LightModeColors.lightTertiary;
      default:
        return LightModeColors.lightSecondary;
    }
  }

  String _getSurveyTypeName() {
    final surveyType = survey['survey_type'] as int? ?? 1;
    switch (surveyType) {
      case 1:
        return 'BDI-II';
      case 2:
        return 'BAI';
      default:
        return 'Encuesta #$surveyType';
    }
  }

  int _calculateScore() {
    final responses = survey['responses'] as List?;
    if (responses == null || responses.isEmpty) return 0;

    return responses.fold<int>(0, (sum, response) {
      final answerValue = response['answer_value'] as int? ?? 0;
      return sum + answerValue;
    });
  }

  String _getScoreLevel(int score, int surveyType) {
    if (surveyType == 1) {
      // BDI-II
      if (score <= 13) return 'Mínima';
      if (score <= 19) return 'Leve';
      if (score <= 28) return 'Moderada';
      return 'Grave';
    } else if (surveyType == 2) {
      // BAI
      if (score <= 7) return 'Mínima';
      if (score <= 15) return 'Leve';
      if (score <= 25) return 'Moderada';
      return 'Severa';
    }
    return 'N/A';
  }

  Color _getScoreLevelColor(int score, int surveyType) {
    if (surveyType == 1) {
      // BDI-II
      if (score <= 13) return LightModeColors.lightTertiary;
      if (score <= 19) return const Color(0xFFFFA726); // Naranja
      if (score <= 28) return const Color(0xFFFF7043); // Naranja oscuro
      return LightModeColors.lightError;
    } else if (surveyType == 2) {
      // BAI
      if (score <= 7) return LightModeColors.lightTertiary;
      if (score <= 15) return const Color(0xFFFFA726);
      if (score <= 25) return const Color(0xFFFF7043);
      return LightModeColors.lightError;
    }
    return LightModeColors.lightSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final patientService = context.watch<PatientService>();
    final patientId = survey['patient_id'] as int?;

    String patientName = 'Sin paciente';
    if (patientId != null) {
      try {
        final patient = patientService.patients.firstWhere(
          (p) => p.patientId == patientId,
        );
        patientName = patient.name;
      } catch (e) {
        patientName = 'Paciente no encontrado';
      }
    }

    final createdAt = DateTime.parse(survey['created_at']);
    final isSynced = survey['synced'] == true;
    final responses = survey['responses'] as List?;
    final totalResponses = responses?.length ?? 0;
    final score = _calculateScore();
    final surveyColor = _getSurveyColor();
    final surveyType = survey['survey_type'] as int? ?? 1;
    final scoreLevel = _getScoreLevel(score, surveyType);
    final scoreLevelColor = _getScoreLevelColor(score, surveyType);
    final isComplete = totalResponses >= 21;

    return GestureDetector(
      onTap: isComplete
          ? () {
              // TODO: Navigate to results screen
              showToast(
                context: context,
                builder: (context, overlay) => SurfaceCard(
                  child: Basic(
                    title: const Text('Resultados'),
                    subtitle: Text('Score: $score - $scoreLevel'),
                    leading: Icon(
                      material.Icons.analytics,
                      color: scoreLevelColor,
                    ),
                  ),
                ),
                location: ToastLocation.bottomCenter,
              );
            }
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
                  child: Icon(
                    material.Icons.assignment,
                    color: surveyColor,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_getSurveyTypeName()).semiBold(),
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSynced
                                  ? LightModeColors.lightTertiary.withValues(alpha: 0.1)
                                  : LightModeColors.lightSecondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isSynced
                                      ? material.Icons.cloud_done
                                      : material.Icons.cloud_upload,
                                  size: 12,
                                  color: isSynced
                                      ? LightModeColors.lightTertiary
                                      : LightModeColors.lightSecondary,
                                ),
                                const Gap(4),
                                Text(
                                  isSynced ? 'Sincronizadas' : 'Pendientes',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSynced
                                        ? LightModeColors.lightTertiary
                                        : LightModeColors.lightSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(patientName).small().muted(),
                    ],
                  ),
                ),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scoreLevelColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: scoreLevelColor,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$score',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: scoreLevelColor,
                          ),
                        ),
                        Text(
                          scoreLevel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: scoreLevelColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Gap(12),
            const Divider(height: 1),
            const Gap(12),
            Row(
              children: [
                Icon(
                  material.Icons.calendar_today,
                  size: 14,
                  color: LightModeColors.lightOnSurfaceVariant,
                ),
                const Gap(6),
                Text(
                  DateFormat('dd/MMM/yyyy HH:mm').format(createdAt),
                ).small().muted(),
                const Spacer(),
                Icon(
                  isComplete ? material.Icons.check_circle : material.Icons.hourglass_empty,
                  size: 14,
                  color: isComplete
                      ? LightModeColors.lightTertiary
                      : LightModeColors.lightOnSurfaceVariant,
                ),
                const Gap(6),
                Text(
                  isComplete
                      ? 'Completa'
                      : '$totalResponses/21 respuestas',
                ).small().muted(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

