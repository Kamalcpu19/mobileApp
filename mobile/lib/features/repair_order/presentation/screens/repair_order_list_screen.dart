import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/category_chip_bar.dart';
import '../../../../core/widgets/search_bar_field.dart';
import '../providers/repair_order_providers.dart';
import '../widgets/repair_order_card.dart';

class RepairOrderListScreen extends ConsumerStatefulWidget {
  const RepairOrderListScreen({super.key});

  @override
  ConsumerState<RepairOrderListScreen> createState() =>
      _RepairOrderListScreenState();
}

class _RepairOrderListScreenState extends ConsumerState<RepairOrderListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(repairOrderFilterProvider);
    final ordersAsync = ref.watch(repairOrdersProvider);
    final stagesAsync = ref.watch(roStagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Attention List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/appointments'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBarField(
              hint: 'Search RO, customer, registration...',
              controller: _searchController,
              onChanged: (value) {
                ref.read(repairOrderFilterProvider.notifier).state =
                    filter.copyWith(search: value);
              },
            ),
          ),
          stagesAsync.when(
            loading: () => const SizedBox(height: 40),
            error: (_, __) => const SizedBox.shrink(),
            data: (stages) {
              final categories = ['All', ...stages];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CategoryChipBar(
                  categories: categories,
                  selected: filter.stage,
                  onSelected: (stage) {
                    ref.read(repairOrderFilterProvider.notifier).state =
                        filter.copyWith(stage: stage);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('No repair orders found'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(repairOrdersProvider),
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return RepairOrderCard(
                        order: order,
                        onTap: () => context.push('/repair-orders/${order.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-ro'),
        icon: const Icon(Icons.add),
        label: const Text('Create RO'),
      ),
    );
  }
}
