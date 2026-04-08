import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ssapp/shared/utils/theme.dart';

// page de marcador de posición para funcionalidades no implementadas
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.message = 'Esta funcionalidad estará disponible próximamente',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: context.textStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: context.textStyles.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
