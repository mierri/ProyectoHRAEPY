import 'dart:convert';
import 'dart:typed_data';

import 'package:ssapp/features/reports/domain/perceived_attendance_barriers_report_support.dart';
import 'package:ssapp/features/reports/domain/specialty_consultation_attendance_report_support.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/surveys/domain/survey_rules.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class SurveyCsvExporter {
  Future<Uint8List> export(
    int surveyType,
    List<Map<String, dynamic>> surveys, {
    CustomSurveyDefinition? customDefinition,
    List<PatientModel>? patients,
  }) async {
    final rows = <List<String>>[];
    if (surveyType == 100 && customDefinition != null) {
      rows.add([
        'survey_id',
        'patient_id',
        'created_at',
        'score',
        'level',
        ...customDefinition.questions.map((q) => q.label),
        'synced',
      ]);
      for (final survey in surveys) {
        final score = survey['score'] as int? ?? SurveyStatsCalculator.calculateSurveyScore(survey);
        final responses = (survey['responses'] as List?) ?? const [];
        final answerByQuestion = <int, dynamic>{};
        for (final r in responses) {
          final qId = r['question_id'] as int?;
          if (qId != null) answerByQuestion[qId] = r;
        }
        rows.add([
          '${survey['survey_id'] ?? ''}',
          '${survey['patient_id'] ?? ''}',
          '${survey['created_at'] ?? ''}',
          '$score',
          '${survey['risk_level'] ?? ''}',
          ...customDefinition.questions.map((q) {
            final r = answerByQuestion[q.fieldId];
            final answerValue = r?['answer_value'] as int?;
            final matchingOptions = q.options.where((o) => o.value == answerValue);
            return matchingOptions.isNotEmpty
                ? matchingOptions.first.label
                : (r?['answer_text'] as String? ?? '');
          }),
          '${survey['synced'] == true}',
        ]);
      }
      return Uint8List.fromList(utf8.encode(rows.map((r) => r.map(_escape).join(',')).join('\n')));
    }
    switch (surveyType) {
      case 1:
      case 2:
      case 4:
      case 6:
      case 7:
      case 8:
      case 10:
      case 11:
      case 12:
      case 13:
      case 19:
      case 20:
        rows.add([
          'survey_id',
          'patient_id',
          'created_at',
          'score',
          'level',
          'responses_count',
          'synced',
        ]);
        for (final survey in surveys) {
          final score = SurveyStatsCalculator.calculateSurveyScore(survey);
          rows.add([
            '${survey['survey_id'] ?? ''}',
            '${survey['patient_id'] ?? ''}',
            '${survey['created_at'] ?? ''}',
            '$score',
            _levelFor(surveyType, score),
            '${(survey['responses'] as List?)?.length ?? 0}',
            '${survey['synced'] == true}',
          ]);
        }
        break;
      case 3:
        rows.add([
          'survey_id',
          'patient_id',
          'created_at',
          'global_adjusted_score',
          'q1',
          'q2',
          'domain1',
          'domain2',
          'domain3',
          'domain4',
          'synced',
        ]);
        for (final survey in surveys) {
          final whoqol = _whoqolMetrics(survey);
          rows.add([
            '${survey['survey_id'] ?? ''}',
            '${survey['patient_id'] ?? ''}',
            '${survey['created_at'] ?? ''}',
            '${whoqol['global_adjusted_score'] ?? 0}',
            '${whoqol['q1'] ?? ''}',
            '${whoqol['q2'] ?? ''}',
            '${whoqol['domain1'] ?? ''}',
            '${whoqol['domain2'] ?? ''}',
            '${whoqol['domain3'] ?? ''}',
            '${whoqol['domain4'] ?? ''}',
            '${survey['synced'] == true}',
          ]);
        }
        break;
      case 5:
        rows.add([
          'survey_id',
          'patient_id',
          'created_at',
          'sf36_global_0_100',
          'physical_functioning',
          'role_physical',
          'bodily_pain',
          'general_health',
          'vitality',
          'social_functioning',
          'role_emotional',
          'mental_health',
          'synced',
        ]);
        for (final survey in surveys) {
          final sf36 = _sf36Metrics(survey);
          rows.add([
            '${survey['survey_id'] ?? ''}',
            '${survey['patient_id'] ?? ''}',
            '${survey['created_at'] ?? ''}',
            (_fmt(sf36['global'])),
            (_fmt(sf36['pf'])),
            (_fmt(sf36['rp'])),
            (_fmt(sf36['bp'])),
            (_fmt(sf36['gh'])),
            (_fmt(sf36['vt'])),
            (_fmt(sf36['sf'])),
            (_fmt(sf36['re'])),
            (_fmt(sf36['mh'])),
            '${survey['synced'] == true}',
          ]);
        }
        break;
      case 9:
        rows.add([
          'survey_id',
          'patient_id',
          'created_at',
          'score',
          'risk_level',
          'altura_m',
          'peso_kg',
          'imc',
          'responses_count',
          'synced',
        ]);
        final patientsById = <int, PatientModel>{
          for (final p in patients ?? const <PatientModel>[]) p.patientId: p,
        };
        for (final survey in surveys) {
          final score = survey['score'] as int? ?? SurveyRules.calculateScore(survey);
          final patientId = survey['patient_id'] as int?;
          final patient = patientId != null ? patientsById[patientId] : null;
          final height = patient?.height;
          final weight = patient?.weight;
          final imc = patient?.imc ??
              ((height != null && weight != null && height > 0)
                  ? weight / (height * height)
                  : null);
          rows.add([
            '${survey['survey_id'] ?? ''}',
            '${survey['patient_id'] ?? ''}',
            '${survey['created_at'] ?? ''}',
            '$score',
            '${survey['risk_level'] ?? ''}',
            height != null ? height.toStringAsFixed(2) : '',
            weight != null ? weight.toStringAsFixed(1) : '',
            imc != null ? imc.toStringAsFixed(1) : '',
            '${(survey['responses'] as List?)?.length ?? 0}',
            '${survey['synced'] == true}',
          ]);
        }
        break;
      case 16:
        rows.add([
          'survey_id',
          'patient_id',
          'created_at',
          'nombre_completo',
          'numero_expediente',
          'fecha_nacimiento',
          'localidad_residencia',
          'transporte_privado',
          'especialidad',
          'falto_cita',
          'citas_perdidas',
          'synced',
        ]);
        for (final survey in surveys) {
          final record =
              SpecialtyConsultationAttendanceRecord.fromSurvey(survey);
          rows.add([
            record.surveyId,
            record.patientId,
            record.createdAt,
            record.nombreCompleto,
            record.numeroExpediente,
            record.fechaNacimiento,
            record.localidadResidencia,
            record.transportePrivadoLabel,
            record.especialidad,
            record.faltoCitaLabel,
            record.citasPerdidasLabel,
            '${survey['synced'] == true}',
          ]);
        }
        break;
      case 17:
        rows.add([
          'survey_id',
          'patient_id',
          'created_at',
          'motivo_reciente',
          'motivo_futuro_1',
          'motivo_futuro_2',
          'motivo_futuro_3',
          'synced',
        ]);
        for (final survey in surveys) {
          final record = PerceivedAttendanceBarriersRecord.fromSurvey(survey);
          rows.add([
            record.surveyId,
            record.patientId,
            record.createdAt,
            record.recentReason?.resolvedLabel ?? '',
            record.primaryFutureReason?.resolvedLabel ?? '',
            record.secondaryFutureReason?.resolvedLabel ?? '',
            record.tertiaryFutureReason?.resolvedLabel ?? '',
            '${survey['synced'] == true}',
          ]);
        }
        break;
      default:
        rows.add(['survey_id', 'patient_id', 'created_at', 'score', 'responses_count', 'synced']);
        for (final survey in surveys) {
          final score = SurveyRules.calculateScore(survey);
          rows.add([
            '${survey['survey_id'] ?? ''}',
            '${survey['patient_id'] ?? ''}',
            '${survey['created_at'] ?? ''}',
            '$score',
            '${(survey['responses'] as List?)?.length ?? 0}',
            '${survey['synced'] == true}',
          ]);
        }
        break;
    }

    final csv = rows.map((r) => r.map(_escape).join(',')).join('\n');
    return Uint8List.fromList(utf8.encode(csv));
  }

  String _escape(String input) {
    final escaped = input.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _levelFor(int surveyType, int score) {
    return switch (surveyType) {
      1 => SurveyStatsCalculator.bdiLevel(score),
      2 => SurveyStatsCalculator.baiLevel(score),
      6 => SurveyStatsCalculator.assistLevel(score),
      7 => SurveyStatsCalculator.gdsLevel(score),
      8 => SurveyStatsCalculator.lawtonLevel(score),
      10 => SurveyStatsCalculator.katzLevel(score),
      11 => SurveyStatsCalculator.iciqsfLevel(score),
      12 => SurveyStatsCalculator.ghq12Level(score),
      13 => SurveyStatsCalculator.phq9Level(score),
      18 => score >= 26 ? 'Normal' : 'Interpretacion clinica',
      19 => score >= 19 ? 'Normal' : 'Bajo esperado',
      20 => switch (score) {
          >= 158 => 'Excelente',
          >= 130 => 'Bueno',
          >= 111 => 'Regular',
          >= 74 => 'Deficiente',
          _ => 'Muy deficiente',
        },
      _ => 'N/A',
    };
  }

  Map<String, dynamic> _whoqolMetrics(Map<String, dynamic> survey) {
    final responses = (survey['responses'] as List?) ?? const [];
    final map = <int, int>{};
    for (final item in responses) {
      final q = item['question_id'] as int?;
      final v = item['answer_value'] as int?;
      if (q != null && v != null) {
        map[q] = v;
      }
    }

    int domainSum(List<int> qIds) {
      var sum = 0;
      for (final q in qIds) {
        final v = map[q];
        if (v == null) {
          return 0;
        }
        sum += v;
      }
      return sum;
    }

    final global = SurveyRules.calculateScore(survey);
    return {
      'global_adjusted_score': global,
      'q1': map[1],
      'q2': map[2],
      'domain1': domainSum(const [3, 4, 10, 15, 16, 17, 18]),
      'domain2': domainSum(const [5, 6, 7, 11, 19, 26]),
      'domain3': domainSum(const [20, 21, 22]),
      'domain4': domainSum(const [8, 9, 12, 13, 14, 23, 24, 25]),
    };
  }

  Map<String, double> _sf36Metrics(Map<String, dynamic> survey) {
    final responses = (survey['responses'] as List?) ?? const [];
    final r = <int, int>{};
    for (final item in responses) {
      final q = item['question_id'] as int?;
      final v = item['answer_value'] as int?;
      if (q != null && v != null) {
        r[q] = v;
      }
    }

    int inv(int value, int max) => (max + 1 - value).clamp(1, max);
    int sumInv(List<int> ids, int max) =>
        ids.fold<int>(0, (acc, id) => acc + inv(r[id] ?? 1, max));

    final pf = (sumInv(const [3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 3) - 10) / 20 * 100;
    final rp = (sumInv(const [13, 14, 15, 16], 2) - 4) / 4 * 100;

    final q21 = r[21] ?? 1;
    final q22 = r[22] ?? 1;
    final bpRaw = inv(q21, 6) + (q21 == 1 ? 6 : (6 - q22).clamp(1, 6));
    final bp = (bpRaw - 2) / 10 * 100;

    final ghRaw =
        (r[1] ?? 1) + inv(r[25] ?? 1, 5) + inv(r[26] ?? 1, 5) + inv(r[27] ?? 1, 5) + inv(r[28] ?? 1, 5);
    final gh = (ghRaw - 5) / 20 * 100;

    final vtRaw = inv(r[23] ?? 1, 6) + inv(r[27] ?? 1, 6) + (r[29] ?? 1) + (r[31] ?? 1);
    final vt = (vtRaw - 4) / 20 * 100;

    final sfRaw = inv(r[20] ?? 1, 5) + (r[32] ?? 1);
    final sf = (sfRaw - 2) / 8 * 100;

    final reRaw = inv(r[17] ?? 1, 2) + inv(r[18] ?? 1, 2) + inv(r[19] ?? 1, 2);
    final re = (reRaw - 3) / 3 * 100;

    final mhRaw = inv(r[24] ?? 1, 6) + inv(r[25] ?? 1, 6) + inv(r[26] ?? 1, 6) + inv(r[28] ?? 1, 6) + (r[30] ?? 1);
    final mh = (mhRaw - 5) / 25 * 100;

    final global = (pf + rp + bp + gh + vt + sf + re + mh) / 8;

    return {
      'global': global.clamp(0, 100),
      'pf': pf.clamp(0, 100),
      'rp': rp.clamp(0, 100),
      'bp': bp.clamp(0, 100),
      'gh': gh.clamp(0, 100),
      'vt': vt.clamp(0, 100),
      'sf': sf.clamp(0, 100),
      're': re.clamp(0, 100),
      'mh': mh.clamp(0, 100),
    };
  }

  String _fmt(dynamic value) {
    if (value is num) {
      return value.toStringAsFixed(1);
    }
    return '$value';
  }
}
