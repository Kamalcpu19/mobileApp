import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/vehicle_providers.dart';

class ServiceHistoryScreen extends ConsumerWidget {
  const ServiceHistoryScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(serviceHistoryProvider(vehicleId));
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Service History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No service history found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(dateFormat.format(entry.serviceDate)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.description != null) Text(entry.description!),
                      if (entry.odometer != null)
                        Text('Odometer: ${entry.odometer} km'),
                    ],
                  ),
                  trailing: entry.totalAmount != null
                      ? Text(
                          '₹${entry.totalAmount!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleSmall,
                        )
                      : null,
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
