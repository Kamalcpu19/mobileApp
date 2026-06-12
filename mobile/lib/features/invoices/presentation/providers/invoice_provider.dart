import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../data/datasources/invoice_remote_datasource.dart';
import '../../data/repositories/invoice_repository_impl.dart';

final invoiceRemoteDataSourceProvider = Provider<InvoiceRemoteDataSource>((ref) {
  return InvoiceRemoteDataSource(ref.watch(apiClientProvider));
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepositoryImpl(ref.watch(invoiceRemoteDataSourceProvider));
});

class InvoiceState {
  const InvoiceState({
    this.invoice,
    this.isLoading = false,
    this.isGenerating = false,
    this.isPaying = false,
    this.error,
    this.pdfPlaceholderGenerated = false,
  });

  final Invoice? invoice;
  final bool isLoading;
  final bool isGenerating;
  final bool isPaying;
  final String? error;
  final bool pdfPlaceholderGenerated;

  InvoiceState copyWith({
    Invoice? invoice,
    bool? isLoading,
    bool? isGenerating,
    bool? isPaying,
    String? error,
    bool? pdfPlaceholderGenerated,
    bool clearError = false,
  }) {
    return InvoiceState(
      invoice: invoice ?? this.invoice,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      isPaying: isPaying ?? this.isPaying,
      error: clearError ? null : (error ?? this.error),
      pdfPlaceholderGenerated: pdfPlaceholderGenerated ?? this.pdfPlaceholderGenerated,
    );
  }
}

class InvoiceNotifier extends StateNotifier<InvoiceState> {
  InvoiceNotifier(this._repository, this.repairOrderId) : super(const InvoiceState()) {
    load();
  }

  final InvoiceRepository _repository;
  final String repairOrderId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final invoice = await _repository.getInvoice(repairOrderId);
      state = state.copyWith(invoice: invoice, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> generateInvoice() async {
    state = state.copyWith(isGenerating: true, clearError: true);
    try {
      final invoice = await _repository.generateInvoice(repairOrderId);
      state = state.copyWith(invoice: invoice, isGenerating: false);
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
    }
  }

  void generatePdfPlaceholder() {
    state = state.copyWith(pdfPlaceholderGenerated: true);
  }

  Future<void> payNow() async {
    final invoice = state.invoice;
    if (invoice == null || invoice.dueAmount <= 0) return;

    state = state.copyWith(isPaying: true, clearError: true);
    try {
      final updated = await _repository.recordPayment(
        invoice.id,
        invoice.dueAmount,
        method: 'cash',
      );
      state = state.copyWith(invoice: updated, isPaying: false);
    } catch (e) {
      state = state.copyWith(isPaying: false, error: e.toString());
    }
  }
}

final invoiceProvider = StateNotifierProvider.autoDispose
    .family<InvoiceNotifier, InvoiceState, String>((ref, repairOrderId) {
  return InvoiceNotifier(ref.watch(invoiceRepositoryProvider), repairOrderId);
});
