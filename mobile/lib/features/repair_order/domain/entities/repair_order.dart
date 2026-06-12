class RepairOrder {
  const RepairOrder({
    required this.id,
    required this.roNumber,
    required this.stage,
    this.customerName,
    this.customerMobile,
    this.registrationNumber,
    this.make,
    this.model,
    this.vehicleDetectionStatus,
    this.odometerIn,
    this.odometerOut,
    this.jobCardNumber,
    this.appointmentId,
    this.customerId,
    this.vehicleId,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String roNumber;
  final String stage;
  final String? customerName;
  final String? customerMobile;
  final String? registrationNumber;
  final String? make;
  final String? model;
  final String? vehicleDetectionStatus;
  final int? odometerIn;
  final int? odometerOut;
  final String? jobCardNumber;
  final String? appointmentId;
  final String? customerId;
  final String? vehicleId;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get vehicleDisplay {
    if (registrationNumber == null) return 'Vehicle not linked';
    return '$registrationNumber · ${make ?? ''} ${model ?? ''}'.trim();
  }
}

class StageHistoryEntry {
  const StageHistoryEntry({
    required this.id,
    this.fromStage,
    required this.toStage,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String? fromStage;
  final String toStage;
  final String? notes;
  final DateTime createdAt;
}
