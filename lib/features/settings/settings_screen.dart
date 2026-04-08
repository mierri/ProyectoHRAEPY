import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/patients/data/patient_repository.dart';
import 'package:ssapp/shared/services/sync_service.dart';
import 'package:ssapp/features/surveys/data/survey_repository.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/utils/toast_helper.dart';

// Responsabilidad: mostrar opciones de configuración y acciones operativas del sistema.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _syncPendingData(BuildContext context) async {
    if (!context.mounted) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final patientService = context.read<PatientService>();
      final syncService = SyncService(
        patientService: patientService,
        surveyRepository: SurveyRepository(),
      );
      final result = await syncService.syncPendingOnly();
      final syncedPatients = result.patientsSynced;
      final syncedSurveys = result.surveysSynced;

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading

        showCenteredToast(
          context,
          title: 'Sincronización completada',
          subtitle: '$syncedPatients pacientes y $syncedSurveys encuestas sincronizadas',
          icon: material.Icons.cloud_done,
          iconColor: LightModeColors.lightPrimary,
          location: ToastLocation.bottomCenter,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading

        showCenteredToast(
          context,
          title: 'Error al sincronizar',
          subtitle: e.toString(),
          icon: material.Icons.cloud_off,
          iconColor: LightModeColors.lightError,
          location: ToastLocation.bottomCenter,
        );
      }
    }
  }

  Future<void> _clearLocalData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text(
          '¿Está seguro de que desea eliminar todos los datos locales?\n\n'
          'Esto eliminará todas las encuestas que no se hayan sincronizado con el servidor.',
        ),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          PrimaryButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Cerrar todas las cajas abiertas
        await Hive.close();

        // Eliminar las cajas
        await Hive.deleteBoxFromDisk('surveys');
        await Hive.deleteBoxFromDisk('patients');

        if (context.mounted) {
          showCenteredToast(
            context,
            title: 'Datos eliminados',
            subtitle: 'Los datos locales han sido eliminados exitosamente',
            icon: material.Icons.check_circle,
            iconColor: LightModeColors.lightPrimary,
            location: ToastLocation.bottomCenter,
          );

          // Regresar al inicio
          context.go('/');
        }
      } catch (e) {
        if (context.mounted) {
          showCenteredToast(
            context,
            title: 'Error',
            subtitle: e.toString(),
            icon: material.Icons.error_outline,
            iconColor: LightModeColors.lightError,
            location: ToastLocation.bottomCenter,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: const Text('Configuración'),
          leading: [
            IconButton(
              icon: const Icon(material.Icons.arrow_back),
              onPressed: () => context.pop(),
              variance: ButtonVariance.ghost,
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sincronización').textLarge().bold(),
            const Gap(16),
            OutlinedContainer(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        material.Icons.cloud_sync,
                        color: LightModeColors.lightPrimary,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text('Sincronizar datos pendientes').semiBold(),
                      ),
                    ],
                  ),
                  const Gap(8),
                  const Text(
                    'Sincroniza pacientes y encuestas que se crearon sin conexión a internet.',
                  ).small().muted(),
                  const Gap(16),
                  PrimaryButton(
                    onPressed: () => _syncPendingData(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          material.Icons.cloud_upload,
                          color: Colors.white,
                          size: 20,
                        ),
                        const Gap(8),
                        const Text('Sincronizar ahora'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(32),
            const Text('Datos Locales').textLarge().bold(),
            const Gap(16),
            OutlinedContainer(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        material.Icons.storage,
                        color: LightModeColors.lightPrimary,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text('Limpiar datos locales').semiBold(),
                      ),
                    ],
                  ),
                  const Gap(8),
                  const Text(
                    'Elimina todas las encuestas y datos almacenados localmente. '
                    'Solo las encuestas sincronizadas permanecerán en el servidor.',
                  ).small().muted(),
                  const Gap(16),
                  OutlineButton(
                    onPressed: () => _clearLocalData(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          material.Icons.delete_outline,
                          color: LightModeColors.lightError,
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          'Limpiar datos',
                          style: TextStyle(
                            color: LightModeColors.lightError,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(32),
            const Text('Información').textLarge().bold(),
            const Gap(16),
            OutlinedContainer(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Versión', '1.0.0'),
                  const Gap(12),
                  const Divider(height: 1),
                  const Gap(12),
                  _buildInfoRow('Base de datos', 'Supabase'),
                  const Gap(12),
                  const Divider(height: 1),
                  const Gap(12),
                  _buildInfoRow('Almacenamiento local', 'Hive'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label).small().muted(),
        Text(value).small(),
      ],
    );
  }
}

