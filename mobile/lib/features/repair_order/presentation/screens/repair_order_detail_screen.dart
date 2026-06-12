import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repair_order_providers.dart';
import '../widgets/progress_timeline.dart';

class RepairOrderDetailScreen extends ConsumerWidget {
  const RepairOrderDetailScreen({super.key, required this.roId});

  final String roId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(repairOrderDetailProvider(roId));
    final timelineAsync = ref.watch(stageHistoryProvider(roId));

    return Scaffold(
      appBar: AppBar(title: const Text('Repair Order')),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (order) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.roNumber,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text('Stage: ${order.stage.replaceAll('_', ' ')}'),
                      const Divider(),
                      Text(order.customerName ?? 'No customer'),
                      Text(order.customerMobile ?? ''),
                      const SizedBox(height: 8),
                      Text(order.vehicleDisplay),
                      if (order.odometerIn != null)
                        Text('Odometer In: ${order.odometerIn} km'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Progress Timeline',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: timelineAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (entries) => ProgressTimeline(entries: entries),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ActionButton(
                icon: Icons.camera_alt,
                label: 'Vehicle Detection',
                onPressed: () => context.push('/vehicle-detection/$roId'),
              ),
              _ActionButton(
                icon: Icons.photo_library,
                label: 'Vehicle Images',
                onPressed: () => context.push('/vehicle-images/$roId'),
              ),
              _ActionButton(
                icon: Icons.edit,
                label: 'Edit Vehicle Info',
                onPressed: () => context.push('/vehicle-info/$roId'),
              ),
              if (order.vehicleId != null)
                _ActionButton(
                  icon: Icons.history,
                  label: 'Service History',
                  onPressed: () =>
                      context.push('/vehicle-history/${order.vehicleId}'),
                ),
              _ActionButton(
                icon: Icons.checklist,
                label: 'Pre-Inspection',
                onPressed: () => context.push('/inspection/$roId'),
              ),
              _ActionButton(
                icon: Icons.fact_check,
                label: 'Pre-Delivery Checklist',
                onPressed: () => context.push('/pre-delivery/$roId'),
              ),
              _ActionButton(
                icon: Icons.report_problem,
                label: 'Complaints',
                onPressed: () => context.push('/complaints/$roId'),
              ),
              _ActionButton(
                icon: Icons.request_quote,
                label: 'Estimates',
                onPressed: () => context.push('/estimates/$roId'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }
}
