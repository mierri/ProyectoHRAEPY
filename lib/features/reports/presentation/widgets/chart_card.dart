import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Wraps a chart in a titled card with a [RepaintBoundary] keyed by [boundaryKey].
/// The PDF generator uses that key to capture the chart as a PNG image.
///
/// Charts se revelan de forma escalonada (150 ms entre cada uno) para no
/// saturar la GPU de la tablet con múltiples renders simultáneos.
class ChartCard extends StatefulWidget {
  final String title;
  final Widget chart;
  final GlobalKey boundaryKey;
  final double height;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    required this.boundaryKey,
    this.height = 260,
  });

  // ── Cola estática de carga escalonada ────────────────────────────────────────
  static final List<_ChartCardState> _queue = [];
  static bool _draining = false;

  static void _enqueue(_ChartCardState state) {
    _queue.add(state);
    if (!_draining) _drain();
  }

  static void _remove(_ChartCardState state) {
    _queue.remove(state);
  }

  static Future<void> _drain() async {
    _draining = true;
    while (_queue.isNotEmpty) {
      final s = _queue.removeAt(0);
      if (s.mounted) {
        s._reveal();
        await Future<void>.delayed(const Duration(milliseconds: 150));
      }
    }
    _draining = false;
  }

  @override
  State<ChartCard> createState() => _ChartCardState();
}

class _ChartCardState extends State<ChartCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    ChartCard._enqueue(this);
  }

  @override
  void dispose() {
    ChartCard._remove(this);
    super.dispose();
  }

  void _reveal() {
    if (mounted) setState(() => _visible = true);
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedContainer(
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Gap(12),
          RepaintBoundary(
            key: widget.boundaryKey,
            child: SizedBox(
              height: widget.height,
              child: _visible ? widget.chart : const _ChartSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder mientras el chart espera su turno en la cola de carga.
class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.muted.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
