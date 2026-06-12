import 'package:flutter/material.dart';

import '../../domain/entities/estimate.dart';

class LineItemTile extends StatelessWidget {
  const LineItemTile({super.key, required this.item});

  final EstimateLineItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(item.itemType == 'part' ? Icons.build : Icons.handyman),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.partNumber != null) Text('P/N: ${item.partNumber}'),
            Text(
              'Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(0)}',
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${item.totalPrice.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              item.approvalStatus,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
