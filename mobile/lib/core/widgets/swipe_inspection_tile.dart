import 'package:flutter/material.dart';

import 'package:workshop_service_advisor/core/constants/app_constants.dart';
import 'package:workshop_service_advisor/core/theme/app_theme.dart';

typedef InspectionStatusCallback = void Function(String status);

/// Swipeable inspection row:
/// - Swipe right → OK
/// - Swipe left → Action Required
/// - Long swipe left → Urgent
class SwipeInspectionTile extends StatefulWidget {
  const SwipeInspectionTile({
    required this.title,
    required this.category,
    required this.status,
    required this.onStatusChanged,
    this.subtitle,
    this.comment,
    this.onCommentTap,
    super.key,
  });

  final String title;
  final String category;
  final String status;
  final String? subtitle;
  final String? comment;
  final InspectionStatusCallback onStatusChanged;
  final VoidCallback? onCommentTap;

  @override
  State<SwipeInspectionTile> createState() => _SwipeInspectionTileState();
}

class _SwipeInspectionTileState extends State<SwipeInspectionTile>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  late AnimationController _resetController;
  Animation<double>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        if (_resetAnimation != null) {
          setState(() => _dragOffset = _resetAnimation!.value);
        }
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _animateReset() {
    _resetAnimation = Tween<double>(
      begin: _dragOffset,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOut,
    ));
    _resetController.forward(from: 0);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final offset = _dragOffset;

    String? newStatus;

    if (offset > AppConstants.shortSwipeThreshold ||
        velocity > 800) {
      newStatus = AppConstants.inspectionStatusOk;
    } else if (offset < -AppConstants.longSwipeThreshold ||
        velocity < -1200) {
      newStatus = AppConstants.inspectionStatusUrgent;
    } else if (offset < -AppConstants.shortSwipeThreshold ||
        velocity < -800) {
      newStatus = AppConstants.inspectionStatusActionRequired;
    }

    if (newStatus != null && newStatus != widget.status) {
      widget.onStatusChanged(newStatus);
    }

    _animateReset();
  }

  Color _statusColor(String status) {
    return switch (status) {
      AppConstants.inspectionStatusOk => AppColors.successGreen,
      AppConstants.inspectionStatusActionRequired => AppColors.warningAmber,
      AppConstants.inspectionStatusUrgent => AppColors.urgentRed,
      AppConstants.inspectionStatusConcern => AppColors.accentOrange,
      _ => AppColors.steelGrey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(widget.status);
    final statusLabel =
        AppConstants.inspectionStatusLabels[widget.status] ?? widget.status;

    final backgroundHint = _dragOffset > 20
        ? AppColors.successGreen.withValues(alpha: 0.15)
        : _dragOffset < -AppConstants.longSwipeThreshold / 2
            ? AppColors.urgentRed.withValues(alpha: 0.15)
            : _dragOffset < -20
                ? AppColors.warningAmber.withValues(alpha: 0.15)
                : Colors.transparent;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundHint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: _dragOffset >= 0
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (_dragOffset > 20)
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.check_circle, color: AppColors.successGreen),
                  ),
                if (_dragOffset < -20)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      _dragOffset < -AppConstants.longSwipeThreshold / 2
                          ? Icons.priority_high
                          : Icons.build_circle_outlined,
                      color: _dragOffset < -AppConstants.longSwipeThreshold / 2
                          ? AppColors.urgentRed
                          : AppColors.warningAmber,
                    ),
                  ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() => _dragOffset += details.delta.dx);
          },
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(_dragOffset.clamp(-120, 120), 0),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.15),
                  child: Icon(Icons.car_repair, color: statusColor, size: 20),
                ),
                title: Text(widget.title, style: theme.textTheme.titleMedium),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(widget.subtitle!, style: theme.textTheme.bodySmall),
                    if (widget.comment != null && widget.comment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.comment!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    if (widget.onCommentTap != null)
                      IconButton(
                        icon: const Icon(Icons.comment_outlined, size: 20),
                        onPressed: widget.onCommentTap,
                        tooltip: 'Add comment',
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
