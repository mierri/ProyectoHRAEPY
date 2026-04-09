import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/investigation_status_pill/widgets/widgets.dart';

enum InvestigationUiStatus { active, draft, completed, paused }

class InvestigationStatusStyle {
  final String label;
  final Color foreground;
  final Color background;

  const InvestigationStatusStyle({
    required this.label,
    required this.foreground,
    required this.background,
  });
}

InvestigationUiStatus resolveInvestigationStatus(InvestigationModel investigation) {
  if (investigation.surveyTypeIds.isEmpty) return InvestigationUiStatus.draft;
  if (investigation.participantIds.isEmpty) return InvestigationUiStatus.paused;

  final daysSinceCreated = DateTime.now().difference(investigation.createdAt).inDays;
  if (daysSinceCreated > 120) return InvestigationUiStatus.completed;

  return InvestigationUiStatus.active;
}

InvestigationStatusStyle investigationStatusStyle(InvestigationUiStatus status) {
  switch (status) {
    case InvestigationUiStatus.active:
      return const InvestigationStatusStyle(
        label: 'Activa',
        foreground: Color(0xFF059669),
        background: Color(0xFFECFDF5),
      );
    case InvestigationUiStatus.draft:
      return const InvestigationStatusStyle(
        label: 'Borrador',
        foreground: Color(0xFF6B7280),
        background: Color(0xFFF3F4F6),
      );
    case InvestigationUiStatus.completed:
      return const InvestigationStatusStyle(
        label: 'Completada',
        foreground: Color(0xFF4F46E5),
        background: Color(0xFFEEF2FF),
      );
    case InvestigationUiStatus.paused:
      return const InvestigationStatusStyle(
        label: 'Pausada',
        foreground: Color(0xFFD97706),
        background: Color(0xFFFFFBEB),
      );
  }
}

class InvestigationStatusPill extends StatelessWidget {
  final InvestigationUiStatus status;

  const InvestigationStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = investigationStatusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: StatusPillLabel(text: style.label, foreground: style.foreground),
    );
  }
}

