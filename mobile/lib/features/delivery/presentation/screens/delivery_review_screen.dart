import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/delivery_provider.dart';
import '../widgets/before_after_comparison.dart';

class DeliveryReviewScreen extends ConsumerWidget {
  const DeliveryReviewScreen({super.key, required this.repairOrderId});

  final String repairOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryReviewProvider(repairOrderId));
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return AppScaffold(
      title: 'Delivery Review',
      body: _buildBody(context, state, isWide),
    );
  }

  Widget _buildBody(BuildContext context, DeliveryReviewState state, bool isWide) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading inspection summary...');
    }

    if (state.error != null && state.order == null) {
      return AppErrorWidget(message: state.error!);
    }

    final order = state.order!;
    final theme = Theme.of(context);
    final issues = [
      ...state.preInspection.where((i) => i.isIssue),
      ...state.postInspection.where((i) => i.isIssue),
    ];

    return ListView(
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
        BeforeAfterComparison(
          preItems: state.preInspection,
          postItems: state.postInspection,
        ),
        const SizedBox(height: 16),
        Text('Inspection Summary', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryStat(
                  label: 'Pre-inspection items',
                  value: '${state.preInspection.length}',
                ),
                _SummaryStat(
                  label: 'Post-inspection items',
                  value: '${state.postInspection.length}',
                ),
                _SummaryStat(
                  label: 'Status changes',
                  value: '${state.changedItems.length}',
                ),
                _SummaryStat(
                  label: 'Open issues',
                  value: '${issues.length}',
                  highlight: issues.isNotEmpty,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.push(RoutePaths.closeJobFor(repairOrderId)),
          child: const Text('Proceed to Close Job Card'),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: highlight ? theme.colorScheme.error : null,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
