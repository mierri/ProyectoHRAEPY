import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:ssapp/features/reports/domain/osteoporosis_report_service.dart';
import 'package:ssapp/features/reports/domain/stats_calculator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/bdi_bai_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/osteoporosis_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/sf36_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/generic_pdf_generator.dart';
import 'package:ssapp/features/reports/infrastructure/pdf/whoqol_pdf_generator.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/assist_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/custom_survey_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/bai_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/bdi_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/gds_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/ghq12_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/iciqsf_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/katz_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/lawton_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/osteoporosis_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/phq9_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/sf36_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/social_determinants_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/sociodemographic_report_section.dart';
import 'package:ssapp/features/reports/presentation/widgets/sections/whoqol_report_section.dart';

abstract class SurveyReportViewModel {
  const SurveyReportViewModel();

  int get surveyType;
  String get surveyName;
  List<GlobalKey> get chartKeys;

  Widget buildSection(List<Map<String, dynamic>> surveys);

  /// Legacy: generates PDF without chart images (fallback).
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys);

  /// Generates PDF with captured chart images embedded.
  /// Default falls back to [generatePdf]; override for better output.
  Future<Uint8List> generatePdfWithImages(
    List<Map<String, dynamic>> surveys,
    List<Uint8List?> chartImages,
  ) async {
    // Default: use GenericPdfGenerator which embeds chart images
    return GenericPdfReportGenerator(
      surveyName: surveyName,
      surveys: surveys,
      chartImages: chartImages,
    ).generate();
  }
}

// ── BDI-II ────────────────────────────────────────────────────────────────────

class BdiReportViewModel extends SurveyReportViewModel {
  const BdiReportViewModel();
  @override int get surveyType => 1;
  @override String get surveyName => 'BDI-II';
  @override List<GlobalKey> get chartKeys => BdiReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => BdiReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 1).generate(surveys);
}

// ── BAI ───────────────────────────────────────────────────────────────────────

class BaiReportViewModel extends SurveyReportViewModel {
  const BaiReportViewModel();
  @override int get surveyType => 2;
  @override String get surveyName => 'BAI';
  @override List<GlobalKey> get chartKeys => BaiReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => BaiReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 2).generate(surveys);
}

// ── WHOQOL-BREF ───────────────────────────────────────────────────────────────

class WhoqolReportViewModel extends SurveyReportViewModel {
  const WhoqolReportViewModel();
  @override int get surveyType => 3;
  @override String get surveyName => 'WHOQOL-BREF';
  @override List<GlobalKey> get chartKeys => WhoqolReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) {
    final data = SurveyStatsCalculator.computeWhoqolReport(surveys);
    return WhoqolReportSection(data: data);
  }
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      const WhoqolPdfGenerator().generate(surveys);
}

// ── SF-36 ─────────────────────────────────────────────────────────────────────

class Sf36ReportViewModel extends SurveyReportViewModel {
  const Sf36ReportViewModel();
  @override int get surveyType => 5;
  @override String get surveyName => 'SF-36';
  @override List<GlobalKey> get chartKeys => Sf36ReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) {
    final data = SurveyStatsCalculator.computeSF36Report(surveys);
    return Sf36ReportSection(data: data);
  }
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      const Sf36PdfGenerator().generate(surveys);
}

// ── ASSIST V3.0 ───────────────────────────────────────────────────────────────

class AssistReportViewModel extends SurveyReportViewModel {
  const AssistReportViewModel();
  @override int get surveyType => 6;
  @override String get surveyName => 'ASSIST V3.0';
  @override List<GlobalKey> get chartKeys => AssistReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => AssistReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 6).generate(surveys);
}

// ── GDS-15 ────────────────────────────────────────────────────────────────────

class GdsReportViewModel extends SurveyReportViewModel {
  const GdsReportViewModel();
  @override int get surveyType => 7;
  @override String get surveyName => 'GDS-15';
  @override List<GlobalKey> get chartKeys => GdsReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => GdsReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 7).generate(surveys);
}

// ── Lawton AIVD ───────────────────────────────────────────────────────────────

class LawtonReportViewModel extends SurveyReportViewModel {
  const LawtonReportViewModel();
  @override int get surveyType => 8;
  @override String get surveyName => 'Lawton AIVD';
  @override List<GlobalKey> get chartKeys => LawtonReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => LawtonReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 8).generate(surveys);
}

// ── Osteoporosis ──────────────────────────────────────────────────────────────

class OsteoporosisReportViewModel extends SurveyReportViewModel {
  const OsteoporosisReportViewModel();
  @override int get surveyType => 9;
  @override String get surveyName => 'Osteoporosis';
  @override List<GlobalKey> get chartKeys => OsteoporosisReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) {
    final report = OsteoporosisReportService.generateCompleteReport(surveys);
    return OsteoporosisReportSection(report: report);
  }
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      const OsteoporosisPdfGenerator().generate(surveys);
}

// ── Katz ABVD ─────────────────────────────────────────────────────────────────

class KatzReportViewModel extends SurveyReportViewModel {
  const KatzReportViewModel();
  @override int get surveyType => 10;
  @override String get surveyName => 'Katz ABVD';
  @override List<GlobalKey> get chartKeys => KatzReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => KatzReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 10).generate(surveys);
}

// ── ICIQ-SF ───────────────────────────────────────────────────────────────────

class IciqsfReportViewModel extends SurveyReportViewModel {
  const IciqsfReportViewModel();
  @override int get surveyType => 11;
  @override String get surveyName => 'ICIQ-SF';
  @override List<GlobalKey> get chartKeys => IciqsfReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => IciqsfReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 11).generate(surveys);
}

// ── GHQ-12 ────────────────────────────────────────────────────────────────────

class Ghq12ReportViewModel extends SurveyReportViewModel {
  const Ghq12ReportViewModel();
  @override int get surveyType => 12;
  @override String get surveyName => 'GHQ-12';
  @override List<GlobalKey> get chartKeys => Ghq12ReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => Ghq12ReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 12).generate(surveys);
}

// ── PHQ-9 ─────────────────────────────────────────────────────────────────────

class Phq9ReportViewModel extends SurveyReportViewModel {
  const Phq9ReportViewModel();
  @override int get surveyType => 13;
  @override String get surveyName => 'PHQ-9';
  @override List<GlobalKey> get chartKeys => Phq9ReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) => Phq9ReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 13).generate(surveys);
}

// ── Sociodemográfico ──────────────────────────────────────────────────────────

class SociodemographicReportViewModel extends SurveyReportViewModel {
  const SociodemographicReportViewModel();
  @override int get surveyType => 14;
  @override String get surveyName => 'Sociodemográfico';
  @override List<GlobalKey> get chartKeys => SociodemographicReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) =>
      SociodemographicReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 14).generate(surveys);
}

// ── Determinantes Sociales ────────────────────────────────────────────────────

class SocialDeterminantsReportViewModel extends SurveyReportViewModel {
  const SocialDeterminantsReportViewModel();
  @override int get surveyType => 15;
  @override String get surveyName => 'Determinantes Sociales';
  @override List<GlobalKey> get chartKeys => SocialDeterminantsReportSection.chartKeys;
  @override Widget buildSection(List<Map<String, dynamic>> surveys) =>
      SocialDeterminantsReportSection(surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      BdiBaiPdfGenerator(surveyType: 15).generate(surveys);
}

// ── Encuesta personalizada ───────────────────────────────────────────────────

class CustomSurveyReportViewModel extends SurveyReportViewModel {
  final CustomSurveyDefinition definition;

  const CustomSurveyReportViewModel(this.definition);

  @override int get surveyType => 100;
  @override String get surveyName => definition.title;
  @override List<GlobalKey> get chartKeys => const [];
  @override Widget buildSection(List<Map<String, dynamic>> surveys) =>
      CustomSurveyReportSection(definition: definition, surveys: surveys);
  @override Future<Uint8List> generatePdf(List<Map<String, dynamic>> surveys) =>
      GenericPdfReportGenerator(surveyName: surveyName, surveys: surveys, chartImages: const []).generate();
}

// ── Router ────────────────────────────────────────────────────────────────────

SurveyReportViewModel resolveReportViewModel(int surveyType, {CustomSurveyDefinition? customDefinition}) {
  if (surveyType == 100 && customDefinition != null) {
    return CustomSurveyReportViewModel(customDefinition);
  }
  return switch (surveyType) {
    1  => const BdiReportViewModel(),
    2  => const BaiReportViewModel(),
    3  => const WhoqolReportViewModel(),
    5  => const Sf36ReportViewModel(),
    6  => const AssistReportViewModel(),
    7  => const GdsReportViewModel(),
    8  => const LawtonReportViewModel(),
    9  => const OsteoporosisReportViewModel(),
    10 => const KatzReportViewModel(),
    11 => const IciqsfReportViewModel(),
    12 => const Ghq12ReportViewModel(),
    13 => const Phq9ReportViewModel(),
    14 => const SociodemographicReportViewModel(),
    15 => const SocialDeterminantsReportViewModel(),
    _  => const BdiReportViewModel(),
  };
}
