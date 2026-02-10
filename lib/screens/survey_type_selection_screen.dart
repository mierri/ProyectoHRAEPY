import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssapp/utils/theme.dart';

enum SurveyType {
  bai,
  bdi,
}

extension SurveyTypeExtension on SurveyType {
  String get code {
    switch (this) {
      case SurveyType.bai:
        return 'BAI';
      case SurveyType.bdi:
        return 'BDI-II';
    }
  }

  String get englishName {
    switch (this) {
      case SurveyType.bai:
        return 'Beck Anxiety Inventory';
      case SurveyType.bdi:
        return 'Beck Depression Inventory — Segunda Edición';
    }
  }

  String get spanishName {
    switch (this) {
      case SurveyType.bai:
        return 'Inventario de Ansiedad de Beck';
      case SurveyType.bdi:
        return 'Inventario de Depresión de Beck';
    }
  }

  IconData get icon {
    switch (this) {
      case SurveyType.bai:
        return Icons.psychology_outlined;
      case SurveyType.bdi:
        return Icons.favorite_outline;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case SurveyType.bai:
        return Theme.of(context).colorScheme.tertiary;
      case SurveyType.bdi:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

class SurveyTypeSelectionScreen extends StatelessWidget {
  const SurveyTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Tipo de Encuesta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipos de Encuestas Disponibles',
                style: context.textStyles.headlineSmall?.bold,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Selecciona el tipo de evaluación que deseas aplicar',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              ...SurveyType.values.map((type) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: SurveyTypeCard(
                  surveyType: type,
                  onTap: () => context.push('/consent-form?surveyType=${type.name}'),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class SurveyTypeCard extends StatelessWidget {
  final SurveyType surveyType;
  final VoidCallback onTap;

  const SurveyTypeCard({
    super.key,
    required this.surveyType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = surveyType.getColor(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  surveyType.icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surveyType.code,
                      style: context.textStyles.titleLarge?.bold.copyWith(
                        color: color,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      surveyType.englishName,
                      style: context.textStyles.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    surveyType.spanishName,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

