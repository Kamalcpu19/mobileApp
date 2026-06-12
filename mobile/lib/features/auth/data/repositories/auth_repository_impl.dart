import '../../../../core/network/api_client.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  User? _cachedUser;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      username: username,
      password: password,
    );
    _cachedUser = result.user.toEntity();
    return _cachedUser!;
  }

  @override
  Future<void> logout() async {
    _cachedUser = null;
    await clearAuthSession(_tokenStorage);
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser;
    final profile = await _remoteDataSource.getProfile();
    _cachedUser = profile.toEntity();
    return _cachedUser;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _tokenStorage.hasAccessToken();
  }
}
