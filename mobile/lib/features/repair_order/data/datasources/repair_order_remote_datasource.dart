import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/repair_order_model.dart';

class RepairOrderRemoteDatasource {
  RepairOrderRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<RepairOrderModel>> fetchRepairOrders({
    String? stage,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (stage != null && stage != 'All') params['stage'] = stage;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _client.get(
      ApiConstants.repairOrders,
      queryParameters: params,
    );
    final data = response.data as List;
    return data
        .map((e) => RepairOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RepairOrderModel> fetchRepairOrderById(String id) async {
    final response = await _client.get('${ApiConstants.repairOrders}/$id');
    return RepairOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RepairOrderModel> createRepairOrder(Map<String, dynamic> body) async {
    final response =
        await _client.post(ApiConstants.repairOrders, data: body);
    return RepairOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<StageHistoryModel>> fetchStageHistory(String id) async {
    final response =
        await _client.get('${ApiConstants.repairOrders}/$id/timeline');
    final data = response.data as List;
    return data
        .map((e) => StageHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchStages() async {
    final response = await _client.get('${ApiConstants.repairOrders}/stages');
    return (response.data as List).cast<String>();
  }
}
