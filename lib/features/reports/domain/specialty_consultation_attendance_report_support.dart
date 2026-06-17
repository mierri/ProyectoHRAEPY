import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_fields.dart';

class SpecialtyConsultationAttendanceRecord {
  final String surveyId;
  final String patientId;
  final String createdAt;
  final DateTime? createdAtDate;
  final String nombreCompleto;
  final String numeroExpediente;
  final String fechaNacimiento;
  final String localidadResidencia;
  final bool? transportePrivado;
  final String transportePrivadoLabel;
  final String especialidad;
  final bool? faltoCita;
  final String faltoCitaLabel;
  final String citasPerdidasLabel;

  const SpecialtyConsultationAttendanceRecord({
    required this.surveyId,
    required this.patientId,
    required this.createdAt,
    required this.createdAtDate,
    required this.nombreCompleto,
    required this.numeroExpediente,
    required this.fechaNacimiento,
    required this.localidadResidencia,
    required this.transportePrivado,
    required this.transportePrivadoLabel,
    required this.especialidad,
    required this.faltoCita,
    required this.faltoCitaLabel,
    required this.citasPerdidasLabel,
  });

  factory SpecialtyConsultationAttendanceRecord.fromSurvey(
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
      final response = responses[fieldId];
      final answerText = response?['answer_text'];
      if (answerText is String) {
        return answerText.trim();
      }
      final answerValue = response?['answer_value'];
      if (answerValue == null) {
        return '';
      }
      return '$answerValue'.trim();
    }

    int? readInt(int fieldId) {
      final value = responses[fieldId]?['answer_value'];
      return value is int ? value : int.tryParse('$value');
    }

    String labelForChoice(List<dynamic> choices, int? value) {
      if (value == null) {
        return '';
      }
      for (final choice in choices) {
        if (choice.value == value) {
          return choice.label;
        }
      }
      return '$value';
    }

    final transporteValue = readInt(
      SpecialtyConsultationAttendanceFieldIds.transportePrivado,
    );
    final especialidadValue = readInt(
      SpecialtyConsultationAttendanceFieldIds.especialidad,
    );
    final faltoCitaValue = readInt(
      SpecialtyConsultationAttendanceFieldIds.faltoCita,
    );
    final citasPerdidasValue = readInt(
      SpecialtyConsultationAttendanceFieldIds.citasPerdidas,
    );
    final especialidadOtra = readText(
      SpecialtyConsultationAttendanceFieldIds.especialidadOtra,
    );

    final especialidadLabel = labelForChoice(
      SpecialtyConsultationAttendanceChoices.especialidades,
      especialidadValue,
    );
    final especialidad = especialidadLabel == 'Otra' && especialidadOtra.isNotEmpty
        ? especialidadOtra
        : especialidadLabel;

    final createdAt = '${survey['created_at'] ?? ''}';

    return SpecialtyConsultationAttendanceRecord(
      surveyId: '${survey['survey_id'] ?? ''}',
      patientId: '${survey['patient_id'] ?? ''}',
      createdAt: createdAt,
      createdAtDate: DateTime.tryParse(createdAt),
      nombreCompleto: readText(
        SpecialtyConsultationAttendanceFieldIds.nombreCompleto,
      ),
      numeroExpediente: readText(
        SpecialtyConsultationAttendanceFieldIds.numeroExpediente,
      ),
      fechaNacimiento: readText(
        SpecialtyConsultationAttendanceFieldIds.fechaNacimiento,
      ),
      localidadResidencia: readText(
        SpecialtyConsultationAttendanceFieldIds.localidadResidencia,
      ),
      transportePrivado: transporteValue == null ? null : transporteValue == 0,
      transportePrivadoLabel: labelForChoice(
        SpecialtyConsultationAttendanceChoices.siNo,
        transporteValue,
      ),
      especialidad: especialidad,
      faltoCita: faltoCitaValue == null ? null : faltoCitaValue == 0,
      faltoCitaLabel: labelForChoice(
        SpecialtyConsultationAttendanceChoices.siNo,
        faltoCitaValue,
      ),
      citasPerdidasLabel: labelForChoice(
        SpecialtyConsultationAttendanceChoices.citasPerdidas,
        citasPerdidasValue,
      ),
    );
  }
}

class SpecialtyConsultationAttendanceReportSummary {
  final List<SpecialtyConsultationAttendanceRecord> records;
  final int total;
  final int withPrivateTransport;
  final int withoutPrivateTransport;
  final int missedAppointmentYes;
  final int missedAppointmentNo;
  final Map<String, int> specialtyCounts;
  final Map<String, int> missedCountDistribution;
  final String mostCommonSpecialty;
  final DateTime? latestSurveyDate;

  const SpecialtyConsultationAttendanceReportSummary({
    required this.records,
    required this.total,
    required this.withPrivateTransport,
    required this.withoutPrivateTransport,
    required this.missedAppointmentYes,
    required this.missedAppointmentNo,
    required this.specialtyCounts,
    required this.missedCountDistribution,
    required this.mostCommonSpecialty,
    required this.latestSurveyDate,
  });

  double get privateTransportPercentage =>
      total == 0 ? 0 : withPrivateTransport / total * 100;

  double get missedAppointmentPercentage =>
      total == 0 ? 0 : missedAppointmentYes / total * 100;

  static SpecialtyConsultationAttendanceReportSummary fromSurveys(
    List<Map<String, dynamic>> surveys,
  ) {
    final records = surveys
        .map(SpecialtyConsultationAttendanceRecord.fromSurvey)
        .toList();

    var withPrivateTransport = 0;
    var withoutPrivateTransport = 0;
    var missedAppointmentYes = 0;
    var missedAppointmentNo = 0;
    final specialtyCounts = <String, int>{};
    final missedCountDistribution = <String, int>{};
    DateTime? latestSurveyDate;

    for (final record in records) {
      if (record.transportePrivado == true) {
        withPrivateTransport++;
      } else if (record.transportePrivado == false) {
        withoutPrivateTransport++;
      }

      if (record.faltoCita == true) {
        missedAppointmentYes++;
      } else if (record.faltoCita == false) {
        missedAppointmentNo++;
      }

      if (record.especialidad.isNotEmpty) {
        specialtyCounts.update(
          record.especialidad,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      if (record.citasPerdidasLabel.isNotEmpty) {
        missedCountDistribution.update(
          record.citasPerdidasLabel,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      final createdAtDate = record.createdAtDate;
      if (createdAtDate != null &&
          (latestSurveyDate == null || createdAtDate.isAfter(latestSurveyDate))) {
        latestSurveyDate = createdAtDate;
      }
    }

    String mostCommonSpecialty = '—';
    if (specialtyCounts.isNotEmpty) {
      final sorted = specialtyCounts.entries.toList()
        ..sort((a, b) {
          final countCompare = b.value.compareTo(a.value);
          if (countCompare != 0) {
            return countCompare;
          }
          return a.key.compareTo(b.key);
        });
      mostCommonSpecialty = sorted.first.key;
    }

    return SpecialtyConsultationAttendanceReportSummary(
      records: records,
      total: records.length,
      withPrivateTransport: withPrivateTransport,
      withoutPrivateTransport: withoutPrivateTransport,
      missedAppointmentYes: missedAppointmentYes,
      missedAppointmentNo: missedAppointmentNo,
      specialtyCounts: specialtyCounts,
      missedCountDistribution: missedCountDistribution,
      mostCommonSpecialty: mostCommonSpecialty,
      latestSurveyDate: latestSurveyDate,
    );
  }
}
