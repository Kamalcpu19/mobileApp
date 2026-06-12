import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/pending_payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../../data/datasources/payments_remote_datasource.dart';
import '../../data/repositories/payments_repository_impl.dart';

final paymentsRemoteDataSourceProvider = Provider<PaymentsRemoteDataSource>((ref) {
  return PaymentsRemoteDataSource(ref.watch(apiClientProvider));
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepositoryImpl(ref.watch(paymentsRemoteDataSourceProvider));
});

class PendingPaymentsState {
  const PendingPaymentsState({
    this.payments = const [],
    this.isLoading = false,
    this.error,
  });

  final List<PendingPayment> payments;
  final bool isLoading;
  final String? error;

  PendingPaymentsState copyWith({
    List<PendingPayment>? payments,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PendingPaymentsState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PendingPaymentsNotifier extends StateNotifier<PendingPaymentsState> {
  PendingPaymentsNotifier(this._repository) : super(const PendingPaymentsState()) {
    load();
  }

  final PaymentsRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payments = await _repository.getPendingPayments();
      state = state.copyWith(payments: payments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String> generateReminder(
    PendingPayment payment,
    ReminderMessageType type,
  ) async {
    return _repository.generateReminderMessage(
      type: type,
      customerName: payment.customerName ?? 'Customer',
      amount: payment.dueAmount,
      dueDate: payment.dueDate ?? DateTime.now(),
    );
  }
}

final pendingPaymentsProvider =
    StateNotifierProvider.autoDispose<PendingPaymentsNotifier, PendingPaymentsState>((ref) {
  return PendingPaymentsNotifier(ref.watch(paymentsRepositoryProvider));
});
