import 'package:flutter/material.dart' as material show Icons;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ssapp/features/investigations/domain/investigation_model.dart';
import 'package:ssapp/features/investigations/presentation/components/list_card/list_card.dart';
import 'package:ssapp/features/investigations/presentation/components/search_bar/search_bar.dart';
import 'package:ssapp/features/investigations/presentation/screens/investigations_screen/components/investigations_content/widgets/widgets.dart';

class InvestigationsContent extends StatelessWidget {
  final List<InvestigationModel> investigations;
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const InvestigationsContent({
    super.key,
    required this.investigations,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: PrimaryButton(
            onPressed: () => context.push('/investigations/new'),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(material.Icons.add, size: 18),
                Gap(8),
                Text('Nueva investigacion'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: InvestigationsSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
            onClear: onClearSearch,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          child: Row(
            children: [
              const Text('Listado disponible').semiBold(),
              const Spacer(),
              ResultsCounter(count: investigations.length),
            ],
          ),
        ),
        Expanded(
          child: investigations.isEmpty
              ? _InvestigationsEmptyState(hasFilter: searchQuery.trim().isNotEmpty)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: investigations.length,
                  separatorBuilder: (context, index) => const Gap(12),
                  itemBuilder: (context, index) {
                    final investigation = investigations[index];
                    return InvestigationListCard(
                      investigation: investigation,
                      onTap: () => context.push('/investigations/${investigation.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _InvestigationsEmptyState extends StatelessWidget {
  final bool hasFilter;

  const _InvestigationsEmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              material.Icons.science_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(12),
            Text(
              hasFilter
                  ? 'No encontramos investigaciones con ese termino'
                  : 'No hay investigaciones registradas todavia',
              textAlign: TextAlign.center,
            ).semiBold(),
            const Gap(6),
            Text(
              hasFilter
                  ? 'Prueba con otro nombre o ID.'
                  : 'Cuando crees una investigacion aparecera aqui.',
              textAlign: TextAlign.center,
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}

