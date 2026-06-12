import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_counts.dart';

class DashboardRepositoryImpl {
  DashboardRepositoryImpl({required DashboardRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final DashboardRemoteDataSource _remoteDataSource;

  Future<DashboardCounts> getCounts() {
    return _remoteDataSource.getCounts();
  }
}
