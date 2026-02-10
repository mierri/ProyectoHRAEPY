import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ssapp/components/action_card.dart';
import 'package:ssapp/components/stat_card.dart';
import 'package:ssapp/components/welcome_card.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.health_and_safety_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('HRAEPY - Sistema de Evaluación'),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeCard(
                userName: 'Evaluador',
                subtitle: 'Sistema de aplicación de encuestas y visualización de resultados',
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Acciones rápidas',
                style: context.textStyles.titleLarge?.bold,
              ),
              SizedBox(height: AppSpacing.md),
              const QuickActionsGrid(),
              SizedBox(height: AppSpacing.xl),
              const StatisticsSection(),
            ],
          ),
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
      ActionCard(
        icon: Icons.add_circle_outline,
        title: 'Nueva Encuesta',
        description: 'Aplicar encuesta a paciente',
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.push('/new-survey'),
      ),
      ActionCard(
        icon: Icons.list_alt,
        title: 'Ver Encuestas',
        description: 'Historial completo',
        color: Theme.of(context).colorScheme.secondary,
        onTap: () => context.push('/surveys'),
      ),
      ActionCard(
        icon: Icons.analytics_outlined,
        title: 'Reportes',
        description: 'Estadísticas y análisis',
        color: Theme.of(context).colorScheme.tertiary,
        onTap: () => context.push('/reports'),
      ),
      ActionCard(
        icon: Icons.people_outline,
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
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => actions[index],
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
        Text(
          'Estadísticas generales',
          style: context.textStyles.titleLarge?.bold,
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.assignment_turned_in,
                value: '${stats['completed']}',
                label: 'Sincronizadas',
                color: Colors.green.shade600,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                icon: Icons.people,
                value: '${patientService.patients.length}',
                label: 'Pacientes',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.pending_actions,
                value: '${stats['incomplete']}',
                label: 'Pendientes',
                color: Colors.orange.shade600,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                icon: Icons.assessment,
                value: '${stats['total']}',
                label: 'Total',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}



