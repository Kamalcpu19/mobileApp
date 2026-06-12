import 'package:flutter/material.dart';

import '../../domain/entities/workflow_order.dart';

class WorkflowOrderCard extends StatelessWidget {
  const WorkflowOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.trailing,
  });

  final WorkflowOrder order;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(Icons.directions_car, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.roNumber,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(order.vehicleLabel, style: theme.textTheme.bodyMedium),
                    if (order.customerName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        order.customerName!,
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                    if (order.jobCardNumber != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'JC: ${order.jobCardNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ?? Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
