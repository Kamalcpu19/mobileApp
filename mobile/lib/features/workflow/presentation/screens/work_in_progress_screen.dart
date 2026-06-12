import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/workflow_provider.dart';
import '../widgets/workflow_order_card.dart';

class WorkInProgressScreen extends ConsumerStatefulWidget {
  const WorkInProgressScreen({super.key});

  @override
  ConsumerState<WorkInProgressScreen> createState() => _WorkInProgressScreenState();
}

class _WorkInProgressScreenState extends ConsumerState<WorkInProgressScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workInProgressProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Work In Progress',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 16, isWide ? 24 : 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search RO, vehicle, customer...',
              leading: const Icon(Icons.search),
              onSubmitted: ref.read(workInProgressProvider.notifier).setSearch,
            ),
          ),
          Expanded(child: _buildList(context, state, isWide)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WorkflowListState state, bool isWide) {
    if (state.isLoading && state.orders.isEmpty) {
      return const LoadingWidget(message: 'Loading work in progress...');
    }

    if (state.error != null && state.orders.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(workInProgressProvider.notifier).load(),
      );
    }

    if (state.orders.isEmpty) {
      return const Center(child: Text('No repairs in progress'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(workInProgressProvider.notifier).load(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 8),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return WorkflowOrderCard(
            order: order,
            onTap: () => context.push('/repair-orders/${order.id}/wip'),
          );
        },
      ),
    );
  }
}

class WorkInProgressDetailScreen extends ConsumerWidget {
  const WorkInProgressDetailScreen({super.key, required this.repairOrderId});

  final String repairOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workInProgressDetailProvider(repairOrderId));
    final notifier = ref.read(workInProgressDetailProvider(repairOrderId).notifier);
    final dateFormat = DateFormat('dd MMM yyyy · HH:mm');
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Track Repair',
      body: _buildBody(context, state, notifier, dateFormat, isWide),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WorkInProgressDetailState state,
    WorkInProgressDetailNotifier notifier,
    DateFormat dateFormat,
    bool isWide,
  ) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading repair details...');
    }

    if (state.error != null && state.order == null) {
      return AppErrorWidget(message: state.error!, onRetry: notifier.load);
    }

    final order = state.order!;
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.roNumber, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(order.vehicleLabel),
                      if (order.customerName != null) Text(order.customerName!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Repair Timeline', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...state.timeline.map(
                (entry) => ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.timeline, size: 18, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  title: Text(AppConstants.stageLabels[entry.toStage] ?? entry.toStage),
                  subtitle: Text(
                    [
                      if (entry.changedByName != null) entry.changedByName,
                      if (entry.createdAt != null) dateFormat.format(entry.createdAt!.toLocal()),
                      if (entry.notes != null) entry.notes,
                    ].whereType<String>().join(' · '),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showJobCard(context, state.jobCard),
                icon: const Icon(Icons.description_outlined),
                label: const Text('View Job Card'),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isWide ? 24 : 16),
            child: FilledButton.icon(
              onPressed: state.isUpdating
                  ? null
                  : () async {
                      final success = await notifier.markComplete();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Marked ready for delivery')),
                        );
                        context.pop();
                      }
                    },
              icon: state.isUpdating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_circle_outline),
              label: Text(state.isUpdating ? 'Updating...' : 'Mark Complete'),
            ),
          ),
        ),
      ],
    );
  }

  void _showJobCard(BuildContext context, Map<String, dynamic>? jobCard) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Job Card'),
        content: jobCard == null
            ? const Text('No job card found for this repair order.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Number: ${jobCard['job_card_number']}'),
                  Text('RO: ${jobCard['ro_number']}'),
                  Text('Status: ${jobCard['status']}'),
                ],
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
