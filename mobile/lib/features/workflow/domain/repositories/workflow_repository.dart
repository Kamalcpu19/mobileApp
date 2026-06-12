import '../entities/spare.dart';
import '../entities/workflow_order.dart';

abstract class WorkflowRepository {
  Future<List<WorkflowOrder>> getOrdersByStage(String stage, {String? search});

  Future<WorkflowOrder> getOrderById(String id);

  Future<List<StageTimelineEntry>> getTimeline(String repairOrderId);

  Future<List<Spare>> getSparesForOrder(String repairOrderId);

  Future<WorkflowOrder> updateStage(String repairOrderId, String stage, {String? notes});

  Future<Map<String, dynamic>?> getJobCard(String repairOrderId);
}
