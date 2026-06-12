class Vehicle {
  const Vehicle({
    required this.id,
    required this.registrationNumber,
    this.make,
    this.model,
    this.year,
    this.variant,
    this.color,
    this.vin,
    this.fuelLevel,
    this.odometer,
    this.avgKmPerDay,
    this.customerId,
    this.detected = false,
  });

  final String id;
  final String registrationNumber;
  final String? make;
  final String? model;
  final int? year;
  final String? variant;
  final String? color;
  final String? vin;
  final double? fuelLevel;
  final int? odometer;
  final int? avgKmPerDay;
  final String? customerId;
  final bool detected;

  String get displayName =>
      '$registrationNumber · ${make ?? ''} ${model ?? ''}'.trim();
}

enum VehicleImageType {
  front,
  back,
  left,
  right,
  fuel,
  odometer,
}

extension VehicleImageTypeExt on VehicleImageType {
  String get apiValue => name;

  String get label {
    switch (this) {
      case VehicleImageType.front:
        return 'Front';
      case VehicleImageType.back:
        return 'Back';
      case VehicleImageType.left:
        return 'Left';
      case VehicleImageType.right:
        return 'Right';
      case VehicleImageType.fuel:
        return 'Fuel Gauge';
      case VehicleImageType.odometer:
        return 'Odometer';
    }
  }
}

class VehicleImage {
  const VehicleImage({
    required this.id,
    required this.imageType,
    required this.imageUrl,
  });

  final String id;
  final String imageType;
  final String imageUrl;
}

class ServiceHistoryEntry {
  const ServiceHistoryEntry({
    required this.id,
    required this.serviceDate,
    this.odometer,
    this.description,
    this.totalAmount,
    this.repairOrderId,
  });

  final String id;
  final DateTime serviceDate;
  final int? odometer;
  final String? description;
  final double? totalAmount;
  final String? repairOrderId;
}

class OcrResult {
  const OcrResult({
    required this.detected,
    this.registrationNumber,
    this.vehicle,
  });

  final bool detected;
  final String? registrationNumber;
  final Vehicle? vehicle;
}
