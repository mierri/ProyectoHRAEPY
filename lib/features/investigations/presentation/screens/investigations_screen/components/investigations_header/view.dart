import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class InvestigationsHeader extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;

  const InvestigationsHeader({
    super.key,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Investigaciones'),
      leading: [
        IconButton(
          icon: const Icon(material.Icons.arrow_back),
          variance: ButtonVariance.ghost,
          onPressed: () => context.go('/'),
        ),
      ],
      trailing: [
        IconButton(
          icon: const Icon(material.Icons.refresh),
          variance: ButtonVariance.ghost,
          onPressed: isLoading ? null : onRefresh,
        ),
      ],
    );
  }
}

