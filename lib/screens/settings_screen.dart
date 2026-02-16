import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/Services/patient_service.dart';
import 'package:ssapp/Services/survey_service.dart';
import 'package:ssapp/utils/theme.dart';

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
      final surveyService = context.read<SurveyService>();

      // Sincronizar pacientes pendientes
      final syncedPatients = await patientService.syncPendingPatients();

      // Sincronizar encuestas pendientes
      final syncedSurveys = await surveyService.syncPendingSurveys();

      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading

        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Sincronización completada'),
              subtitle: Text('$syncedPatients pacientes y $syncedSurveys encuestas sincronizadas'),
              leading: Icon(
                material.Icons.cloud_done,
                color: LightModeColors.lightPrimary,
              ),
              trailingAlignment: Alignment.center,
            ),
          ),
          location: ToastLocation.bottomCenter,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar loading

        showToast(
          context: context,
          builder: (context, overlay) => SurfaceCard(
            child: Basic(
              title: const Text('Error al sincronizar'),
              subtitle: Text(e.toString()),
              leading: Icon(
                material.Icons.cloud_off,
                color: LightModeColors.lightError,
              ),
              trailingAlignment: Alignment.center,
            ),
          ),
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
          showToast(
            context: context,
            builder: (context, overlay) => SurfaceCard(
              child: Basic(
                title: const Text('Datos eliminados'),
                subtitle: const Text('Los datos locales han sido eliminados exitosamente'),
                leading: Icon(
                  material.Icons.check_circle,
                  color: LightModeColors.lightPrimary,
                ),
                trailingAlignment: Alignment.center,
              ),
            ),
            location: ToastLocation.bottomCenter,
          );

          // Regresar al inicio
          context.go('/');
        }
      } catch (e) {
        if (context.mounted) {
          showToast(
            context: context,
            builder: (context, overlay) => SurfaceCard(
              child: Basic(
                title: const Text('Error'),
                subtitle: Text(e.toString()),
                leading: Icon(
                  material.Icons.error_outline,
                  color: LightModeColors.lightError,
                ),
                trailingAlignment: Alignment.center,
              ),
            ),
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

