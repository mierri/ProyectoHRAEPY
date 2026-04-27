import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:ssapp/features/reports/domain/osteoporosis_report_service.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/bdi_bai_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/osteoporosis_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/sf36_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/whoqol_pdf_generator.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/bdi_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/osteoporosis_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/sf36_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/whoqol_report_section.dart';

abstract class SurveyReportViewModel {
  const SurveyReportViewModel();

  int get surveyType;
  String get surveyName;

  Widget buildSection(List<Map<String, dynamic>> surveys);
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys);
}

class BdiBaiReportViewModel extends SurveyReportViewModel {
  @override
  final int surveyType;

  const BdiBaiReportViewModel({required this.surveyType});

  @override
  String get surveyName {
    return switch (surveyType) {
      2 => 'BAI',
      12 => 'GHQ-12',
      13 => 'PHQ-9',
      _ => 'BDI-II',
    };
  }

  @override
  Widget buildSection(List<Map<String, dynamic>> surveys) {
    final scores = surveys.map(SurveyStatsCalculator.calculateSurveyScore).toList();
    final stats = SurveyStatsCalculator.computeBasicStats(scores);
    final dist = switch (surveyType) {
      2 => SurveyStatsCalculator.baiDistribution(surveys),
      12 => SurveyStatsCalculator.ghq12Distribution(surveys),
      13 => SurveyStatsCalculator.phq9Distribution(surveys),
      _ => SurveyStatsCalculator.bdiDistribution(surveys),
    };

    return BdiReportSection(
      surveys: surveys,
      stats: stats,
      distribution: dist,
      title: 'Resumen $surveyName',
    );
  }

  @override
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) {
    return BdiBaiPdfGenerator(surveyType: surveyType).generate(surveys);
  }
}

class WhoqolReportViewModel extends SurveyReportViewModel {
  const WhoqolReportViewModel();

  @override
  int get surveyType => 3;

  @override
  String get surveyName => 'WHOQOL-BREF';

  @override
  Widget buildSection(List<Map<String, dynamic>> surveys) {
    final data = SurveyStatsCalculator.computeWhoqolReport(surveys);
    return WhoqolReportSection(data: data);
  }

  @override
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) {
    return const WhoqolPdfGenerator().generate(surveys);
  }
}

class Sf36ReportViewModel extends SurveyReportViewModel {
  const Sf36ReportViewModel();

  @override
  int get surveyType => 5;

  @override
  String get surveyName => 'SF-36';

  @override
  Widget buildSection(List<Map<String, dynamic>> surveys) {
    final data = SurveyStatsCalculator.computeSF36Report(surveys);
    return Sf36ReportSection(data: data);
  }

  @override
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) {
    return const Sf36PdfGenerator().generate(surveys);
  }
}

class OsteoporosisReportViewModel extends SurveyReportViewModel {
  const OsteoporosisReportViewModel();

  @override
  int get surveyType => 9;

  @override
  String get surveyName => 'Osteoporosis';

  @override
  Widget buildSection(List<Map<String, dynamic>> surveys) {
    final report = OsteoporosisReportService.generateCompleteReport(surveys);
    return OsteoporosisReportSection(report: report);
  }

  @override
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) {
    return const OsteoporosisPdfGenerator().generate(surveys);
  }
}

SurveyReportViewModel resolveReportViewModel(int surveyType) {
  return switch (surveyType) {
    2 => const BdiBaiReportViewModel(surveyType: 2),
    3 => const WhoqolReportViewModel(),
    5 => const Sf36ReportViewModel(),
    9 => const OsteoporosisReportViewModel(),
    12 => const BdiBaiReportViewModel(surveyType: 12),
    13 => const BdiBaiReportViewModel(surveyType: 13),
    _ => BdiBaiReportViewModel(surveyType: surveyType),
  };
}
