import 'package:flutter/material.dart';

import '../../domain/entities/repair_order.dart';

class RepairOrderCard extends StatelessWidget {
  const RepairOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final RepairOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order.roNumber,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  _StageChip(stage: order.stage),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.customerName ?? 'No customer'),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.directions_car, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(order.vehicleDisplay)),
                ],
              ),
              if (order.jobCardNumber != null) ...[
                const SizedBox(height: 4),
                Text('JC: ${order.jobCardNumber}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  const _StageChip({required this.stage});

  final String stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stage.replaceAll('_', ' ').toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
