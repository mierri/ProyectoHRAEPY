import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class InvestigationDetailHeader extends StatelessWidget {
  final int investigationId;

  const InvestigationDetailHeader({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Investigacion #$investigationId'),
      leading: [
        IconButton(
          icon: const Icon(material.Icons.arrow_back),
          variance: ButtonVariance.ghost,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/investigations');
            }
          },
        ),
      ],
      trailing: [
        IconButton(
          icon: const Icon(material.Icons.edit),
          variance: ButtonVariance.ghost,
          onPressed: () => context.push('/investigations/$investigationId/edit'),
        ),
      ],
    );
  }
}

