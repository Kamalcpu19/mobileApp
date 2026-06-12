import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart' show AppColors;
import '../../domain/entities/inspection_item.dart';

class InspectionSwipeTile extends StatelessWidget {
  const InspectionSwipeTile({
    super.key,
    required this.item,
    required this.onStatusChanged,
    required this.onCommentChanged,
    required this.onImageTap,
  });

  final InspectionItem item;
  final ValueChanged<InspectionStatus> onStatusChanged;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onImageTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          ListTile(
            title: Text(item.itemName),
            subtitle: Text(item.category),
            trailing: _StatusBadge(status: item.status),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatusButton(
                  label: 'OK',
                  color: AppColors.successGreen,
                  selected: item.status == InspectionStatus.ok,
                  onTap: () => onStatusChanged(InspectionStatus.ok),
                ),
                const SizedBox(width: 8),
                _StatusButton(
                  label: 'Action',
                  color: AppColors.warningAmber,
                  selected: item.status == InspectionStatus.actionRequired,
                  onTap: () =>
                      onStatusChanged(InspectionStatus.actionRequired),
                ),
                const SizedBox(width: 8),
                _StatusButton(
                  label: 'Urgent',
                  color: AppColors.urgentRed,
                  selected: item.status == InspectionStatus.urgent,
                  onTap: () => onStatusChanged(InspectionStatus.urgent),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Add comment...',
                      isDense: true,
                    ),
                    controller: TextEditingController(text: item.comment ?? '')
                      ..selection = TextSelection.collapsed(
                        offset: (item.comment ?? '').length,
                      ),
                    onSubmitted: onCommentChanged,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    item.imageUrl != null ? Icons.image : Icons.add_a_photo,
                    color: item.imageUrl != null ? Colors.green : null,
                  ),
                  onPressed: onImageTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final InspectionStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case InspectionStatus.ok:
        color = AppColors.successGreen;
        label = 'OK';
      case InspectionStatus.actionRequired:
        color = AppColors.warningAmber;
        label = 'Action';
      case InspectionStatus.urgent:
        color = AppColors.urgentRed;
        label = 'Urgent';
      case InspectionStatus.pending:
        color = Colors.grey;
        label = 'Pending';
    }
    return Chip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
