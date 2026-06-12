import '../../domain/entities/inspection_item.dart';

class InspectionItemModel extends InspectionItem {
  const InspectionItemModel({
    required super.id,
    required super.itemName,
    required super.category,
    required super.status,
    required super.inspectionType,
    super.comment,
    super.imageUrl,
  });

  factory InspectionItemModel.fromJson(Map<String, dynamic> json) {
    return InspectionItemModel(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      category: json['category'] as String? ?? 'General',
      status: json['status'] as String? ?? 'pending',
      inspectionType: json['inspection_type'] as String? ?? 'pre',
      comment: json['comment'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ServiceHistoryEntryModel extends ServiceHistoryEntry {
  const ServiceHistoryEntryModel({
    required super.id,
    required super.serviceDate,
    super.odometer,
    super.description,
    super.totalAmount,
  });

  factory ServiceHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryEntryModel(
      id: json['id'] as String,
      serviceDate: DateTime.parse(json['service_date'] as String),
      odometer: json['odometer'] as int?,
      description: json['description'] as String?,
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString())
          : null,
    );
  }
}

class DeliveryOrderSummaryModel extends DeliveryOrderSummary {
  const DeliveryOrderSummaryModel({
    required super.id,
    required super.roNumber,
    super.customerName,
    super.registrationNumber,
    super.make,
    super.model,
    super.odometerIn,
    super.odometerOut,
    super.nextServiceReminder,
    super.jobCardNumber,
    super.vehicleId,
  });

  factory DeliveryOrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderSummaryModel(
      id: json['id'] as String,
      roNumber: json['ro_number'] as String,
      customerName: json['customer_name'] as String?,
      registrationNumber: json['registration_number'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      odometerIn: json['odometer_in'] as int?,
      odometerOut: json['odometer_out'] as int?,
      nextServiceReminder: json['next_service_reminder'] != null
          ? DateTime.tryParse(json['next_service_reminder'] as String)
          : null,
      jobCardNumber: json['job_card_number'] as String?,
      vehicleId: json['vehicle_id'] as String?,
    );
  }
}
