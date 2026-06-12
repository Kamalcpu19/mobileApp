import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getProfile() {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<AutomationSettings> getAutomationSettings() {
    return _remoteDataSource.getAutomationSettings();
  }
}
