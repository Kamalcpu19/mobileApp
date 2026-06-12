/// Application-wide constants aligned with the backend repair-order workflow.
abstract final class AppConstants {
  static const String appName = 'Workshop Service Advisor';
  static const String appVersion = '1.0.0';

  /// Repair-order pipeline stages (matches backend `repairOrderService.STAGES`).
  static const List<String> repairOrderStages = [
    'inspection',
    'estimation_request',
    'estimate',
    'approval_pending',
    'spares_pending',
    'work_in_progress',
    'ready_for_delivery',
    'invoice',
    'delivered',
  ];

  /// Human-readable labels for repair-order stages.
  static const Map<String, String> stageLabels = {
    'inspection': 'Inspection',
    'estimation_request': 'Estimation Request',
    'estimate': 'Estimate',
    'approval_pending': 'Approval Pending',
    'spares_pending': 'Spares Pending',
    'work_in_progress': 'Work In Progress',
    'ready_for_delivery': 'Ready for Delivery',
    'invoice': 'Invoice',
    'delivered': 'Delivered',
  };

  /// Pre-inspection item statuses used by swipe gestures and API updates.
  static const String inspectionStatusPending = 'pending';
  static const String inspectionStatusOk = 'ok';
  static const String inspectionStatusActionRequired = 'action_required';
  static const String inspectionStatusUrgent = 'urgent';
  static const String inspectionStatusConcern = 'concern';

  static const List<String> inspectionStatuses = [
    inspectionStatusPending,
    inspectionStatusOk,
    inspectionStatusActionRequired,
    inspectionStatusUrgent,
    inspectionStatusConcern,
  ];

  static const Map<String, String> inspectionStatusLabels = {
    inspectionStatusPending: 'Pending',
    inspectionStatusOk: 'OK',
    inspectionStatusActionRequired: 'Action Required',
    inspectionStatusUrgent: 'Urgent',
    inspectionStatusConcern: 'Concern',
  };

  static const List<String> supportedLocales = ['en', 'ar'];
  static const String defaultLocale = 'en';

  static const double shortSwipeThreshold = 80;
  static const double longSwipeThreshold = 160;
}
