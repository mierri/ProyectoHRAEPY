import 'package:shadcn_flutter/shadcn_flutter.dart';

class KpiCard extends StatelessWidget {
  final String label;
  final String value;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      child: SurfaceCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label).small().muted(),
              const Gap(4),
              Text(value).semiBold().large(),
            ],
          ),
        ),
      ),
    );
  }
}

