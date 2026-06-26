import 'package:flutter/material.dart' as material show Icons;
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/reports/presentation/reports_viewmodel.dart';
import 'package:ssapp/features/surveys/domain/survey_service.dart';

const Map<int, String> _surveyNames = {
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
  16: 'Asistencia en Consulta de Especialidad',
  17: 'Barreras Percibidas para la Asistencia',
};

class InvestigationReportsSection extends StatefulWidget {
  final InvestigationModel investigation;

  const InvestigationReportsSection({
    super.key,
    required this.investigation,
  });

  @override
  State<InvestigationReportsSection> createState() =>
      _InvestigationReportsSectionState();
}

class _InvestigationReportsSectionState
    extends State<InvestigationReportsSection> {
  late final ReportsViewModel _viewModel;
  late List<int> _availableTypes;

  @override
  void initState() {
    super.initState();
    _viewModel = ReportsViewModel();
    _availableTypes = widget.investigation.surveyTypeIds
        .where((id) => _surveyNames.containsKey(id))
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_availableTypes.isNotEmpty &&
        _viewModel.surveys.isEmpty &&
        !_viewModel.isLoading) {
      _loadForType(_availableTypes.first);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadForType(int surveyType) {
    final surveyService = context.read<SurveyService>();
    return _viewModel.loadReport(
      surveyService,
      surveyType,
      investigationId: widget.investigation.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_availableTypes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              material.Icons.bar_chart,
              size: 72,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(12),
            const Text('Sin encuestas configuradas').semiBold(),
            const Gap(4),
            const Text('Esta investigación no tiene encuestas asignadas')
                .small()
                .muted(),
          ],
        ),
      );
    }

    return ChangeNotifierProvider<ReportsViewModel>.value(
      value: _viewModel,
      child: Consumer<ReportsViewModel>(
        builder: (context, vm, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ControlBar(
                selectedSurveyType: vm.selectedSurveyType,
                availableTypes: _availableTypes,
                isExporting: vm.isExporting,
                onSurveyTypeChanged: _loadForType,
                onExportCsv:
                    vm.surveys.isEmpty ? null : () => vm.exportCsv(context),
                onExportPdf:
                    vm.surveys.isEmpty ? null : () => vm.exportPdf(context),
                onPrintPdf:
                    vm.surveys.isEmpty ? null : () => vm.printPdf(context),
              ),
              const Divider(height: 1),
              const Gap(16),
              if (vm.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (vm.surveys.isEmpty)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        material.Icons.bar_chart,
                        size: 72,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                      const Gap(12),
                      Text(
                        'Sin respuestas para ${_surveyNames[vm.selectedSurveyType] ?? 'Encuesta'}',
                      ).semiBold(),
                      const Gap(4),
                      const Text(
                        'Aún no hay encuestas completadas en esta investigación',
                      ).small().muted(),
                    ],
                  ),
                )
              else
                vm.activeReportViewModel.buildSection(vm.surveys),
            ],
          );
        },
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  final int selectedSurveyType;
  final List<int> availableTypes;
  final bool isExporting;
  final ValueChanged<int> onSurveyTypeChanged;
  final VoidCallback? onExportCsv;
  final VoidCallback? onExportPdf;
  final VoidCallback? onPrintPdf;

  const _ControlBar({
    required this.selectedSurveyType,
    required this.availableTypes,
    required this.isExporting,
    required this.onSurveyTypeChanged,
    required this.onExportCsv,
    required this.onExportPdf,
    required this.onPrintPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: Select<int>(
            value: selectedSurveyType,
            onChanged: (v) {
              if (v != null) onSurveyTypeChanged(v);
            },
            itemBuilder: (context, item) =>
                Text(_surveyNames[item] ?? 'Encuesta'),
            popup: SelectPopup(
              items: SelectItemList(
                children: [
                  for (final typeId in availableTypes)
                    SelectItemButton(
                      value: typeId,
                      child: Text(_surveyNames[typeId] ?? 'Encuesta'),
                    ),
                ],
              ),
            ).call,
          ),
        ),
        OutlineButton(
          onPressed: isExporting ? null : onExportCsv,
          child: const Text('Exportar CSV'),
        ),
        OutlineButton(
          onPressed: isExporting ? null : onPrintPdf,
          child: const Text('Imprimir PDF'),
        ),
        PrimaryButton(
          onPressed: isExporting ? null : onExportPdf,
          child: Text(isExporting ? 'Procesando...' : 'Descargar PDF'),
        ),
      ],
    );
  }
}
