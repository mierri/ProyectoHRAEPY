import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:ssapp/features/reports/domain/perceived_attendance_barriers_report_support.dart';
import 'package:ssapp/features/reports/domain/specialty_consultation_attendance_report_support.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/surveys/domain/survey_rules.dart';
import 'package:ssapp/features/surveys/shared/form/form_question.dart';
import 'package:ssapp/features/surveys/types/assist/domain/assist_questions.dart';
import 'package:ssapp/features/surveys/types/bdi/domain/bdi_questions.dart';
import 'package:ssapp/features/surveys/types/fantastic_mexa/domain/fantastic_mexa_questions.dart';
import 'package:ssapp/features/surveys/types/gds/domain/gds_questions.dart';
import 'package:ssapp/features/surveys/types/ghq12/domain/ghq12_questions.dart';
import 'package:ssapp/features/surveys/types/iciq_sf/domain/iciq_sf_questions.dart';
import 'package:ssapp/features/surveys/types/katz/domain/katz_questions.dart';
import 'package:ssapp/features/surveys/types/lawton/domain/lawton_questions.dart';
import 'package:ssapp/features/surveys/types/osteoporosis/domain/osteoporosis_questions.dart';
import 'package:ssapp/features/surveys/types/perceived_attendance_barriers/domain/perceived_attendance_barriers_questions.dart';
import 'package:ssapp/features/surveys/types/phq9/domain/phq9_questions.dart';
import 'package:ssapp/features/surveys/types/sf36/domain/sf36_questions.dart';
import 'package:ssapp/features/surveys/types/social_determinants/domain/social_determinants_questions.dart';
import 'package:ssapp/features/surveys/types/sociodemographic/domain/sociodemographic_questions.dart';
import 'package:ssapp/features/surveys/types/specialty_consultation_attendance/domain/specialty_consultation_attendance_questions.dart';
import 'package:ssapp/features/surveys/types/whoqol/domain/whoqol_questions.dart';
import 'package:ssapp/shared/models/patient_model.dart';

class SurveyExcelExporter {
  Future<Uint8List> export(
    int surveyType,
    List<Map<String, dynamic>> surveys, {
    CustomSurveyDefinition? customDefinition,
    List<PatientModel>? patients,
  }) async {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet();

    _writeRows(
      excel,
      'Datos originales',
      _originalRows(
        surveyType,
        surveys,
        customDefinition: customDefinition,
        patients: patients,
      ),
    );
    _writeRows(
      excel,
      'Respuestas por paciente',
      _patientResponseRows(
        surveyType,
        surveys,
        customDefinition: customDefinition,
      ),
    );
    _writeRows(
      excel,
      'Resumen por pregunta',
      _summaryRows(surveyType, surveys, customDefinition: customDefinition),
    );
    _writeRows(
      excel,
      'Diccionario preguntas',
      _dictionaryRows(surveyType, customDefinition: customDefinition),
    );

    if (defaultSheet != null && excel.sheets.length > 1) {
      excel.delete(defaultSheet);
    }

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? const <int>[]);
  }

  void _writeRows(Excel excel, String sheetName, List<List<dynamic>> rows) {
    final sheet = excel[sheetName];
    for (final row in rows) {
      sheet.appendRow(row.map(_cellValue).toList());
    }
  }

  CellValue _cellValue(dynamic value) {
    if (value is int) return IntCellValue(value);
    if (value is double) return DoubleCellValue(value);
    if (value is bool) return BoolCellValue(value);
    return TextCellValue(value?.toString() ?? '');
  }

  List<List<dynamic>> _originalRows(
    int surveyType,
    List<Map<String, dynamic>> surveys, {
    CustomSurveyDefinition? customDefinition,
    List<PatientModel>? patients,
  }) {
    final rows = <List<dynamic>>[];
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
        final score =
            survey['score'] as int? ??
            SurveyStatsCalculator.calculateSurveyScore(survey);
        final responses = (survey['responses'] as List?) ?? const [];
        final answerByQuestion = <int, dynamic>{};
        for (final r in responses) {
          final qId = r['question_id'] as int?;
          if (qId != null) answerByQuestion[qId] = r;
        }
        rows.add([
          survey['survey_id'] ?? '',
          survey['patient_id'] ?? '',
          survey['created_at'] ?? '',
          score,
          survey['risk_level'] ?? '',
          ...customDefinition.questions.map((q) {
            final r = answerByQuestion[q.fieldId];
            final answerValue = r?['answer_value'] as int?;
            final matchingOptions = q.options.where(
              (o) => o.value == answerValue,
            );
            return matchingOptions.isNotEmpty
                ? matchingOptions.first.label
                : (r?['answer_text'] as String? ?? '');
          }),
          survey['synced'] == true,
        ]);
      }
      return rows;
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
            survey['survey_id'] ?? '',
            survey['patient_id'] ?? '',
            survey['created_at'] ?? '',
            score,
            _levelFor(surveyType, score),
            (survey['responses'] as List?)?.length ?? 0,
            survey['synced'] == true,
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
            survey['survey_id'] ?? '',
            survey['patient_id'] ?? '',
            survey['created_at'] ?? '',
            whoqol['global_adjusted_score'] ?? 0,
            whoqol['q1'] ?? '',
            whoqol['q2'] ?? '',
            whoqol['domain1'] ?? '',
            whoqol['domain2'] ?? '',
            whoqol['domain3'] ?? '',
            whoqol['domain4'] ?? '',
            survey['synced'] == true,
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
            survey['survey_id'] ?? '',
            survey['patient_id'] ?? '',
            survey['created_at'] ?? '',
            _fmt(sf36['global']),
            _fmt(sf36['pf']),
            _fmt(sf36['rp']),
            _fmt(sf36['bp']),
            _fmt(sf36['gh']),
            _fmt(sf36['vt']),
            _fmt(sf36['sf']),
            _fmt(sf36['re']),
            _fmt(sf36['mh']),
            survey['synced'] == true,
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
          final score =
              survey['score'] as int? ?? SurveyRules.calculateScore(survey);
          final patientId = survey['patient_id'] as int?;
          final patient = patientId != null ? patientsById[patientId] : null;
          final height = patient?.height;
          final weight = patient?.weight;
          final imc =
              patient?.imc ??
              ((height != null && weight != null && height > 0)
                  ? weight / (height * height)
                  : null);
          rows.add([
            survey['survey_id'] ?? '',
            survey['patient_id'] ?? '',
            survey['created_at'] ?? '',
            score,
            survey['risk_level'] ?? '',
            height != null ? height.toStringAsFixed(2) : '',
            weight != null ? weight.toStringAsFixed(1) : '',
            imc != null ? imc.toStringAsFixed(1) : '',
            (survey['responses'] as List?)?.length ?? 0,
            survey['synced'] == true,
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
          final record = SpecialtyConsultationAttendanceRecord.fromSurvey(
            survey,
          );
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
            survey['synced'] == true,
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
            survey['synced'] == true,
          ]);
        }
        break;
      default:
        rows.add([
          'survey_id',
          'patient_id',
          'created_at',
          'score',
          'responses_count',
          'synced',
        ]);
        for (final survey in surveys) {
          final score = SurveyRules.calculateScore(survey);
          rows.add([
            survey['survey_id'] ?? '',
            survey['patient_id'] ?? '',
            survey['created_at'] ?? '',
            score,
            (survey['responses'] as List?)?.length ?? 0,
            survey['synced'] == true,
          ]);
        }
        break;
    }
    return rows;
  }

  List<List<dynamic>> _patientResponseRows(
    int surveyType,
    List<Map<String, dynamic>> surveys, {
    CustomSurveyDefinition? customDefinition,
  }) {
    final questions = _questionColumns(
      surveyType,
      customDefinition: customDefinition,
    );
    final rows = <List<dynamic>>[
      [
        'survey_id',
        'patient_id',
        'created_at',
        'score',
        ...questions.map((q) => q.header),
      ],
    ];

    for (final survey in surveys) {
      final answers = _answersByQuestion(survey);
      rows.add([
        survey['survey_id'] ?? '',
        survey['patient_id'] ?? '',
        survey['created_at'] ?? '',
        survey['score'] ?? SurveyRules.calculateScore(survey),
        ...questions.map((q) => _answerLabel(answers[q.id], q)),
      ]);
    }
    return rows;
  }

  List<List<dynamic>> _summaryRows(
    int surveyType,
    List<Map<String, dynamic>> surveys, {
    CustomSurveyDefinition? customDefinition,
  }) {
    final questions = _questionColumns(
      surveyType,
      customDefinition: customDefinition,
    );
    final counts = <int, Map<String, int>>{};

    for (final survey in surveys) {
      final answers = _answersByQuestion(survey);
      for (final question in questions) {
        final label = _answerLabel(answers[question.id], question);
        if (label.isEmpty) continue;
        counts.putIfAbsent(question.id, () => {});
        counts[question.id]![label] = (counts[question.id]![label] ?? 0) + 1;
      }
    }

    final rows = <List<dynamic>>[
      ['pregunta_id', 'pregunta', 'respuesta', 'cantidad'],
    ];
    for (final question in questions) {
      final questionCounts = counts[question.id] ?? const <String, int>{};
      if (questionCounts.isEmpty) {
        rows.add([question.id, question.label, 'Sin respuestas', 0]);
        continue;
      }
      final sortedEntries = questionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (var index = 0; index < sortedEntries.length; index++) {
        final entry = sortedEntries[index];
        rows.add([
          index == 0 ? question.id : '',
          index == 0 ? question.label : '',
          entry.key,
          entry.value,
        ]);
      }
    }
    return rows;
  }

  List<List<dynamic>> _dictionaryRows(
    int surveyType, {
    CustomSurveyDefinition? customDefinition,
  }) {
    final questions = _questionColumns(
      surveyType,
      customDefinition: customDefinition,
    );
    return [
      ['columna', 'pregunta_id', 'pregunta', 'opciones'],
      for (final question in questions)
        [
          question.header,
          question.id,
          question.label,
          question.options.entries
              .map((entry) => '${entry.key}: ${entry.value}')
              .join(' | '),
        ],
    ];
  }

  Map<int, dynamic> _answersByQuestion(Map<String, dynamic> survey) {
    final responses = (survey['responses'] as List?) ?? const [];
    final answers = <int, dynamic>{};
    for (final response in responses) {
      final questionId = response['question_id'] as int?;
      if (questionId != null) answers[questionId] = response;
    }
    return answers;
  }

  String _answerLabel(dynamic response, _QuestionColumn question) {
    if (response == null) return '';
    final answerText = response['answer_text'] as String?;
    if (answerText != null && answerText.trim().isNotEmpty) {
      return answerText.trim();
    }

    final answerValue = response['answer_value'];
    if (answerValue == null) return '';
    final options = question.options;
    if (options.isNotEmpty && answerValue is int) {
      if (question.isMultiChoiceMask) {
        final labels = <String>[];
        for (final option in options.entries) {
          if ((answerValue & option.key) != 0) labels.add(option.value);
        }
        return labels.isEmpty ? '$answerValue' : labels.join('; ');
      }
      return options[answerValue] ?? '$answerValue';
    }
    return '$answerValue';
  }

  List<_QuestionColumn> _questionColumns(
    int surveyType, {
    CustomSurveyDefinition? customDefinition,
  }) {
    if (surveyType == 100 && customDefinition != null) {
      return customDefinition.questions
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => _QuestionColumn(
              entry.value.fieldId,
              entry.value.label,
              header: 'P${entry.key + 1}',
              options: {
                for (final option in entry.value.options)
                  option.value: option.label,
              },
            ),
          )
          .toList();
    }

    return switch (surveyType) {
      1 => _fromSurveyQuestions(BDIQuestions.questions),
      2 => _fromSurveyQuestions(BAIQuestions.questions),
      3 =>
        WhoqolQuestions.questions
            .map(
              (q) => _QuestionColumn(
                q.number,
                q.text,
                options: _indexedOptions(
                  WhoqolQuestions.labelsFor(q.scaleType),
                  startAt: 1,
                ),
              ),
            )
            .toList(),
      5 =>
        SF36Questions.questions
            .map(
              (q) => _QuestionColumn(
                q.number,
                q.text,
                options: _indexedOptions(q.options, startAt: 1),
              ),
            )
            .toList(),
      6 => _assistQuestionColumns(),
      7 => _fromSurveyQuestions(GDSQuestions.questions),
      8 => _fromSurveyQuestions(LawtonQuestions.questions),
      9 => _fromSurveyQuestions(OsteoporosisQuestions.questions),
      10 => _fromSurveyQuestions(KatzQuestions.questions),
      11 => _fromSurveyQuestions(
        IciqSfQuestions.questions,
        multiChoiceIds: const {4},
      ),
      12 => _fromSurveyQuestions(Ghq12Questions.questions),
      13 => _fromSurveyQuestions(Phq9Questions.questions),
      14 => _fromFormQuestions(sociodemographicQuestions),
      15 => _fromFormQuestions(socialDeterminantsQuestions),
      16 => _fromFormQuestions(specialtyConsultationAttendanceQuestions),
      17 => _fromFormQuestions(
        buildPerceivedAttendanceBarriersQuestions(
          includeAntecedentsSection: true,
        ),
      ),
      20 => [
        ..._fantasticGeneralColumns(),
        ..._fromSurveyQuestions(FantasticMexaQuestions.questions),
      ],
      _ => const <_QuestionColumn>[],
    };
  }

  List<_QuestionColumn> _fromSurveyQuestions(
    List<SurveyQuestion> questions, {
    Set<int> multiChoiceIds = const {},
  }) {
    return questions
        .map(
          (q) => _QuestionColumn(
            q.number,
            q.category,
            options: {
              for (final option in q.options)
                if (!q.options
                    .takeWhile((o) => o != option)
                    .any((o) => o.score == option.score))
                  option.score: option.text,
            },
            isMultiChoiceMask: multiChoiceIds.contains(q.number),
          ),
        )
        .toList();
  }

  List<_QuestionColumn> _fromFormQuestions(List<FormQuestion> questions) {
    final columns = <_QuestionColumn>[];
    for (final question in questions) {
      for (var index = 0; index < question.fields.length; index++) {
        final field = question.fields[index];
        columns.add(
          _QuestionColumn(
            field.fieldId,
            '${question.number}. ${question.label} - ${field.label}',
            header: question.fields.length == 1
                ? question.number
                : '${question.number}.${index + 1}',
            options: {
              for (final option in field.options) option.value: option.label,
            },
            isMultiChoiceMask: field.type == FormFieldType.multiChoice,
          ),
        );
      }
    }
    return columns;
  }

  List<_QuestionColumn> _assistQuestionColumns() {
    final columns = <_QuestionColumn>[];
    const questionTitles = {
      1: 'P1. Sustancia consumida alguna vez',
      2: 'P2. Frecuencia de consumo en los ultimos 3 meses',
      3: 'P3. Deseo o urgencia de consumir',
      4: 'P4. Problemas por consumo',
      5: 'P5. Dejo de hacer lo esperado por consumo',
      6: 'P6. Preocupacion de terceros',
      7: 'P7. Intento fallido de controlar o dejar consumo',
    };

    for (final substance in AssistQuestions.substances) {
      columns.add(
        _QuestionColumn(
          AssistQuestions.encodedQuestionId(
            questionNumber: 1,
            substanceId: substance.id,
          ),
          '${questionTitles[1]} - ${substance.label}',
          header: 'P1.${substance.id}',
          options: const {0: 'No', 1: 'Si'},
        ),
      );
    }
    for (final questionNumber in const [2, 3, 4, 5, 6, 7]) {
      final options = switch (questionNumber) {
        2 => _zipOptions(
          AssistQuestions.p2Scores,
          AssistQuestions.frequencyOptions,
        ),
        3 => _zipOptions(
          AssistQuestions.p3Scores,
          AssistQuestions.frequencyOptions,
        ),
        4 => _zipOptions(
          AssistQuestions.p4Scores,
          AssistQuestions.frequencyOptions,
        ),
        5 => _zipOptions(
          AssistQuestions.p5Scores,
          AssistQuestions.frequencyOptions,
        ),
        6 ||
        7 => _zipOptions(AssistQuestions.p67Scores, AssistQuestions.p67Options),
        _ => const <int, String>{},
      };
      for (final substance in AssistQuestions.substances) {
        columns.add(
          _QuestionColumn(
            AssistQuestions.encodedQuestionId(
              questionNumber: questionNumber,
              substanceId: substance.id,
            ),
            '${questionTitles[questionNumber]} - ${substance.label}',
            header: 'P$questionNumber.${substance.id}',
            options: options,
          ),
        );
      }
    }
    columns.add(
      _QuestionColumn(
        AssistQuestions.encodedQuestionId(questionNumber: 8, substanceId: 0),
        'P8. Consumo por via inyectada',
        header: 'P8',
        options: _zipOptions(
          AssistQuestions.p8Scores,
          AssistQuestions.p8Options,
        ),
      ),
    );
    return columns;
  }

  List<_QuestionColumn> _fantasticGeneralColumns() {
    return [
      const _QuestionColumn(
        FantasticMexaGeneralDataFields.fecha,
        'Fecha',
        header: 'D1',
      ),
      const _QuestionColumn(
        FantasticMexaGeneralDataFields.iniciales,
        'Iniciales',
        header: 'D2',
      ),
      _QuestionColumn(
        FantasticMexaGeneralDataFields.escolaridad,
        'Escolaridad',
        header: 'D3',
        options: _indexedOptions(FantasticMexaGeneralDataOptions.escolaridad),
      ),
      const _QuestionColumn(
        FantasticMexaGeneralDataFields.ocupacion,
        'Ocupacion',
        header: 'D4',
      ),
      _QuestionColumn(
        FantasticMexaGeneralDataFields.estadoCivil,
        'Estado civil',
        header: 'D5',
        options: _indexedOptions(FantasticMexaGeneralDataOptions.estadoCivil),
      ),
      _QuestionColumn(
        FantasticMexaGeneralDataFields.habitantesCasa,
        'Habitantes en casa',
        header: 'D6',
        options: _indexedOptions(
          FantasticMexaGeneralDataOptions.habitantesCasa,
        ),
      ),
      _QuestionColumn(
        FantasticMexaGeneralDataFields.numHabitantes,
        'Numero de habitantes',
        header: 'D7',
        options: _indexedOptions(FantasticMexaGeneralDataOptions.numHabitantes),
      ),
      const _QuestionColumn(
        FantasticMexaGeneralDataFields.anosLaborando,
        'Anos laborando',
        header: 'D8',
      ),
      _QuestionColumn(
        FantasticMexaGeneralDataFields.horarioLaboral,
        'Horario laboral',
        header: 'D9',
        options: _indexedOptions(
          FantasticMexaGeneralDataOptions.horarioLaboral,
        ),
      ),
      const _QuestionColumn(
        FantasticMexaGeneralDataFields.pesoKg,
        'Peso kg',
        header: 'D10',
      ),
      const _QuestionColumn(
        FantasticMexaGeneralDataFields.estaturaM,
        'Estatura m',
        header: 'D11',
      ),
    ];
  }

  Map<int, String> _indexedOptions(List<String> labels, {int startAt = 0}) {
    return {
      for (var index = 0; index < labels.length; index++)
        index + startAt: labels[index],
    };
  }

  Map<int, String> _zipOptions(List<int> values, List<String> labels) {
    return {
      for (
        var index = 0;
        index < values.length && index < labels.length;
        index++
      )
        values[index]: labels[index],
    };
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
        if (v == null) return 0;
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

    final pf =
        (sumInv(const [3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 3) - 10) / 20 * 100;
    final rp = (sumInv(const [13, 14, 15, 16], 2) - 4) / 4 * 100;

    final q21 = r[21] ?? 1;
    final q22 = r[22] ?? 1;
    final bpRaw = inv(q21, 6) + (q21 == 1 ? 6 : (6 - q22).clamp(1, 6));
    final bp = (bpRaw - 2) / 10 * 100;

    final ghRaw =
        (r[1] ?? 1) +
        inv(r[25] ?? 1, 5) +
        inv(r[26] ?? 1, 5) +
        inv(r[27] ?? 1, 5) +
        inv(r[28] ?? 1, 5);
    final gh = (ghRaw - 5) / 20 * 100;

    final vtRaw =
        inv(r[23] ?? 1, 6) + inv(r[27] ?? 1, 6) + (r[29] ?? 1) + (r[31] ?? 1);
    final vt = (vtRaw - 4) / 20 * 100;

    final sfRaw = inv(r[20] ?? 1, 5) + (r[32] ?? 1);
    final sf = (sfRaw - 2) / 8 * 100;

    final reRaw = inv(r[17] ?? 1, 2) + inv(r[18] ?? 1, 2) + inv(r[19] ?? 1, 2);
    final re = (reRaw - 3) / 3 * 100;

    final mhRaw =
        inv(r[24] ?? 1, 6) +
        inv(r[25] ?? 1, 6) +
        inv(r[26] ?? 1, 6) +
        inv(r[28] ?? 1, 6) +
        (r[30] ?? 1);
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
    if (value is num) return value.toStringAsFixed(1);
    return '$value';
  }
}

class _QuestionColumn {
  final int id;
  final String label;
  final String? columnHeader;
  final Map<int, String> options;
  final bool isMultiChoiceMask;

  String get header => columnHeader ?? '$id';

  const _QuestionColumn(
    this.id,
    this.label, {
    String? header,
    this.options = const {},
    this.isMultiChoiceMask = false,
  }) : columnHeader = header;
}
