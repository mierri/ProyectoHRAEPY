import 'package:shadcn_flutter/shadcn_flutter.dart';

class ResultsCounter extends StatelessWidget {
  final int count;

  const ResultsCounter({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.muted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$count').small().semiBold(),
    );
  }
}

