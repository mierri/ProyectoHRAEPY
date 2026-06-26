import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_fields.dart';

class PerceivedAttendanceBarrierReason {
  final int value;
  final String label;
  final String freeText;

  const PerceivedAttendanceBarrierReason({
    required this.value,
    required this.label,
    required this.freeText,
  });

  String get resolvedLabel {
    if (value == PerceivedAttendanceBarriersChoices.otroMotivoValue &&
        freeText.isNotEmpty) {
      return freeText;
    }
    return label;
  }
}

class PerceivedAttendanceBarriersRecord {
  final String surveyId;
  final String patientId;
  final String createdAt;
  final DateTime? createdAtDate;
  final PerceivedAttendanceBarrierReason? recentReason;
  final PerceivedAttendanceBarrierReason? primaryFutureReason;
  final PerceivedAttendanceBarrierReason? secondaryFutureReason;
  final PerceivedAttendanceBarrierReason? tertiaryFutureReason;

  const PerceivedAttendanceBarriersRecord({
    required this.surveyId,
    required this.patientId,
    required this.createdAt,
    required this.createdAtDate,
    required this.recentReason,
    required this.primaryFutureReason,
    required this.secondaryFutureReason,
    required this.tertiaryFutureReason,
  });

  bool get hasAntecedentSection => recentReason != null;

  factory PerceivedAttendanceBarriersRecord.fromSurvey(
    Map<String, dynamic> survey,
  ) {
    final responses = <int, Map<String, dynamic>>{};
    for (final item in (survey['responses'] as List? ?? const [])) {
      if (item is Map<String, dynamic>) {
        final questionId = item['question_id'] as int?;
        if (questionId != null) {
          responses[questionId] = item;
        }
      }
    }

    String readText(int fieldId) {
      final answerText = responses[fieldId]?['answer_text'];
      return answerText is String ? answerText.trim() : '';
    }

    int? readInt(int fieldId) {
      final value = responses[fieldId]?['answer_value'];
      return value is int ? value : int.tryParse('$value');
    }

    PerceivedAttendanceBarrierReason? readReason(
      int choiceFieldId,
      int otherFieldId,
    ) {
      final value = readInt(choiceFieldId);
      if (value == null) {
        return null;
      }
      final option = PerceivedAttendanceBarriersChoices.motivos
          .where((choice) => choice.value == value)
          .toList();
      final label = option.isEmpty ? '$value' : option.first.label;
      return PerceivedAttendanceBarrierReason(
        value: value,
        label: label,
        freeText: readText(otherFieldId),
      );
    }

    final createdAt = '${survey['created_at'] ?? ''}';

    return PerceivedAttendanceBarriersRecord(
      surveyId: '${survey['survey_id'] ?? ''}',
      patientId: '${survey['patient_id'] ?? ''}',
      createdAt: createdAt,
      createdAtDate: DateTime.tryParse(createdAt),
      recentReason: readReason(
        PerceivedAttendanceBarriersFieldIds.motivoReciente,
        PerceivedAttendanceBarriersFieldIds.motivoRecienteOtro,
      ),
      primaryFutureReason: readReason(
        PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipal,
        PerceivedAttendanceBarriersFieldIds.motivoFuturoPrincipalOtro,
      ),
      secondaryFutureReason: readReason(
        PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundario,
        PerceivedAttendanceBarriersFieldIds.motivoFuturoSecundarioOtro,
      ),
      tertiaryFutureReason: readReason(
        PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciario,
        PerceivedAttendanceBarriersFieldIds.motivoFuturoTerciarioOtro,
      ),
    );
  }
}

class PerceivedAttendanceBarriersReportSummary {
  final List<PerceivedAttendanceBarriersRecord> records;
  final Map<String, int> recentReasonCounts;
  final Map<String, int> primaryFutureReasonCounts;
  final Map<String, int> allFutureReasonCounts;
  final Map<String, int> rankOneToThreeCounts;
  final DateTime? latestSurveyDate;

  const PerceivedAttendanceBarriersReportSummary({
    required this.records,
    required this.recentReasonCounts,
    required this.primaryFutureReasonCounts,
    required this.allFutureReasonCounts,
    required this.rankOneToThreeCounts,
    required this.latestSurveyDate,
  });

  int get total => records.length;

  int get withAntecedentSection =>
      records.where((record) => record.hasAntecedentSection).length;

  double get antecedentSectionPercentage =>
      total == 0 ? 0 : withAntecedentSection / total * 100;

  String get topPrimaryReason => _topLabel(primaryFutureReasonCounts);

  String get topOverallFutureReason => _topLabel(allFutureReasonCounts);

  static String _topLabel(Map<String, int> counts) {
    if (counts.isEmpty) {
      return '—';
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return a.key.compareTo(b.key);
      });
    return sorted.first.key;
  }

  static PerceivedAttendanceBarriersReportSummary fromSurveys(
    List<Map<String, dynamic>> surveys,
  ) {
    final records = surveys
        .map(PerceivedAttendanceBarriersRecord.fromSurvey)
        .toList();
    final recentReasonCounts = <String, int>{};
    final primaryFutureReasonCounts = <String, int>{};
    final allFutureReasonCounts = <String, int>{};
    final rankOneToThreeCounts = <String, int>{
      'Motivo 1': 0,
      'Motivo 2': 0,
      'Motivo 3': 0,
    };
    DateTime? latestSurveyDate;

    void addCount(Map<String, int> counts, String label) {
      if (label.isEmpty) {
        return;
      }
      counts.update(label, (current) => current + 1, ifAbsent: () => 1);
    }

    for (final record in records) {
      if (record.recentReason != null) {
        addCount(recentReasonCounts, record.recentReason!.resolvedLabel);
      }
      if (record.primaryFutureReason != null) {
        addCount(
          primaryFutureReasonCounts,
          record.primaryFutureReason!.resolvedLabel,
        );
        rankOneToThreeCounts['Motivo 1'] =
            (rankOneToThreeCounts['Motivo 1'] ?? 0) + 1;
      }
      if (record.secondaryFutureReason != null) {
        rankOneToThreeCounts['Motivo 2'] =
            (rankOneToThreeCounts['Motivo 2'] ?? 0) + 1;
      }
      if (record.tertiaryFutureReason != null) {
        rankOneToThreeCounts['Motivo 3'] =
            (rankOneToThreeCounts['Motivo 3'] ?? 0) + 1;
      }

      for (final reason in [
        record.primaryFutureReason,
        record.secondaryFutureReason,
        record.tertiaryFutureReason,
      ]) {
        if (reason != null) {
          addCount(allFutureReasonCounts, reason.resolvedLabel);
        }
      }

      final createdAtDate = record.createdAtDate;
      if (createdAtDate != null &&
          (latestSurveyDate == null || createdAtDate.isAfter(latestSurveyDate))) {
        latestSurveyDate = createdAtDate;
      }
    }

    return PerceivedAttendanceBarriersReportSummary(
      records: records,
      recentReasonCounts: recentReasonCounts,
      primaryFutureReasonCounts: primaryFutureReasonCounts,
      allFutureReasonCounts: allFutureReasonCounts,
      rankOneToThreeCounts: rankOneToThreeCounts,
      latestSurveyDate: latestSurveyDate,
    );
  }
}
