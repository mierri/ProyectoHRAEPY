import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/services/sync_service.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';
import 'package:ssapp/features/surveys/data/survey_repository.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';
import 'package:ssapp/shared/widgets/components/welcome_card.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

// Responsabilidad: renderizar el dashboard principal y disparar sincronización automática al iniciar.
// ─── Breakpoints ─────────────────────────────────────────────────────────────
class _BP {
  static const double tablet  = 600;
  static const double desktop = 900;
  /// Max content width on very wide screens
  static const double maxContent = 1100;
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _autoSync();
  }

  Future<void> _autoSync() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    try {
      final patientService = context.read<PatientService>();
      final surveyService = context.read<SurveyService>();

      await Future.wait([
        patientService.loadPatients(),
        surveyService.loadSurveys(),
      ]);

      if (!mounted) return;

      final syncService = SyncService(
        patientService: patientService,
        surveyRepository: SurveyRepository(),
      );
      final result = await syncService.syncPendingOnly();
      final syncedPatients = result.patientsSynced;
      final syncedSurveys = result.surveysSynced;
      if ((syncedPatients > 0 || syncedSurveys > 0) && mounted) {
        showCenteredToast(
          context,
          title: 'Sincronización automática',
          subtitle: '$syncedPatients pacientes y $syncedSurveys encuestas sincronizadas',
          icon: material.Icons.cloud_done,
          iconColor: LightModeColors.lightTertiary,
          location: ToastLocation.topCenter,
        );
      }
    } catch (e) {
      // Sin conexión — silencioso
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= _BP.tablet;
    final isDesktop = width >= _BP.desktop;
    final hPad = isDesktop
        ? ((width - _BP.maxContent) / 2).clamp(24.0, 120.0)
        : 16.0;

    return Scaffold(
      headers: [
        AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.digital_wellbeing_rounded, color: LightModeColors.lightPrimary),
              const Gap(8),
              const Text('Sistema de Evaluación').medium(),
            ],
          ),
          trailing: [
            OutlineButton(
              density: ButtonDensity.icon,
              onPressed: () => context.push('/settings'),
              child: const Icon(material.Icons.settings),
            ),
          ],
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeCard(
                  userName: 'Evaluador',
                  subtitle: 'Sistema de aplicación de encuestas y visualización de resultados',
                  wide: isTablet,
                ),
                const Gap(28),
                const Text('Acciones rápidas').textLarge().bold(),
                const Gap(16),
                const QuickActionsGrid(),
                const Gap(32),
                StatisticsSection(isTablet: isTablet),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Quick actions grid ───────────────────────────────────────────────────────
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        icon: material.Icons.add_circle_outline,
        title: 'Nueva Encuesta',
        description: 'Aplicar encuesta a paciente',
        color: LightModeColors.lightPrimary,
        onTap: () => context.push('/new-survey'),
      ),
      _ActionData(
        icon: material.Icons.list_alt,
        title: 'Ver Encuestas',
        description: 'Historial completo',
        color: LightModeColors.lightSecondary,
        onTap: () => context.push('/surveys'),
      ),
      _ActionData(
        icon: material.Icons.analytics_outlined,
        title: 'Reportes',
        description: 'Estadísticas y análisis',
        color: LightModeColors.lightTertiary,
        onTap: () => context.push('/reports'),
      ),
      _ActionData(
        icon: material.Icons.people_outline,
        title: 'Pacientes',
        description: 'Gestionar pacientes',
        color: LightModeColors.lightSecondary,
        onTap: () => context.push('/patients'),
      ),
      _ActionData(
        icon: material.Icons.query_stats,
        title: 'Investigaciones',
        description: 'Acceso a investigaciones relacionadas',
        color: LightModeColors.lightPrimary,
        onTap: () => context.push('/investigations'),
      ),
      _ActionData(
        icon: material.Icons.edit_note,
        title: 'Crear Encuestas',
        description: 'Diseña tus propias encuestas',
        color: LightModeColors.lightTertiary,
        onTap: () => context.push('/survey-builder'),
      ),
    ];

    // Desktop: 4 en fila | Mobile/Tablet: 2 en fila.
    // Permite que algunas tarjetas ocupen más columnas en pantallas compactas.
    // Mantiene 2 columnas consistentes para distribuir las 6 acciones en 3 filas.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }
        const cols = 2;
        const spacing = 16.0;
        final cardWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;

        final rows = <List<_ActionCell>>[];
        var currentRow = <_ActionCell>[];
        var usedCols = 0;

        for (final action in actions) {
          final span = action.mobileSpan.clamp(1, cols);

          if (usedCols + span > cols) {
            rows.add(currentRow);
            currentRow = <_ActionCell>[];
            usedCols = 0;
          }

          currentRow.add(_ActionCell(data: action, span: span));
          usedCols += span;

          if (usedCols == cols) {
            rows.add(currentRow);
            currentRow = <_ActionCell>[];
            usedCols = 0;
          }
        }

        if (currentRow.isNotEmpty) {
          rows.add(currentRow);
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: spacing),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < row.length; i++) ...[
                    if (i > 0) const SizedBox(width: spacing),
                    SizedBox(
                      width: cardWidth * row[i].span + spacing * (row[i].span - 1),
                      child: _ActionCard(data: row[i].data),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ActionData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final int mobileSpan;

  const _ActionData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
    this.mobileSpan = 1,
  });
}

class _ActionCell {
  final _ActionData data;
  final int span;

  const _ActionCell({required this.data, required this.span});
}

class _ActionCard extends StatelessWidget {
  final _ActionData data;
  const _ActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: data.color.withValues(alpha: 0.6), width: 2.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(data.icon, size: 40, color: data.color),
            const Gap(10),
            Text(
              data.title,
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.visible,
              ),
            ),
            const Gap(4),
            Text(
              data.description,
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.mutedForeground,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Statistics section ───────────────────────────────────────────────────────
class StatisticsSection extends StatelessWidget {
  final bool isTablet;
  const StatisticsSection({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    // Suscripción estrecha: solo reconstruye cuando cambian los valores concretos,
    // no en cualquier notifyListeners() de los servicios.
    final stats = context.select<SurveyService, Map<String, dynamic>>(
      (s) => s.getStatistics(),
    );
    final patientCount = context.select<PatientService, int>(
      (p) => p.patients.length,
    );

    final items = [
      _StatData(material.Icons.cloud_done,  '${stats['synced']}',  'Sincronizadas',  const Color(0xFF43A047)),
      _StatData(material.Icons.people,      '$patientCount',        'Pacientes',      LightModeColors.lightPrimary),
      _StatData(material.Icons.cloud_upload,'${stats['pending']}',  'Pendientes',     const Color(0xFFFB8C00)),
      _StatData(material.Icons.assessment,  '${stats['total']}',    'Total Encuestas',LightModeColors.lightSecondary),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estadísticas generales').textLarge().bold(),
        const Gap(16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 0) {
              return const SizedBox.shrink();
            }
            final cols    = isTablet ? 4 : 2;
            const spacing = 14.0;
            final cardWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;

            final rows = <List<_StatData>>[];
            for (int i = 0; i < items.length; i += cols) {
              rows.add(items.sublist(i, (i + cols).clamp(0, items.length)));
            }

            return Column(
              children: rows.map((row) => Padding(
                padding: const EdgeInsets.only(bottom: spacing),
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < row.length; i++) ...[
                          if (i > 0) const SizedBox(width: spacing),
                          SizedBox(width: cardWidth, child: _StatCard(data: row[i])),
                        ],
                      ],
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StatData {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatData(this.icon, this.value, this.label, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data.color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: data.color, size: 30),
          const Gap(8),
          Text(
            data.value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: data.color),
          ),
          const Gap(2),
          Text(
            data.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).small().muted(),
        ],
      ),
    );
  }
}

