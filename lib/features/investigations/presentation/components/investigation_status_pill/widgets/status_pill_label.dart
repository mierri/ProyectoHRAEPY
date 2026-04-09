import 'package:shadcn_flutter/shadcn_flutter.dart';

class StatusPillLabel extends StatelessWidget {
  final String text;
  final Color foreground;

  const StatusPillLabel({
    super.key,
    required this.text,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
    );
  }
}

