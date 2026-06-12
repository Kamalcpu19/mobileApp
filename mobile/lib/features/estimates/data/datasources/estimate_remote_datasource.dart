import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/estimate_model.dart';

class EstimateRemoteDatasource {
  EstimateRemoteDatasource(this._client);

  final ApiClient _client;

  Future<EstimateModel?> fetchEstimate(String repairOrderId) async {
    try {
      final response =
          await _client.get('${ApiConstants.estimates}/$repairOrderId');
      return EstimateModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException catch (_) {
      return null;
    }
  }

  Future<EstimateModel> createEstimate(String repairOrderId) async {
    final response =
        await _client.post('${ApiConstants.estimates}/$repairOrderId');
    return EstimateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EstimateLineItemModel> addLineItem(
    String estimateId,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      '${ApiConstants.estimates}/$estimateId/items',
      data: body,
    );
    return EstimateLineItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EstimateModel> submitForApproval(String estimateId) async {
    final response =
        await _client.post('${ApiConstants.estimates}/$estimateId/submit');
    return EstimateModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EstimateModel> generateAiEstimate(String repairOrderId) async {
    final response =
        await _client.post('${ApiConstants.ai}/estimate/$repairOrderId');
    final data = response.data;
    return EstimateModel.fromJson(
      data is Map && data['estimate'] != null
          ? data['estimate'] as Map<String, dynamic>
          : data as Map<String, dynamic>,
    );
  }
}
