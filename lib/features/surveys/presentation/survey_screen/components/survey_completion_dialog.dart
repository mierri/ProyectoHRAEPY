import 'package:flutter/material.dart' as material show Icons;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/shared/utils/theme.dart';
import 'package:ssapp/shared/widgets/lumi/lumi_widget.dart';

/// Dialog content shown after a survey is saved successfully.
class SurveyCompletionDialogContent extends StatelessWidget {
  final bool wasSynced;
  final VoidCallback onNo;
  final VoidCallback onYes;

  const SurveyCompletionDialogContent({
    super.key,
    required this.wasSynced,
    required this.onNo,
    required this.onYes,
  });

  @override
  Widget build(BuildContext context) {
    final syncColor = wasSynced ? LightModeColors.lightTertiary : LightModeColors.lightSecondary;
    final syncIcon  = wasSynced ? material.Icons.cloud_done : material.Icons.cloud_upload;
    final syncLabel = wasSynced ? 'Datos sincronizados' : 'Pendiente de sincronización';

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: LumiWidget(
                variant: LumiVariant.caring,
                size: 100,
                message: '¡Muchas gracias\npor participar!',
                bubbleColor: const Color(0xFFFFE8F0),
              ),
            ),
            const Gap(20),
            const Text('La encuesta ha sido completada exitosamente.', style: TextStyle(fontSize: 15)),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: syncColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: syncColor),
              ),
              child: Row(children: [
                Icon(syncIcon, color: syncColor),
                const Gap(12),
                Expanded(child: Text(syncLabel, style: TextStyle(fontSize: 13, color: syncColor))),
              ]),
            ),
            const Gap(20),
            const Text('¿Desea ver su resultado?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Gap(20),
            Row(children: [
              Expanded(child: OutlineButton(onPressed: onNo, child: const Text('No'))),
              const Gap(12),
              Expanded(child: PrimaryButton(onPressed: onYes, child: const Text('Sí'))),
            ]),
          ]),
        ),
      ),
    );
  }
}
