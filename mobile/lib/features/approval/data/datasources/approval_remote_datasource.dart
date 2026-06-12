import '../../../../core/network/api_client.dart';
import '../models/estimate_model.dart';

class ApprovalRemoteDataSource {
  ApprovalRemoteDataSource(this._client);

  final ApiClient _client;

  Future<EstimateModel> getEstimateByToken(String token) async {
    final response = await _client.get<Map<String, dynamic>>('/estimates/approve/$token');
    return EstimateModel.fromJson(response.data!);
  }

  Future<EstimateModel> submitApprovals(
    String token,
    List<Map<String, String>> approvals,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/estimates/approve/$token',
      data: {'approvals': approvals},
    );
    return EstimateModel.fromJson(response.data!);
  }
}
