import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_counts.dart';

class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._client);

  final ApiClient _client;

  Future<DashboardCounts> getCounts() async {
    final response = await _client.get('${ApiConstants.dashboard}/counts');
    return DashboardCounts.fromJson(response.data as Map<String, dynamic>);
  }
}
