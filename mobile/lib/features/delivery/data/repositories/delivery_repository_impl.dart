import '../../domain/entities/inspection_item.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/delivery_remote_datasource.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl(this._remoteDataSource);

  final DeliveryRemoteDataSource _remoteDataSource;

  @override
  Future<DeliveryOrderSummary> getOrderSummary(String repairOrderId) {
    return _remoteDataSource.getOrderSummary(repairOrderId);
  }

  @override
  Future<List<InspectionItem>> getInspectionItems(String repairOrderId, {String? type}) {
    return _remoteDataSource.getInspectionItems(repairOrderId, type: type);
  }

  @override
  Future<DeliveryOrderSummary> closeJobCard(
    String repairOrderId, {
    required int odometerOut,
    required DateTime nextServiceReminder,
  }) {
    return _remoteDataSource.closeJobCard(
      repairOrderId,
      odometerOut: odometerOut,
      nextServiceReminder: nextServiceReminder,
    );
  }

  @override
  Future<List<ServiceHistoryEntry>> getServiceHistory(String vehicleId) {
    return _remoteDataSource.getServiceHistory(vehicleId);
  }

  @override
  Future<Map<String, dynamic>?> getInvoice(String repairOrderId) {
    return _remoteDataSource.getInvoice(repairOrderId);
  }
}
