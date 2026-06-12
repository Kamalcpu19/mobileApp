import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/workflow_provider.dart';
import '../widgets/workflow_order_card.dart';

class SparesPendingScreen extends ConsumerStatefulWidget {
  const SparesPendingScreen({super.key});

  @override
  ConsumerState<SparesPendingScreen> createState() => _SparesPendingScreenState();
}

class _SparesPendingScreenState extends ConsumerState<SparesPendingScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sparesPendingProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Spares Pending',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 16, isWide ? 24 : 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search RO, vehicle, customer...',
              leading: const Icon(Icons.search),
              onSubmitted: ref.read(sparesPendingProvider.notifier).setSearch,
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(sparesPendingProvider.notifier).setSearch('');
                    },
                  ),
              ],
            ),
          ),
          Expanded(child: _buildContent(context, state, isWide)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkflowListState state, bool isWide) {
    if (state.isLoading && state.orders.isEmpty) {
      return const LoadingWidget(message: 'Loading spares pending...');
    }

    if (state.error != null && state.orders.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(sparesPendingProvider.notifier).load(),
      );
    }

    if (state.orders.isEmpty) {
      return const Center(child: Text('No repair orders awaiting spares'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(sparesPendingProvider.notifier).load(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 8),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return WorkflowOrderCard(
            order: order,
            onTap: () => _showSparesSheet(context, order.id),
          );
        },
      ),
    );
  }

  void _showSparesSheet(BuildContext context, String repairOrderId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _SparesReadOnlySheet(repairOrderId: repairOrderId),
    );
  }
}

class _SparesReadOnlySheet extends ConsumerWidget {
  const _SparesReadOnlySheet({required this.repairOrderId});

  final String repairOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sparesDetailProvider(repairOrderId));
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        if (state.isLoading) {
          return const LoadingWidget(message: 'Loading spares...');
        }

        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Pending Spares',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (state.order != null) ...[
              const SizedBox(height: 4),
              Text(state.order!.vehicleLabel, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            if (state.spares.isEmpty)
              const Text('No spare parts listed for this repair order.')
            else
              ...state.spares.map(
                (spare) => ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(spare.partName),
                  subtitle: Text(
                    [
                      if (spare.partNumber != null) 'PN: ${spare.partNumber}',
                      'Qty: ${spare.quantity.toStringAsFixed(0)}',
                    ].join(' · '),
                  ),
                  trailing: Chip(
                    label: Text(spare.status),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
