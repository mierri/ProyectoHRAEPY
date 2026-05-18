import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';

void showSurveyFormSavingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const Gap(16),
            const Text(
              'Guardando encuesta...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

void showSurveyFormCompletionDialog(
  BuildContext context, {
  required bool wasSynced,
  required VoidCallback onContinue,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: LightModeColors.lightPrimary,
                    size: 28,
                  ),
                  const Gap(12),
                  const Expanded(
                    child: Text(
                      'Encuesta guardada',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              _SyncStatusBadge(wasSynced: wasSynced),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onContinue();
                  },
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SyncStatusBadge extends StatelessWidget {
  final bool wasSynced;
  const _SyncStatusBadge({required this.wasSynced});

  @override
  Widget build(BuildContext context) {
    final color = wasSynced
        ? LightModeColors.lightTertiary
        : LightModeColors.lightSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            wasSynced ? Icons.cloud_done : Icons.cloud_upload,
            color: color,
            size: 20,
          ),
          const Gap(10),
          Expanded(
            child: Text(
              wasSynced
                  ? 'Datos sincronizados correctamente.'
                  : 'Encuesta pendiente de sincronización.',
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
