import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/workflow_provider.dart';
import '../widgets/workflow_order_card.dart';

class ReadyForDeliveryScreen extends ConsumerWidget {
  const ReadyForDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readyForDeliveryProvider);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Ready for Delivery',
      body: _buildBody(context, ref, state, isWide),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, WorkflowListState state, bool isWide) {
    if (state.isLoading && state.orders.isEmpty) {
      return const LoadingWidget(message: 'Loading deliveries...');
    }

    if (state.error != null && state.orders.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(readyForDeliveryProvider.notifier).load(),
      );
    }

    if (state.orders.isEmpty) {
      return const Center(child: Text('No vehicles ready for delivery'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(readyForDeliveryProvider.notifier).load(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 16),
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return WorkflowOrderCard(
            order: order,
            trailing: FilledButton.tonal(
              onPressed: () => context.push(RoutePaths.reviewFor(order.id)),
              child: const Text('Review'),
            ),
            onTap: () => context.push(RoutePaths.reviewFor(order.id)),
          );
        },
      ),
    );
  }
}
