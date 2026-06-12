import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/repair_order_remote_datasource.dart';
import '../../data/repositories/repair_order_repository_impl.dart';
import '../../domain/entities/repair_order.dart';
import '../../domain/repositories/repair_order_repository.dart';

final repairOrderDatasourceProvider = Provider<RepairOrderRemoteDatasource>(
  (ref) => RepairOrderRemoteDatasource(ref.watch(apiClientProvider)),
);

final repairOrderRepositoryProvider = Provider<RepairOrderRepository>(
  (ref) => RepairOrderRepositoryImpl(ref.watch(repairOrderDatasourceProvider)),
);

class RepairOrderFilter {
  const RepairOrderFilter({this.stage = 'All', this.search = ''});

  final String stage;
  final String search;

  RepairOrderFilter copyWith({String? stage, String? search}) {
    return RepairOrderFilter(
      stage: stage ?? this.stage,
      search: search ?? this.search,
    );
  }
}

final repairOrderFilterProvider =
    StateProvider<RepairOrderFilter>((ref) => const RepairOrderFilter());

final repairOrdersProvider =
    FutureProvider.autoDispose<List<RepairOrder>>((ref) {
  final filter = ref.watch(repairOrderFilterProvider);
  final repo = ref.watch(repairOrderRepositoryProvider);
  return repo.getRepairOrders(
    stage: filter.stage == 'All' ? null : filter.stage,
    search: filter.search.isEmpty ? null : filter.search,
  );
});

final repairOrderDetailProvider =
    FutureProvider.autoDispose.family<RepairOrder, String>((ref, id) {
  final repo = ref.watch(repairOrderRepositoryProvider);
  return repo.getRepairOrderById(id);
});

final stageHistoryProvider =
    FutureProvider.autoDispose.family<List<StageHistoryEntry>, String>(
        (ref, roId) {
  final repo = ref.watch(repairOrderRepositoryProvider);
  return repo.getStageHistory(roId);
});

final roStagesProvider = FutureProvider.autoDispose<List<String>>((ref) {
  final repo = ref.watch(repairOrderRepositoryProvider);
  return repo.getStages();
});

class CreateRoState {
  const CreateRoState({
    this.customerId,
    this.vehicleId,
    this.appointmentId,
    this.notes = '',
    this.isSubmitting = false,
  });

  final String? customerId;
  final String? vehicleId;
  final String? appointmentId;
  final String notes;
  final bool isSubmitting;

  CreateRoState copyWith({
    String? customerId,
    String? vehicleId,
    String? appointmentId,
    String? notes,
    bool? isSubmitting,
  }) {
    return CreateRoState(
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      appointmentId: appointmentId ?? this.appointmentId,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final createRoProvider =
    StateNotifierProvider<CreateRoNotifier, CreateRoState>((ref) {
  return CreateRoNotifier(ref);
});

class CreateRoNotifier extends StateNotifier<CreateRoState> {
  CreateRoNotifier(this._ref) : super(const CreateRoState());

  final Ref _ref;

  void initFromExtra(Map<String, dynamic>? extra) {
    if (extra == null) return;
    state = state.copyWith(
      appointmentId: extra['appointmentId'] as String?,
      customerId: extra['customerId'] as String?,
      vehicleId: extra['vehicleId'] as String?,
    );
  }

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  Future<RepairOrder?> submit() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final order = await _ref.read(repairOrderRepositoryProvider).createRepairOrder(
            customerId: state.customerId,
            vehicleId: state.vehicleId,
            appointmentId: state.appointmentId,
          );
      _ref.invalidate(repairOrdersProvider);
      return order;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
