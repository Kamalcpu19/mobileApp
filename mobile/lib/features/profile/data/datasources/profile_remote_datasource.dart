import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_models.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);

  final ApiClient _client;

  Future<UserProfileModel> getProfile() async {
    final response = await _client.get<Map<String, dynamic>>('${ApiConstants.auth}/profile');
    return UserProfileModel.fromJson(response.data!);
  }

  Future<AutomationSettingsModel> getAutomationSettings() async {
    final response = await _client.get<Map<String, dynamic>>('${ApiConstants.ai}/settings');
    return AutomationSettingsModel.fromJson(response.data!);
  }
}
