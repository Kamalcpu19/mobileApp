import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/repair_order.dart';

class ProgressTimeline extends StatelessWidget {
  const ProgressTimeline({super.key, required this.entries});

  final List<StageHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No stage history yet'),
      );
    }

    final dateFormat = DateFormat('dd MMM, HH:mm');
    final sorted = List<StageHistoryEntry>.from(entries)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final entry = sorted[index];
        final isLast = index == sorted.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isLast
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.toStage.replaceAll('_', ' ').toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        dateFormat.format(entry.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (entry.notes != null && entry.notes!.isNotEmpty)
                        Text(entry.notes!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
