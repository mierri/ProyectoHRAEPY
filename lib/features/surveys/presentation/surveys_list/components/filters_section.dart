import 'package:shadcn_flutter/shadcn_flutter.dart';

class SurveyFilterOption {
  final String value;
  final String label;
  const SurveyFilterOption({required this.value, required this.label});
}

class SurveysFiltersSection extends StatelessWidget {
  final String filterType;
  final String filterStatus;
  final ValueChanged<String> onFilterTypeChanged;
  final ValueChanged<String> onFilterStatusChanged;

  const SurveysFiltersSection({
    super.key,
    required this.filterType,
    required this.filterStatus,
    required this.onFilterTypeChanged,
    required this.onFilterStatusChanged,
  });

  static const _typeOptions = [
    SurveyFilterOption(value: 'all',                label: 'Todas'),
    SurveyFilterOption(value: 'bdi',                label: 'BDI-II'),
    SurveyFilterOption(value: 'bai',                label: 'BAI'),
    SurveyFilterOption(value: 'gds',                label: 'GDS-15'),
    SurveyFilterOption(value: 'ghq12',              label: 'GHQ-12'),
    SurveyFilterOption(value: 'phq9',               label: 'PHQ-9'),
    SurveyFilterOption(value: 'lawton',             label: 'Lawton AIVD'),
    SurveyFilterOption(value: 'katz',               label: 'Katz ABVD'),
    SurveyFilterOption(value: 'iciqsf',             label: 'ICIQ-SF'),
    SurveyFilterOption(value: 'whoqol',             label: 'WHOQOL-BREF'),
    SurveyFilterOption(value: 'sf36',               label: 'SF-36'),
    SurveyFilterOption(value: 'assist',             label: 'ASSIST V3.0'),
    SurveyFilterOption(value: 'osteoporosis',       label: 'Osteoporosis'),
    SurveyFilterOption(value: 'sociodemographic',   label: 'Sociodemografico'),
    SurveyFilterOption(value: 'social_determinants',label: 'Determinantes Sociales'),
  ];

  static const _statusOptions = [
    SurveyFilterOption(value: 'all',     label: 'Todas'),
    SurveyFilterOption(value: 'synced',  label: 'Sincronizadas'),
    SurveyFilterOption(value: 'pending', label: 'Pendientes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: SurveyFilterDropdown(
            label: 'Tipo de encuesta',
            options: _typeOptions,
            selected: filterType == 'all' ? null : filterType,
            hint: 'Todas',
            onChanged: (v) => onFilterTypeChanged(v ?? 'all'),
          )),
          const Gap(10),
          Expanded(child: SurveyFilterDropdown(
            label: 'Estado',
            options: _statusOptions,
            selected: filterStatus == 'all' ? null : filterStatus,
            hint: 'Todas',
            onChanged: (v) => onFilterStatusChanged(v ?? 'all'),
          )),
        ],
      ),
    );
  }
}

class SurveyFilterDropdown extends StatelessWidget {
  final String label;
  final List<SurveyFilterOption> options;
  final String? selected;
  final String hint;
  final ValueChanged<String?> onChanged;

  const SurveyFilterDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label).small(),
        const Gap(6),
        Select<String>(
          value: selected,
          onChanged: onChanged,
          itemBuilder: (context, item) {
            final match = options.where((o) => o.value == item).toList();
            return Text(match.isNotEmpty ? match.first.label : item);
          },
          popup: SelectPopup(
            items: SelectItemList(
              children: [
                for (final opt in options)
                  SelectItemButton(
                    value: opt.value == 'all' ? null : opt.value,
                    child: Text(opt.label),
                  ),
              ],
            ),
          ).call,
          placeholder: Text(hint, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
