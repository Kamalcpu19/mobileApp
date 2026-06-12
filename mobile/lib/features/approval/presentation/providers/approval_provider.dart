import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/estimate.dart';
import '../../domain/entities/estimate_line_item.dart';
import '../../domain/repositories/approval_repository.dart';
import '../../data/datasources/approval_remote_datasource.dart';
import '../../data/repositories/approval_repository_impl.dart';

final approvalRemoteDataSourceProvider = Provider<ApprovalRemoteDataSource>((ref) {
  return ApprovalRemoteDataSource(ref.watch(apiClientProvider));
});

final approvalRepositoryProvider = Provider<ApprovalRepository>((ref) {
  return ApprovalRepositoryImpl(ref.watch(approvalRemoteDataSourceProvider));
});

class ApprovalState {
  const ApprovalState({
    this.estimate,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  final Estimate? estimate;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final bool submitted;

  ApprovalState copyWith({
    Estimate? estimate,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool? submitted,
    bool clearError = false,
  }) {
    return ApprovalState(
      estimate: estimate ?? this.estimate,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      submitted: submitted ?? this.submitted,
    );
  }
}

class ApprovalNotifier extends StateNotifier<ApprovalState> {
  ApprovalNotifier(this._repository) : super(const ApprovalState());

  final ApprovalRepository _repository;

  Future<void> loadEstimate(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final estimate = await _repository.getEstimateByToken(token);
      state = state.copyWith(estimate: estimate, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateItemStatus(String itemId, LineItemApprovalStatus status) {
    final estimate = state.estimate;
    if (estimate == null) return;

    final updatedItems = estimate.lineItems
        .map(
          (item) => item.id == itemId ? item.copyWith(approvalStatus: status) : item,
        )
        .toList();

    state = state.copyWith(
      estimate: Estimate(
        id: estimate.id,
        estimateNumber: estimate.estimateNumber,
        status: estimate.status,
        lineItems: updatedItems,
        subtotal: estimate.subtotal,
        taxAmount: estimate.taxAmount,
        totalAmount: estimate.totalAmount,
        repairOrderId: estimate.repairOrderId,
        approvalToken: estimate.approvalToken,
      ),
    );
  }

  void approveAll() {
    final estimate = state.estimate;
    if (estimate == null) return;

    final updatedItems = estimate.lineItems
        .map((item) => item.copyWith(approvalStatus: LineItemApprovalStatus.approved))
        .toList();

    state = state.copyWith(
      estimate: Estimate(
        id: estimate.id,
        estimateNumber: estimate.estimateNumber,
        status: estimate.status,
        lineItems: updatedItems,
        subtotal: estimate.subtotal,
        taxAmount: estimate.taxAmount,
        totalAmount: estimate.totalAmount,
        repairOrderId: estimate.repairOrderId,
        approvalToken: estimate.approvalToken,
      ),
    );
  }

  Future<void> submit(String token) async {
    final estimate = state.estimate;
    if (estimate == null) return;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final approvals = estimate.lineItems
          .map((item) => (itemId: item.id, status: item.approvalStatus))
          .toList();
      final result = await _repository.submitApprovals(token, approvals);
      state = state.copyWith(estimate: result, isSubmitting: false, submitted: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }
}

final approvalProvider = StateNotifierProvider.autoDispose
    .family<ApprovalNotifier, ApprovalState, String>((ref, token) {
  return ApprovalNotifier(ref.watch(approvalRepositoryProvider))..loadEstimate(token);
});
