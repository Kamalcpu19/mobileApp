import '../../domain/entities/repair_order.dart';
import '../../domain/repositories/repair_order_repository.dart';
import '../datasources/repair_order_remote_datasource.dart';

class RepairOrderRepositoryImpl implements RepairOrderRepository {
  RepairOrderRepositoryImpl(this._datasource);

  final RepairOrderRemoteDatasource _datasource;

  @override
  Future<List<RepairOrder>> getRepairOrders({String? stage, String? search}) {
    return _datasource.fetchRepairOrders(stage: stage, search: search);
  }

  @override
  Future<RepairOrder> getRepairOrderById(String id) {
    return _datasource.fetchRepairOrderById(id);
  }

  @override
  Future<RepairOrder> createRepairOrder({
    String? customerId,
    String? vehicleId,
    String? appointmentId,
    String? detectionStatus,
    int? odometerIn,
  }) {
    return _datasource.createRepairOrder({
      if (customerId != null) 'customerId': customerId,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (appointmentId != null) 'appointmentId': appointmentId,
      if (detectionStatus != null) 'detectionStatus': detectionStatus,
      if (odometerIn != null) 'odometerIn': odometerIn,
    });
  }

  @override
  Future<List<StageHistoryEntry>> getStageHistory(String repairOrderId) {
    return _datasource.fetchStageHistory(repairOrderId);
  }

  @override
  Future<List<String>> getStages() {
    return _datasource.fetchStages();
  }
}
