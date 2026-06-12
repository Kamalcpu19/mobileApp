import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/estimate_remote_datasource.dart';
import '../../data/repositories/estimate_repository_impl.dart';
import '../../domain/entities/estimate.dart';
import '../../domain/repositories/estimate_repository.dart';

final estimateDatasourceProvider = Provider<EstimateRemoteDatasource>(
  (ref) => EstimateRemoteDatasource(ref.watch(apiClientProvider)),
);

final estimateRepositoryProvider = Provider<EstimateRepository>(
  (ref) => EstimateRepositoryImpl(ref.watch(estimateDatasourceProvider)),
);

final estimateProvider =
    FutureProvider.autoDispose.family<Estimate?, String>((ref, roId) async {
  final repo = ref.watch(estimateRepositoryProvider);
  var estimate = await repo.getEstimate(roId);
  estimate ??= await repo.createEstimate(roId);
  return estimate;
});

class EstimateFormState {
  const EstimateFormState({
    this.itemType = 'service',
    this.name = '',
    this.partNumber = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.isAdding = false,
    this.isGenerating = false,
    this.isSubmitting = false,
  });

  final String itemType;
  final String name;
  final String partNumber;
  final double quantity;
  final double unitPrice;
  final bool isAdding;
  final bool isGenerating;
  final bool isSubmitting;

  EstimateFormState copyWith({
    String? itemType,
    String? name,
    String? partNumber,
    double? quantity,
    double? unitPrice,
    bool? isAdding,
    bool? isGenerating,
    bool? isSubmitting,
  }) {
    return EstimateFormState(
      itemType: itemType ?? this.itemType,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      isAdding: isAdding ?? this.isAdding,
      isGenerating: isGenerating ?? this.isGenerating,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final estimateFormProvider = StateNotifierProvider.autoDispose
    .family<EstimateFormNotifier, EstimateFormState, String>(
  (ref, roId) => EstimateFormNotifier(ref, roId),
);

class EstimateFormNotifier extends StateNotifier<EstimateFormState> {
  EstimateFormNotifier(this._ref, this.roId) : super(const EstimateFormState());

  final Ref _ref;
  final String roId;

  void setItemType(String type) => state = state.copyWith(itemType: type);
  void setName(String name) => state = state.copyWith(name: name);
  void setPartNumber(String v) => state = state.copyWith(partNumber: v);
  void setQuantity(double v) => state = state.copyWith(quantity: v);
  void setUnitPrice(double v) => state = state.copyWith(unitPrice: v);

  Future<void> addLineItem() async {
    if (state.name.trim().isEmpty) return;
    state = state.copyWith(isAdding: true);
    try {
      final estimate = await _ref.read(estimateProvider(roId).future);
      if (estimate == null) return;
      await _ref.read(estimateRepositoryProvider).addLineItem(estimate.id, {
        'itemType': state.itemType,
        'name': state.name.trim(),
        if (state.partNumber.isNotEmpty) 'partNumber': state.partNumber,
        'quantity': state.quantity,
        'unitPrice': state.unitPrice,
      });
      _ref.invalidate(estimateProvider(roId));
      state = const EstimateFormState();
    } finally {
      state = state.copyWith(isAdding: false);
    }
  }

  Future<void> generateAiQuote() async {
    state = state.copyWith(isGenerating: true);
    try {
      await _ref.read(estimateRepositoryProvider).generateAiEstimate(roId);
      _ref.invalidate(estimateProvider(roId));
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  Future<void> submitApproval() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final estimate = await _ref.read(estimateProvider(roId).future);
      if (estimate == null) return;
      await _ref
          .read(estimateRepositoryProvider)
          .submitForApproval(estimate.id);
      _ref.invalidate(estimateProvider(roId));
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
