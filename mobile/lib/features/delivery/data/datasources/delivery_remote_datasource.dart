import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/delivery_models.dart';

class DeliveryRemoteDataSource {
  DeliveryRemoteDataSource(this._client);

  final ApiClient _client;

  Future<DeliveryOrderSummaryModel> getOrderSummary(String repairOrderId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '${ApiConstants.repairOrders}/$repairOrderId',
    );
    return DeliveryOrderSummaryModel.fromJson(response.data!);
  }

  Future<List<InspectionItemModel>> getInspectionItems(
    String repairOrderId, {
    String? type,
  }) async {
    final response = await _client.get<List<dynamic>>(
      '${ApiConstants.inspections}/$repairOrderId',
      queryParameters: type != null ? {'type': type} : null,
    );
    return (response.data ?? [])
        .map((e) => InspectionItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeliveryOrderSummaryModel> closeJobCard(
    String repairOrderId, {
    required int odometerOut,
    required DateTime nextServiceReminder,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${ApiConstants.repairOrders}/$repairOrderId/close',
      data: {
        'odometerOut': odometerOut,
        'nextServiceReminder': nextServiceReminder.toIso8601String().split('T').first,
      },
    );
    return DeliveryOrderSummaryModel.fromJson(response.data!);
  }

  Future<List<ServiceHistoryEntryModel>> getServiceHistory(String vehicleId) async {
    final response = await _client.get<List<dynamic>>(
      '${ApiConstants.vehicles}/$vehicleId/service-history',
    );
    return (response.data ?? [])
        .map((e) => ServiceHistoryEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>?> getInvoice(String repairOrderId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/invoices/$repairOrderId');
      return response.data;
    } catch (_) {
      return null;
    }
  }
}
