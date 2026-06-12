import 'package:flutter/material.dart';

import '../../domain/entities/estimate_line_item.dart';

class SwipeLineItemTile extends StatelessWidget {
  const SwipeLineItemTile({
    super.key,
    required this.item,
    required this.onApprove,
    required this.onReject,
    this.enabled = true,
  });

  final EstimateLineItem item;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = switch (item.approvalStatus) {
      LineItemApprovalStatus.approved => colorScheme.primary,
      LineItemApprovalStatus.rejected => colorScheme.error,
      LineItemApprovalStatus.pending => colorScheme.outline,
    };

    final statusLabel = switch (item.approvalStatus) {
      LineItemApprovalStatus.approved => 'Approved',
      LineItemApprovalStatus.rejected => 'Rejected',
      LineItemApprovalStatus.pending => 'Pending',
    };

    return Dismissible(
      key: ValueKey(item.id),
      direction: enabled ? DismissDirection.horizontal : DismissDirection.none,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onApprove();
        } else {
          onReject();
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text('Approve', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Reject', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Icon(Icons.cancel, color: colorScheme.error),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Chip(
                    label: Text(statusLabel, style: theme.textTheme.labelSmall),
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    side: BorderSide(color: statusColor.withValues(alpha: 0.4)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(item.description!, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} × '
                    '₹${item.unitPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (enabled) ...[
                const SizedBox(height: 8),
                Text(
                  'Swipe right to approve · left to reject',
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
