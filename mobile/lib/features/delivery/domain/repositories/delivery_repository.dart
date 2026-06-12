import '../entities/inspection_item.dart';
import '../entities/delivery_order_summary.dart';

abstract class DeliveryRepository {
  Future<DeliveryOrderSummary> getOrderSummary(String repairOrderId);

  Future<List<InspectionItem>> getInspectionItems(String repairOrderId, {String? type});

  Future<DeliveryOrderSummary> closeJobCard(
    String repairOrderId, {
    required int odometerOut,
    required DateTime nextServiceReminder,
  });

  Future<List<ServiceHistoryEntry>> getServiceHistory(String vehicleId);

  Future<Map<String, dynamic>?> getInvoice(String repairOrderId);
}
