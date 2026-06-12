import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<({String token, UserModel user})> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      '${ApiConstants.auth}/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    await persistAuthTokens(_tokenStorage, data);

    return (
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<UserModel> getProfile() async {
    final response = await _client.get('${ApiConstants.auth}/profile');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
