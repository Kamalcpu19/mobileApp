/// Central route path constants for [GoRouter] configuration.
abstract final class RoutePaths {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const appointments = '/appointments';
  static const createRo = '/create-ro';
  static const repairOrders = '/repair-orders';
  static const sparesPending = '/workflow/spares-pending';
  static const workInProgress = '/workflow/wip';
  static const readyForDelivery = '/workflow/ready-delivery';
  static const vehicleDetection = '/repair-orders/:roId/vehicle-detection';
  static const vehicleImages = '/repair-orders/:roId/vehicle-images';
  static const preInspection = '/repair-orders/:roId/pre-inspection';
  static const complaints = '/repair-orders/:roId/complaints';
  static const aiRecommendations = '/repair-orders/:roId/ai-recommendations';
  static const jobCard = '/repair-orders/:roId/job-card';
  static const vehicleAttention = '/repair-orders/:roId/vehicle-attention';
  static const estimation = '/repair-orders/:roId/estimation';
  static const approval = '/repair-orders/:roId/approval';
  static const spares = '/repair-orders/:roId/spares';
  static const wip = '/repair-orders/:roId/wip';
  static const readyDelivery = '/repair-orders/:roId/ready-delivery';
  static const preDeliveryChecklist =
      '/repair-orders/:roId/pre-delivery-checklist';
  static const review = '/repair-orders/:roId/review';
  static const invoice = '/repair-orders/:roId/invoice';
  static const closeJob = '/repair-orders/:roId/close-job';
  static const delivered = '/delivered';
  static const pendingPayments = '/pending-payments';
  static const profile = '/profile';
  static const automationSettings = '/settings/automation';
  static const workspaceSettings = '/settings/workspace';

  static const sparesPendingList = '/workflow/spares-pending';
  static const wipList = '/workflow/wip';
  static const readyDeliveryList = '/workflow/ready-delivery';
  static const customerApprovalToken = '/approve/:token';

  static String customerApprovalFor(String token) => '/approve/$token';

  static String createRoFor(String appointmentId) =>
      '/appointments/$appointmentId/create-ro';

  static String vehicleDetectionFor(String roId) =>
      '/repair-orders/$roId/vehicle-detection';

  static String vehicleImagesFor(String roId) =>
      '/repair-orders/$roId/vehicle-images';

  static String preInspectionFor(String roId) =>
      '/repair-orders/$roId/pre-inspection';

  static String complaintsFor(String roId) =>
      '/repair-orders/$roId/complaints';

  static String aiRecommendationsFor(String roId) =>
      '/repair-orders/$roId/ai-recommendations';

  static String jobCardFor(String roId) => '/repair-orders/$roId/job-card';

  static String vehicleAttentionFor(String roId) =>
      '/repair-orders/$roId/vehicle-attention';

  static String estimationFor(String roId) =>
      '/repair-orders/$roId/estimation';

  static String approvalFor(String roId) => '/repair-orders/$roId/approval';

  static String sparesFor(String roId) => '/repair-orders/$roId/spares';

  static String wipFor(String roId) => '/repair-orders/$roId/wip';

  static String readyDeliveryFor(String roId) =>
      '/repair-orders/$roId/ready-delivery';

  static String preDeliveryChecklistFor(String roId) =>
      '/repair-orders/$roId/pre-delivery-checklist';

  static String reviewFor(String roId) => '/repair-orders/$roId/review';

  static String invoiceFor(String roId) => '/repair-orders/$roId/invoice';

  static String closeJobFor(String roId) => '/repair-orders/$roId/close-job';
}
