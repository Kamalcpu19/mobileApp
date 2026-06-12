import '../entities/repair_order.dart';

abstract class RepairOrderRepository {
  Future<List<RepairOrder>> getRepairOrders({String? stage, String? search});

  Future<RepairOrder> getRepairOrderById(String id);

  Future<RepairOrder> createRepairOrder({
    String? customerId,
    String? vehicleId,
    String? appointmentId,
    String? detectionStatus,
    int? odometerIn,
  });

  Future<List<StageHistoryEntry>> getStageHistory(String repairOrderId);

  Future<List<String>> getStages();
}
