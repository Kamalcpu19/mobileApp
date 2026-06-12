import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/spare.dart';
import '../../domain/entities/workflow_order.dart';
import '../../domain/repositories/workflow_repository.dart';
import '../../data/datasources/workflow_remote_datasource.dart';
import '../../data/repositories/workflow_repository_impl.dart';

final workflowRemoteDataSourceProvider = Provider<WorkflowRemoteDataSource>((ref) {
  return WorkflowRemoteDataSource(ref.watch(apiClientProvider));
});

final workflowRepositoryProvider = Provider<WorkflowRepository>((ref) {
  return WorkflowRepositoryImpl(ref.watch(workflowRemoteDataSourceProvider));
});

class WorkflowListState {
  const WorkflowListState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  final List<WorkflowOrder> orders;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  WorkflowListState copyWith({
    List<WorkflowOrder>? orders,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool clearError = false,
  }) {
    return WorkflowListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class WorkflowListNotifier extends StateNotifier<WorkflowListState> {
  WorkflowListNotifier(this._repository, this.stage) : super(const WorkflowListState()) {
    load();
  }

  final WorkflowRepository _repository;
  final String stage;

  Future<void> load({String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true, searchQuery: search ?? state.searchQuery);
    try {
      final orders = await _repository.getOrdersByStage(stage, search: state.searchQuery);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    load(search: query);
  }
}

final sparesPendingProvider = StateNotifierProvider.autoDispose<WorkflowListNotifier, WorkflowListState>((ref) {
  return WorkflowListNotifier(ref.watch(workflowRepositoryProvider), 'spares_pending');
});

final workInProgressProvider = StateNotifierProvider.autoDispose<WorkflowListNotifier, WorkflowListState>((ref) {
  return WorkflowListNotifier(ref.watch(workflowRepositoryProvider), 'work_in_progress');
});

final readyForDeliveryProvider = StateNotifierProvider.autoDispose<WorkflowListNotifier, WorkflowListState>((ref) {
  return WorkflowListNotifier(ref.watch(workflowRepositoryProvider), 'ready_for_delivery');
});

class WorkInProgressDetailState {
  const WorkInProgressDetailState({
    this.order,
    this.timeline = const [],
    this.jobCard,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
  });

  final WorkflowOrder? order;
  final List<StageTimelineEntry> timeline;
  final Map<String, dynamic>? jobCard;
  final bool isLoading;
  final bool isUpdating;
  final String? error;

  WorkInProgressDetailState copyWith({
    WorkflowOrder? order,
    List<StageTimelineEntry>? timeline,
    Map<String, dynamic>? jobCard,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    bool clearError = false,
  }) {
    return WorkInProgressDetailState(
      order: order ?? this.order,
      timeline: timeline ?? this.timeline,
      jobCard: jobCard ?? this.jobCard,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WorkInProgressDetailNotifier extends StateNotifier<WorkInProgressDetailState> {
  WorkInProgressDetailNotifier(this._repository, this.repairOrderId)
      : super(const WorkInProgressDetailState()) {
    load();
  }

  final WorkflowRepository _repository;
  final String repairOrderId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.getOrderById(repairOrderId),
        _repository.getTimeline(repairOrderId),
        _repository.getJobCard(repairOrderId),
      ]);
      state = state.copyWith(
        order: results[0] as WorkflowOrder,
        timeline: results[1] as List<StageTimelineEntry>,
        jobCard: results[2] as Map<String, dynamic>?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> markComplete() async {
    state = state.copyWith(isUpdating: true, clearError: true);
    try {
      final order = await _repository.updateStage(
        repairOrderId,
        'ready_for_delivery',
        notes: 'Repair completed',
      );
      state = state.copyWith(order: order, isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
      return false;
    }
  }
}

final workInProgressDetailProvider = StateNotifierProvider.autoDispose
    .family<WorkInProgressDetailNotifier, WorkInProgressDetailState, String>((ref, repairOrderId) {
  return WorkInProgressDetailNotifier(ref.watch(workflowRepositoryProvider), repairOrderId);
});

class SparesDetailState {
  const SparesDetailState({
    this.spares = const [],
    this.order,
    this.isLoading = false,
    this.error,
  });

  final List<Spare> spares;
  final WorkflowOrder? order;
  final bool isLoading;
  final String? error;
}

class SparesDetailNotifier extends StateNotifier<SparesDetailState> {
  SparesDetailNotifier(this._repository, this.repairOrderId) : super(const SparesDetailState()) {
    load();
  }

  final WorkflowRepository _repository;
  final String repairOrderId;

  Future<void> load() async {
    state = const SparesDetailState(isLoading: true);
    try {
      final results = await Future.wait([
        _repository.getSparesForOrder(repairOrderId),
        _repository.getOrderById(repairOrderId),
      ]);
      state = SparesDetailState(
        spares: results[0] as List<Spare>,
        order: results[1] as WorkflowOrder,
        isLoading: false,
      );
    } catch (e) {
      state = SparesDetailState(isLoading: false, error: e.toString());
    }
  }
}

final sparesDetailProvider = StateNotifierProvider.autoDispose
    .family<SparesDetailNotifier, SparesDetailState, String>((ref, repairOrderId) {
  return SparesDetailNotifier(ref.watch(workflowRepositoryProvider), repairOrderId);
});
