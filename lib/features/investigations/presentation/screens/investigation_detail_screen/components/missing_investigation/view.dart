import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MissingInvestigationView extends StatelessWidget {
  final int id;

  const MissingInvestigationView({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              material.Icons.science_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(12),
            Text('No se encontro la investigacion $id').semiBold(),
            const Gap(6),
            const Text('Actualiza el listado e intenta nuevamente.').small().muted(),
            const Gap(12),
            OutlineButton(
              onPressed: () => context.go('/investigations'),
              child: const Text('Volver al listado'),
            ),
          ],
        ),
      ),
    );
  }
}

