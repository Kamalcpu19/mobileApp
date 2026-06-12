import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/inspection_item.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../../data/datasources/delivery_remote_datasource.dart';
import '../../data/repositories/delivery_repository_impl.dart';

final deliveryRemoteDataSourceProvider = Provider<DeliveryRemoteDataSource>((ref) {
  return DeliveryRemoteDataSource(ref.watch(apiClientProvider));
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepositoryImpl(ref.watch(deliveryRemoteDataSourceProvider));
});

class DeliveryReviewState {
  const DeliveryReviewState({
    this.order,
    this.preInspection = const [],
    this.postInspection = const [],
    this.isLoading = false,
    this.error,
  });

  final DeliveryOrderSummary? order;
  final List<InspectionItem> preInspection;
  final List<InspectionItem> postInspection;
  final bool isLoading;
  final String? error;

  List<InspectionItem> get changedItems {
    final postByName = {for (final item in postInspection) item.itemName: item};
    return preInspection.where((pre) {
      final post = postByName[pre.itemName];
      return post != null && pre.status != post.status;
    }).toList();
  }

  DeliveryReviewState copyWith({
    DeliveryOrderSummary? order,
    List<InspectionItem>? preInspection,
    List<InspectionItem>? postInspection,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DeliveryReviewState(
      order: order ?? this.order,
      preInspection: preInspection ?? this.preInspection,
      postInspection: postInspection ?? this.postInspection,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DeliveryReviewNotifier extends StateNotifier<DeliveryReviewState> {
  DeliveryReviewNotifier(this._repository, this.repairOrderId)
      : super(const DeliveryReviewState()) {
    load();
  }

  final DeliveryRepository _repository;
  final String repairOrderId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repository.getOrderSummary(repairOrderId),
        _repository.getInspectionItems(repairOrderId, type: 'pre'),
        _repository.getInspectionItems(repairOrderId, type: 'post'),
      ]);
      state = DeliveryReviewState(
        order: results[0] as DeliveryOrderSummary,
        preInspection: results[1] as List<InspectionItem>,
        postInspection: results[2] as List<InspectionItem>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final deliveryReviewProvider = StateNotifierProvider.autoDispose
    .family<DeliveryReviewNotifier, DeliveryReviewState, String>((ref, repairOrderId) {
  return DeliveryReviewNotifier(ref.watch(deliveryRepositoryProvider), repairOrderId);
});

class CloseJobCardState {
  const CloseJobCardState({
    this.order,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  final DeliveryOrderSummary? order;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final bool submitted;

  CloseJobCardState copyWith({
    DeliveryOrderSummary? order,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool? submitted,
    bool clearError = false,
  }) {
    return CloseJobCardState(
      order: order ?? this.order,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      submitted: submitted ?? this.submitted,
    );
  }
}

class CloseJobCardNotifier extends StateNotifier<CloseJobCardState> {
  CloseJobCardNotifier(this._repository, this.repairOrderId)
      : super(const CloseJobCardState()) {
    load();
  }

  final DeliveryRepository _repository;
  final String repairOrderId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final order = await _repository.getOrderSummary(repairOrderId);
      state = state.copyWith(order: order, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submit({
    required int odometerOut,
    required DateTime nextServiceReminder,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final order = await _repository.closeJobCard(
        repairOrderId,
        odometerOut: odometerOut,
        nextServiceReminder: nextServiceReminder,
      );
      state = state.copyWith(order: order, isSubmitting: false, submitted: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final closeJobCardProvider = StateNotifierProvider.autoDispose
    .family<CloseJobCardNotifier, CloseJobCardState, String>((ref, repairOrderId) {
  return CloseJobCardNotifier(ref.watch(deliveryRepositoryProvider), repairOrderId);
});

class DeliveredState {
  const DeliveredState({
    this.order,
    this.invoice,
    this.serviceHistory = const [],
    this.isLoading = false,
    this.error,
  });

  final DeliveryOrderSummary? order;
  final Map<String, dynamic>? invoice;
  final List<ServiceHistoryEntry> serviceHistory;
  final bool isLoading;
  final String? error;
}

class DeliveredNotifier extends StateNotifier<DeliveredState> {
  DeliveredNotifier(this._repository, this.repairOrderId) : super(const DeliveredState()) {
    load();
  }

  final DeliveryRepository _repository;
  final String repairOrderId;

  Future<void> load() async {
    state = const DeliveredState(isLoading: true);
    try {
      final order = await _repository.getOrderSummary(repairOrderId);
      final invoice = await _repository.getInvoice(repairOrderId);
      List<ServiceHistoryEntry> history = [];
      if (order.vehicleId != null) {
        history = await _repository.getServiceHistory(order.vehicleId!);
      }
      state = DeliveredState(
        order: order,
        invoice: invoice,
        serviceHistory: history,
        isLoading: false,
      );
    } catch (e) {
      state = DeliveredState(isLoading: false, error: e.toString());
    }
  }
}

final deliveredProvider = StateNotifierProvider.autoDispose
    .family<DeliveredNotifier, DeliveredState, String>((ref, repairOrderId) {
  return DeliveredNotifier(ref.watch(deliveryRepositoryProvider), repairOrderId);
});
