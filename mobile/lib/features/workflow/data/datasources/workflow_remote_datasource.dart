import '../../../../core/network/api_client.dart';
import '../models/workflow_order_model.dart';

class WorkflowRemoteDataSource {
  WorkflowRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<WorkflowOrderModel>> getOrdersByStage(String stage, {String? search}) async {
    final response = await _client.get<List<dynamic>>(
      '/repair-orders',
      queryParameters: {
        'stage': stage,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return (response.data ?? [])
        .map((e) => WorkflowOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WorkflowOrderModel> getOrderById(String id) async {
    final response = await _client.get<Map<String, dynamic>>('/repair-orders/$id');
    return WorkflowOrderModel.fromJson(response.data!);
  }

  Future<List<StageTimelineEntryModel>> getTimeline(String repairOrderId) async {
    final response = await _client.get<List<dynamic>>('/repair-orders/$repairOrderId/timeline');
    return (response.data ?? [])
        .map((e) => StageTimelineEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SpareModel>> getSparesForOrder(String repairOrderId) async {
    final response = await _client.get<Map<String, dynamic>>('/estimates/$repairOrderId');
    final data = response.data;
    if (data == null) return [];

    final lineItems = data['lineItems'] as List<dynamic>? ?? [];
    return lineItems
        .where((item) => (item as Map<String, dynamic>)['item_type'] == 'part')
        .map((item) {
          final map = item as Map<String, dynamic>;
          return SpareModel(
            id: map['id'] as String,
            partName: map['name'] as String,
            partNumber: map['part_number'] as String?,
            quantity: SpareModel._toDouble(map['quantity']),
            status: map['approval_status'] as String? ?? 'pending',
            repairOrderId: repairOrderId,
          );
        })
        .toList();
  }

  Future<WorkflowOrderModel> updateStage(
    String repairOrderId,
    String stage, {
    String? notes,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/repair-orders/$repairOrderId/stage',
      data: {
        'stage': stage,
        if (notes != null) 'notes': notes,
      },
    );
    return WorkflowOrderModel.fromJson(response.data!);
  }

  Future<Map<String, dynamic>?> getJobCard(String repairOrderId) async {
    try {
      final order = await getOrderById(repairOrderId);
      if (order.jobCardNumber == null) return null;
      return {
        'job_card_number': order.jobCardNumber,
        'repair_order_id': repairOrderId,
        'ro_number': order.roNumber,
        'status': 'active',
      };
    } catch (_) {
      return null;
    }
  }
}
