import 'package:flutter/material.dart' as material;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/reports/presentation/reports_viewmodel.dart';
import 'package:ssapp/features/reports/presentation/viewmodels/survey_report_viewmodels.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_definition.dart';
import 'package:ssapp/features/survey_builder/domain/custom_survey_service.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportsViewModel _viewModel;
  List<CustomSurveyDefinition> _customSurveys = [];
  int _selectedValue = 1;

  static const Map<int, String> _surveyNames = {
    1: 'BDI-II',
    2: 'BAI',
    3: 'WHOQOL-BREF',
    5: 'SF-36',
    6: 'ASSIST V3.0',
    7: 'GDS-15',
    8: 'Lawton AIVD',
    9: 'Osteoporosis',
    10: 'Katz ABVD',
    11: 'ICIQ-SF',
    12: 'GHQ-12',
    13: 'PHQ-9',
    14: 'Sociodemográfico',
    15: 'Determinantes Sociales',
  };

  @override
  void initState() {
    super.initState();
    _viewModel = ReportsViewModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel.surveys.isEmpty && !_viewModel.isLoading) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    final surveyService = context.read<SurveyService>();
    final customSurveyService = context.read<CustomSurveyService>();
    await surveyService.loadSurveys();
    await customSurveyService.loadAll();
    if (!mounted) return;
    setState(() => _customSurveys = customSurveyService.activeSurveys);
    await _loadForType(_viewModel.selectedSurveyType);
  }

  Future<void> _loadForType(int value) {
    setState(() => _selectedValue = value);
    final surveyService = context.read<SurveyService>();
    if (_surveyNames.containsKey(value)) {
      return _viewModel.loadReport(surveyService, value);
    }
    final definition = context.read<CustomSurveyService>().getById(value);
    return _viewModel.loadReport(
      surveyService,
      100,
      customSurveyId: definition?.id,
      customDefinition: definition,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportsViewModel>.value(
      value: _viewModel,
      child: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            headers: [
              AppBar(
                title: const Text('Reportes y Estadísticas'),
                leading: [
                  IconButton(
                    icon: const Icon(material.Icons.arrow_back),
                    onPressed: () => material.Navigator.of(context).pop(),
                    variance: ButtonVariance.ghost,
                  ),
                ],
              ),
            ],
            child: Column(
              children: [
                _HeaderBar(
                  selectedValue: _selectedValue,
                  customSurveys: _customSurveys,
                  isExporting: vm.isExporting,
                  onSurveyTypeChanged: (value) => _loadForType(value),
                  onExportCsv: vm.surveys.isEmpty ? null : () => vm.exportCsv(context),
                  onExportPdf: vm.surveys.isEmpty ? null : () => vm.exportPdf(context),
                ),
                const Divider(height: 1),
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _ReportBody(
                          reportViewModel: vm.activeReportViewModel,
                          surveyName: vm.activeReportViewModel.surveyName,
                          surveys: vm.surveys,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final int selectedValue;
  final List<CustomSurveyDefinition> customSurveys;
  final bool isExporting;
  final ValueChanged<int> onSurveyTypeChanged;
  final VoidCallback? onExportCsv;
  final VoidCallback? onExportPdf;

  const _HeaderBar({
    required this.selectedValue,
    required this.customSurveys,
    required this.isExporting,
    required this.onSurveyTypeChanged,
    required this.onExportCsv,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: Select<int>(
              value: selectedValue,
              onChanged: (v) {
                if (v != null) onSurveyTypeChanged(v);
              },
              itemBuilder: (context, item) => Text(_labelForType(item, customSurveys)),
              popup: SelectPopup(
                items: SelectItemList(
                  children: [
                    const SelectItemButton(value: 1, child: Text('BDI-II')),
                    const SelectItemButton(value: 2, child: Text('BAI')),
                    const SelectItemButton(value: 3, child: Text('WHOQOL-BREF')),
                    const SelectItemButton(value: 5, child: Text('SF-36')),
                    const SelectItemButton(value: 6, child: Text('ASSIST V3.0')),
                    const SelectItemButton(value: 7, child: Text('GDS-15')),
                    const SelectItemButton(value: 8, child: Text('Lawton AIVD')),
                    const SelectItemButton(value: 9, child: Text('Osteoporosis')),
                    const SelectItemButton(value: 10, child: Text('Katz ABVD')),
                    const SelectItemButton(value: 11, child: Text('ICIQ-SF')),
                    const SelectItemButton(value: 12, child: Text('GHQ-12')),
                    const SelectItemButton(value: 13, child: Text('PHQ-9')),
                    const SelectItemButton(value: 14, child: Text('Sociodemográfico')),
                    const SelectItemButton(value: 15, child: Text('Determinantes Sociales')),
                    for (final def in customSurveys)
                      SelectItemButton(value: def.id, child: Text('Mis encuestas: ${def.title}')),
                  ],
                ),
              ).call,
            ),
          ),
          OutlineButton(
            onPressed: isExporting ? null : onExportCsv,
            child: const Text('Exportar CSV'),
          ),
          PrimaryButton(
            onPressed: isExporting ? null : onExportPdf,
            child: Text(isExporting ? 'Exportando...' : 'Exportar PDF'),
          ),
        ],
      ),
    );
  }

  static String _labelForType(int surveyType, List<CustomSurveyDefinition> customSurveys) {
    switch (surveyType) {
      case 1:
        return 'BDI-II';
      case 2:
        return 'BAI';
      case 3:
        return 'WHOQOL-BREF';
      case 5:
        return 'SF-36';
      case 6:
        return 'ASSIST V3.0';
      case 7:
        return 'GDS-15';
      case 8:
        return 'Lawton AIVD';
      case 9:
        return 'Osteoporosis';
      case 10:
        return 'Katz ABVD';
      case 11:
        return 'ICIQ-SF';
      case 12:
        return 'GHQ-12';
      case 13:
        return 'PHQ-9';
      case 14:
        return 'Sociodemográfico';
      case 15:
        return 'Determinantes Sociales';
      default:
        for (final def in customSurveys) {
          if (def.id == surveyType) return def.title;
        }
        return 'Encuesta';
    }
  }
}

class _ReportBody extends StatelessWidget {
  final SurveyReportViewModel reportViewModel;
  final String surveyName;
  final List<Map<String, dynamic>> surveys;

  const _ReportBody({
    required this.reportViewModel,
    required this.surveyName,
    required this.surveys,
  });

  @override
  Widget build(BuildContext context) {
    if (surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(material.Icons.bar_chart, size: 72, color: Theme.of(context).colorScheme.mutedForeground),
            const Gap(12),
            Text('Sin encuestas para $surveyName').semiBold(),
            const Gap(4),
            const Text('Selecciona otro tipo o completa nuevas encuestas').small().muted(),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RepaintBoundary(
        child: _DeferredSection(
          reportViewModel: reportViewModel,
          surveys: surveys,
        ),
      ),
    );
  }
}

/// Difiere la construcción de la sección al siguiente frame para no bloquear
/// la animación de navegación ni el hilo principal al cambiar tipo de reporte.
class _DeferredSection extends StatefulWidget {
  final SurveyReportViewModel reportViewModel;
  final List<Map<String, dynamic>> surveys;

  const _DeferredSection({
    required this.reportViewModel,
    required this.surveys,
  });

  @override
  State<_DeferredSection> createState() => _DeferredSectionState();
}

class _DeferredSectionState extends State<_DeferredSection> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void didUpdateWidget(_DeferredSection old) {
    super.didUpdateWidget(old);
    // Al cambiar tipo de reporte o datos: muestra loading un frame antes
    // de reconstruir todos los charts, liberando el hilo principal.
    if (old.reportViewModel.surveyType != widget.reportViewModel.surveyType ||
        !identical(old.surveys, widget.surveys)) {
      setState(() => _ready = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.reportViewModel.buildSection(widget.surveys);
  }
}
