import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ApplyInvestigationHeader extends StatelessWidget {
  final String investigationTitle;

  const ApplyInvestigationHeader({
    super.key,
    required this.investigationTitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aplicar encuestas').small().muted(),
          Text(investigationTitle, maxLines: 1, overflow: TextOverflow.ellipsis).semiBold(),
        ],
      ),
      leading: [
        IconButton(
          icon: const Icon(material.Icons.arrow_back),
          variance: ButtonVariance.ghost,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}

