import '../../domain/entities/spare.dart';
import '../../domain/entities/workflow_order.dart';

class WorkflowOrderModel extends WorkflowOrder {
  const WorkflowOrderModel({
    required super.id,
    required super.roNumber,
    required super.stage,
    super.customerName,
    super.customerMobile,
    super.registrationNumber,
    super.make,
    super.model,
    super.jobCardNumber,
    super.odometerIn,
    super.updatedAt,
  });

  factory WorkflowOrderModel.fromJson(Map<String, dynamic> json) {
    return WorkflowOrderModel(
      id: json['id'] as String,
      roNumber: json['ro_number'] as String,
      stage: json['stage'] as String,
      customerName: json['customer_name'] as String?,
      customerMobile: json['customer_mobile'] as String?,
      registrationNumber: json['registration_number'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      jobCardNumber: json['job_card_number'] as String?,
      odometerIn: json['odometer_in'] as int?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}

class StageTimelineEntryModel extends StageTimelineEntry {
  const StageTimelineEntryModel({
    required super.id,
    required super.toStage,
    super.fromStage,
    super.changedByName,
    super.notes,
    super.createdAt,
  });

  factory StageTimelineEntryModel.fromJson(Map<String, dynamic> json) {
    return StageTimelineEntryModel(
      id: json['id'] as String,
      toStage: json['to_stage'] as String,
      fromStage: json['from_stage'] as String?,
      changedByName: json['changed_by_name'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

class SpareModel extends Spare {
  const SpareModel({
    required super.id,
    required super.partName,
    super.partNumber,
    required super.quantity,
    required super.status,
    super.repairOrderId,
    super.roNumber,
    super.registrationNumber,
  });

  factory SpareModel.fromJson(Map<String, dynamic> json) {
    return SpareModel(
      id: json['id'] as String,
      partName: json['part_name'] as String? ?? json['name'] as String? ?? 'Unknown part',
      partNumber: json['part_number'] as String?,
      quantity: _toDouble(json['quantity']),
      status: json['status'] as String? ?? 'pending',
      repairOrderId: json['repair_order_id'] as String?,
      roNumber: json['ro_number'] as String?,
      registrationNumber: json['registration_number'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 1;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 1;
  }
}
