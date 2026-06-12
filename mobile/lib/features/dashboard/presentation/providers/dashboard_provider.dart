import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/models/dashboard_counts.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.counts = DashboardCounts.empty,
    this.errorMessage,
  });

  final DashboardStatus status;
  final DashboardCounts counts;
  final String? errorMessage;

  bool get isLoading => status == DashboardStatus.loading;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardCounts? counts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      counts: counts ?? this.counts,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>(
  (ref) => DashboardRemoteDataSource(ref.watch(apiClientProvider)),
);

final dashboardRepositoryProvider = Provider<DashboardRepositoryImpl>(
  (ref) => DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
  ),
);

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._repository) : super(const DashboardState()) {
    loadCounts();
  }

  final DashboardRepositoryImpl _repository;

  Future<void> loadCounts() async {
    state = state.copyWith(
      status: DashboardStatus.loading,
      clearError: true,
    );

    try {
      final counts = await _repository.getCounts();
      state = state.copyWith(
        status: DashboardStatus.loaded,
        counts: counts,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: DashboardStatus.error,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> refresh() => loadCounts();
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});
