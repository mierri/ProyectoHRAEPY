import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../components/welcome_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-sincronizar al cargar el dashboard
    _autoSync();
  }

  Future<void> _autoSync() async {
    // Esperar un momento para que la UI cargue
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    try {
      final patientService = context.read<PatientService>();
      final surveyService = context.read<SurveyService>();

      // Intentar sincronizar en segundo plano (sin bloquear UI)
      final syncedPatients = await patientService.syncPendingPatients();
      final syncedSurveys = await surveyService.syncPendingSurveys();

      // Solo mostrar toast si se sincronizó algo
      if ((syncedPatients > 0 || syncedSurveys > 0) && mounted) {
        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Sincronización automática'),
              subtitle: Text('$syncedPatients pacientes y $syncedSurveys encuestas sincronizadas'),
              leading: Icon(
                material.Icons.cloud_done,
                color: LightModeColors.lightTertiary,
              ),
              trailingAlignment: Alignment.center,
            ),
          ),
          location: ToastLocation.topCenter,
        );
      }
    } catch (e) {
      print('Auto-sync falló (probablemente sin internet): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.digital_wellbeing_rounded,
                color: LightModeColors.lightPrimary,
              ),
              const Gap(8),
              const Text('Sistema de Evaluación').medium(),
            ],
          ),
          trailing: [
            OutlineButton(
              density: ButtonDensity.icon,
              onPressed: () {
                context.push('/settings');
              },
              child: const Icon(material.Icons.settings),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WelcomeCard(
              userName: 'Evaluador',
              subtitle: 'Sistema de aplicación de encuestas y visualización de resultados',
            ),
            const Gap(24),
            const Text('Acciones rápidas').textLarge().bold(),
            const Gap(16),
            const QuickActionsGrid(),
            const Gap(32),
            const StatisticsSection(),
          ],
        ),
      ),
    );
  }
}

/// Grid of quick action cards
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionCardData(
        icon: material.Icons.add_circle_outline,
        title: 'Nueva Encuesta',
        description: 'Aplicar encuesta a paciente',
        color: LightModeColors.lightPrimary,
        onTap: () => context.push('/new-survey'),
      ),
      _ActionCardData(
        icon: material.Icons.list_alt,
        title: 'Ver Encuestas',
        description: 'Historial completo',
        color: LightModeColors.lightSecondary,
        onTap: () => context.push('/surveys'),
      ),
      _ActionCardData(
        icon: material.Icons.analytics_outlined,
        title: 'Reportes',
        description: 'Estadísticas y análisis',
        color: LightModeColors.lightTertiary,
        onTap: () => context.push('/reports'),
      ),
      _ActionCardData(
        icon: material.Icons.people_outline,
        title: 'Pacientes',
        description: 'Gestionar pacientes',
        color: LightModeColors.lightSecondary,
        onTap: () => context.push('/patients'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _ActionCard(data: actions[index]),
    );
  }
}

class _ActionCardData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  _ActionCardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _ActionCardData data;

  const _ActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: data.color.withValues(alpha: 0.6),
            width: 2.0,
          ),
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  data.icon,
                  size: 48,
                  color: data.color,
                ),
                const Gap(8),
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                ).semiBold(),
                const Gap(4),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).small().muted(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Statistics section showing survey and patient statistics
class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final surveyService = context.watch<SurveyService>();
    final patientService = context.watch<PatientService>();
    final stats = surveyService.getStatistics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estadísticas generales').textLarge().bold(),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: material.Icons.cloud_done,
                value: '${stats['synced']}',
                label: 'Sincronizadas',
                color: const Color(0xFF43A047), // green.shade600
              ),
            ),
            const Gap(16),
            Expanded(
              child: _StatCard(
                icon: material.Icons.people,
                value: '${patientService.patients.length}',
                label: 'Pacientes',
                color: LightModeColors.lightPrimary,
              ),
            ),
          ],
        ),
        const Gap(16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: material.Icons.cloud_upload,
                value: '${stats['pending']}',
                label: 'Pendientes',
                color: const Color(0xFFFB8C00), // orange.shade600
              ),
            ),
            const Gap(16),
            Expanded(
              child: _StatCard(
                icon: material.Icons.assessment,
                value: '${stats['total']}',
                label: 'Total Encuestas',
                color: LightModeColors.lightSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const Gap(8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label).small().muted(),
        ],
      ),
    );
  }
}



