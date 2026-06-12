import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/vehicle_remote_datasource.dart';
import '../../data/repositories/vehicle_repository_impl.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

final vehicleDatasourceProvider = Provider<VehicleRemoteDatasource>(
  (ref) => VehicleRemoteDatasource(ref.watch(apiClientProvider)),
);

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => VehicleRepositoryImpl(ref.watch(vehicleDatasourceProvider)),
);

final serviceHistoryProvider =
    FutureProvider.autoDispose.family<List<ServiceHistoryEntry>, String>(
        (ref, vehicleId) {
  return ref.watch(vehicleRepositoryProvider).getServiceHistory(vehicleId);
});

class VehicleDetectionState {
  const VehicleDetectionState({
    this.registrationNumber = '',
    this.isScanning = false,
    this.isLookingUp = false,
    this.detectedVehicle,
    this.error,
  });

  final String registrationNumber;
  final bool isScanning;
  final bool isLookingUp;
  final Vehicle? detectedVehicle;
  final String? error;

  VehicleDetectionState copyWith({
    String? registrationNumber,
    bool? isScanning,
    bool? isLookingUp,
    Vehicle? detectedVehicle,
    String? error,
  }) {
    return VehicleDetectionState(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      isScanning: isScanning ?? this.isScanning,
      isLookingUp: isLookingUp ?? this.isLookingUp,
      detectedVehicle: detectedVehicle ?? this.detectedVehicle,
      error: error,
    );
  }
}

final vehicleDetectionProvider = StateNotifierProvider.autoDispose
    .family<VehicleDetectionNotifier, VehicleDetectionState, String>(
  (ref, roId) => VehicleDetectionNotifier(ref, roId),
);

class VehicleDetectionNotifier extends StateNotifier<VehicleDetectionState> {
  VehicleDetectionNotifier(this._ref, this.roId)
      : super(const VehicleDetectionState());

  final Ref _ref;
  final String roId;

  void setRegistration(String value) {
    state = state.copyWith(registrationNumber: value.toUpperCase(), error: null);
  }

  Future<void> lookup() async {
    if (state.registrationNumber.isEmpty) return;
    state = state.copyWith(isLookingUp: true, error: null);
    try {
      final vehicle = await _ref
          .read(vehicleRepositoryProvider)
          .lookupVehicle(state.registrationNumber);
      state = state.copyWith(
        isLookingUp: false,
        detectedVehicle: vehicle,
        error: vehicle == null ? 'Vehicle not found in workshop records' : null,
      );
    } catch (e) {
      state = state.copyWith(isLookingUp: false, error: e.toString());
    }
  }

  Future<void> scanPlate(String imageBase64) async {
    state = state.copyWith(isScanning: true, error: null);
    try {
      final result =
          await _ref.read(vehicleRepositoryProvider).recognizePlate(imageBase64);
      state = state.copyWith(
        isScanning: false,
        registrationNumber:
            result.registrationNumber ?? state.registrationNumber,
        detectedVehicle: result.vehicle,
        error: !result.detected ? 'Could not detect plate number' : null,
      );
    } catch (e) {
      state = state.copyWith(isScanning: false, error: e.toString());
    }
  }
}

const requiredImageTypes = VehicleImageType.values;

class VehicleImageCaptureState {
  const VehicleImageCaptureState({
    this.captured = const {},
    this.skipped = false,
    this.odometer,
    this.avgKmPerDay,
    this.currentIndex = 0,
    this.isUploading = false,
  });

  final Map<VehicleImageType, String> captured;
  final bool skipped;
  final int? odometer;
  final int? avgKmPerDay;
  final int currentIndex;
  final bool isUploading;

  VehicleImageType get currentType => requiredImageTypes[currentIndex];

  bool get isComplete =>
      skipped || captured.length >= requiredImageTypes.length;

  VehicleImageCaptureState copyWith({
    Map<VehicleImageType, String>? captured,
    bool? skipped,
    int? odometer,
    int? avgKmPerDay,
    int? currentIndex,
    bool? isUploading,
  }) {
    return VehicleImageCaptureState(
      captured: captured ?? this.captured,
      skipped: skipped ?? this.skipped,
      odometer: odometer ?? this.odometer,
      avgKmPerDay: avgKmPerDay ?? this.avgKmPerDay,
      currentIndex: currentIndex ?? this.currentIndex,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

final vehicleImageCaptureProvider = StateNotifierProvider.autoDispose
    .family<VehicleImageCaptureNotifier, VehicleImageCaptureState, String>(
  (ref, roId) => VehicleImageCaptureNotifier(ref),
);

class VehicleImageCaptureNotifier
    extends StateNotifier<VehicleImageCaptureState> {
  VehicleImageCaptureNotifier(this._ref)
      : super(const VehicleImageCaptureState());

  final Ref _ref;

  void captureImage(VehicleImageType type, String imageUrl) {
    final updated = Map<VehicleImageType, String>.from(state.captured);
    updated[type] = imageUrl;
    final nextIndex = (state.currentIndex + 1).clamp(0, requiredImageTypes.length);
    state = state.copyWith(
      captured: updated,
      currentIndex: nextIndex >= requiredImageTypes.length
          ? requiredImageTypes.length - 1
          : nextIndex,
    );
  }

  void skipToOdometer() {
    state = state.copyWith(
      skipped: true,
      currentIndex: requiredImageTypes.indexOf(VehicleImageType.odometer),
    );
  }

  void setOdometer(int? value) => state = state.copyWith(odometer: value);

  void setAvgKm(int? value) => state = state.copyWith(avgKmPerDay: value);

  Future<void> uploadAll(String vehicleId) async {
    state = state.copyWith(isUploading: true);
    final repo = _ref.read(vehicleRepositoryProvider);
    for (final entry in state.captured.entries) {
      await repo.saveVehicleImage(vehicleId, entry.key.apiValue, entry.value);
    }
    if (state.odometer != null || state.avgKmPerDay != null) {
      await repo.createOrUpdateVehicle({
        'id': vehicleId,
        if (state.odometer != null) 'odometer': state.odometer,
        if (state.avgKmPerDay != null) 'avgKmPerDay': state.avgKmPerDay,
      });
    }
    state = state.copyWith(isUploading: false);
  }
}

class VehicleEditState {
  const VehicleEditState({
    this.registrationNumber = '',
    this.make = '',
    this.model = '',
    this.year,
    this.variant = '',
    this.color = '',
    this.vin = '',
    this.odometer,
    this.avgKmPerDay,
    this.isSaving = false,
  });

  final String registrationNumber;
  final String make;
  final String model;
  final int? year;
  final String variant;
  final String color;
  final String vin;
  final int? odometer;
  final int? avgKmPerDay;
  final bool isSaving;

  VehicleEditState copyWith({
    String? registrationNumber,
    String? make,
    String? model,
    int? year,
    String? variant,
    String? color,
    String? vin,
    int? odometer,
    int? avgKmPerDay,
    bool? isSaving,
  }) {
    return VehicleEditState(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      variant: variant ?? this.variant,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      odometer: odometer ?? this.odometer,
      avgKmPerDay: avgKmPerDay ?? this.avgKmPerDay,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final vehicleEditProvider = StateNotifierProvider.autoDispose
    .family<VehicleEditNotifier, VehicleEditState, String>(
  (ref, roId) => VehicleEditNotifier(ref),
);

class VehicleEditNotifier extends StateNotifier<VehicleEditState> {
  VehicleEditNotifier(this._ref) : super(const VehicleEditState());

  final Ref _ref;

  void loadFromVehicle(Vehicle vehicle) {
    state = VehicleEditState(
      registrationNumber: vehicle.registrationNumber,
      make: vehicle.make ?? '',
      model: vehicle.model ?? '',
      year: vehicle.year,
      variant: vehicle.variant ?? '',
      color: vehicle.color ?? '',
      vin: vehicle.vin ?? '',
      odometer: vehicle.odometer,
      avgKmPerDay: vehicle.avgKmPerDay,
    );
  }

  void update(String field, dynamic value) {
    switch (field) {
      case 'registrationNumber':
        state = state.copyWith(registrationNumber: value as String);
      case 'make':
        state = state.copyWith(make: value as String);
      case 'model':
        state = state.copyWith(model: value as String);
      case 'year':
        state = state.copyWith(year: value as int?);
      case 'variant':
        state = state.copyWith(variant: value as String);
      case 'color':
        state = state.copyWith(color: value as String);
      case 'vin':
        state = state.copyWith(vin: value as String);
      case 'odometer':
        state = state.copyWith(odometer: value as int?);
      case 'avgKmPerDay':
        state = state.copyWith(avgKmPerDay: value as int?);
    }
  }

  Future<Vehicle?> save() async {
    state = state.copyWith(isSaving: true);
    try {
      final vehicle = await _ref.read(vehicleRepositoryProvider).createOrUpdateVehicle({
        'registrationNumber': state.registrationNumber,
        'make': state.make,
        'model': state.model,
        if (state.year != null) 'year': state.year,
        'variant': state.variant,
        'color': state.color,
        'vin': state.vin,
        if (state.odometer != null) 'odometer': state.odometer,
        if (state.avgKmPerDay != null) 'avgKmPerDay': state.avgKmPerDay,
      });
      return vehicle;
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }
}
