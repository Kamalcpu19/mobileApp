import '../../domain/entities/repair_order.dart';

class RepairOrderModel extends RepairOrder {
  const RepairOrderModel({
    required super.id,
    required super.roNumber,
    required super.stage,
    super.customerName,
    super.customerMobile,
    super.registrationNumber,
    super.make,
    super.model,
    super.vehicleDetectionStatus,
    super.odometerIn,
    super.odometerOut,
    super.jobCardNumber,
    super.appointmentId,
    super.customerId,
    super.vehicleId,
    super.notes,
    super.createdAt,
    super.updatedAt,
  });

  factory RepairOrderModel.fromJson(Map<String, dynamic> json) {
    return RepairOrderModel(
      id: json['id'] as String,
      roNumber: json['ro_number'] as String,
      stage: json['stage'] as String? ?? 'inspection',
      customerName: json['customer_name'] as String?,
      customerMobile: json['customer_mobile'] as String?,
      registrationNumber: json['registration_number'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      vehicleDetectionStatus: json['vehicle_detection_status'] as String?,
      odometerIn: json['odometer_in'] as int?,
      odometerOut: json['odometer_out'] as int?,
      jobCardNumber: json['job_card_number'] as String?,
      appointmentId: json['appointment_id'] as String?,
      customerId: json['customer_id'] as String?,
      vehicleId: json['vehicle_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class StageHistoryModel extends StageHistoryEntry {
  const StageHistoryModel({
    required super.id,
    super.fromStage,
    required super.toStage,
    super.notes,
    required super.createdAt,
  });

  factory StageHistoryModel.fromJson(Map<String, dynamic> json) {
    return StageHistoryModel(
      id: json['id'] as String,
      fromStage: json['from_stage'] as String?,
      toStage: json['to_stage'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
