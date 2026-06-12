import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.id,
    required super.registrationNumber,
    super.make,
    super.model,
    super.year,
    super.variant,
    super.color,
    super.vin,
    super.fuelLevel,
    super.odometer,
    super.avgKmPerDay,
    super.customerId,
    super.detected,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      registrationNumber: json['registration_number'] as String,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      variant: json['variant'] as String?,
      color: json['color'] as String?,
      vin: json['vin'] as String?,
      fuelLevel: (json['fuel_level'] as num?)?.toDouble(),
      odometer: json['odometer'] as int?,
      avgKmPerDay: json['avg_km_per_day'] as int?,
      customerId: json['customer_id'] as String?,
      detected: json['detected'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'registrationNumber': registrationNumber,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (year != null) 'year': year,
        if (variant != null) 'variant': variant,
        if (color != null) 'color': color,
        if (vin != null) 'vin': vin,
        if (fuelLevel != null) 'fuelLevel': fuelLevel,
        if (odometer != null) 'odometer': odometer,
        if (avgKmPerDay != null) 'avgKmPerDay': avgKmPerDay,
        if (customerId != null) 'customerId': customerId,
      };
}

class VehicleImageModel extends VehicleImage {
  const VehicleImageModel({
    required super.id,
    required super.imageType,
    required super.imageUrl,
  });

  factory VehicleImageModel.fromJson(Map<String, dynamic> json) {
    return VehicleImageModel(
      id: json['id'] as String,
      imageType: json['image_type'] as String,
      imageUrl: json['image_url'] as String,
    );
  }
}

class ServiceHistoryModel extends ServiceHistoryEntry {
  const ServiceHistoryModel({
    required super.id,
    required super.serviceDate,
    super.odometer,
    super.description,
    super.totalAmount,
    super.repairOrderId,
  });

  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryModel(
      id: json['id'] as String,
      serviceDate: DateTime.parse(json['service_date'] as String),
      odometer: json['odometer'] as int?,
      description: json['description'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      repairOrderId: json['repair_order_id'] as String?,
    );
  }
}

class OcrResultModel extends OcrResult {
  const OcrResultModel({
    required super.detected,
    super.registrationNumber,
    super.vehicle,
  });

  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    return OcrResultModel(
      detected: json['detected'] as bool? ?? false,
      registrationNumber: json['registrationNumber'] as String? ??
          json['registration_number'] as String?,
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>)
          : (json['id'] != null ? VehicleModel.fromJson(json) : null),
    );
  }
}
