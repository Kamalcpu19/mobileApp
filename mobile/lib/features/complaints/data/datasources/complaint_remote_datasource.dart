import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/complaint_model.dart';

class ComplaintRemoteDatasource {
  ComplaintRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<ComplaintModel>> fetchComplaints(String repairOrderId) async {
    final response = await _client.get('${ApiConstants.complaints}/$repairOrderId');
    final data = response.data as List;
    return data
        .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ComplaintModel> addComplaint(
    String repairOrderId,
    String description, {
    String source = 'manual',
  }) async {
    final response = await _client.post(
      '${ApiConstants.complaints}/$repairOrderId',
      data: {'description': description, 'source': source},
    );
    return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AiRecommendationModel>> analyzeComplaints(
    String repairOrderId,
  ) async {
    final response = await _client.post(
      '${ApiConstants.complaints}/$repairOrderId/analyze',
    );
    final data = response.data;
    final list = data is Map ? data['recommendations'] ?? [] : data;
    return (list as List)
        .map((e) => AiRecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AiRecommendationModel>> fetchRecommendations(
    String repairOrderId,
  ) async {
    final response =
        await _client.get('${ApiConstants.ai}/recommendations/$repairOrderId');
    final data = response.data as List;
    return data
        .map((e) => AiRecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AiRecommendationModel> toggleRecommendation(
    String id,
    bool isSelected,
  ) async {
    final response = await _client.patch(
      '${ApiConstants.ai}/recommendations/$id/select',
      data: {'isSelected': isSelected},
    );
    return AiRecommendationModel.fromJson(response.data as Map<String, dynamic>);
  }
}
