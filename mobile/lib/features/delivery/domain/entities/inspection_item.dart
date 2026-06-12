import 'package:equatable/equatable.dart';

class InspectionItem extends Equatable {
  const InspectionItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.status,
    required this.inspectionType,
    this.comment,
    this.imageUrl,
  });

  final String id;
  final String itemName;
  final String category;
  final String status;
  final String inspectionType;
  final String? comment;
  final String? imageUrl;

  bool get isIssue =>
      status == 'action_required' || status == 'urgent' || status == 'concern';

  @override
  List<Object?> get props => [id, itemName, status, inspectionType];
}

class ServiceHistoryEntry extends Equatable {
  const ServiceHistoryEntry({
    required this.id,
    required this.serviceDate,
    this.odometer,
    this.description,
    this.totalAmount,
  });

  final String id;
  final DateTime serviceDate;
  final int? odometer;
  final String? description;
  final double? totalAmount;

  @override
  List<Object?> get props => [id, serviceDate];
}

class DeliveryOrderSummary extends Equatable {
  const DeliveryOrderSummary({
    required this.id,
    required this.roNumber,
    this.customerName,
    this.registrationNumber,
    this.make,
    this.model,
    this.odometerIn,
    this.odometerOut,
    this.nextServiceReminder,
    this.jobCardNumber,
    this.vehicleId,
  });

  final String id;
  final String roNumber;
  final String? customerName;
  final String? registrationNumber;
  final String? make;
  final String? model;
  final int? odometerIn;
  final int? odometerOut;
  final DateTime? nextServiceReminder;
  final String? jobCardNumber;
  final String? vehicleId;

  String get vehicleLabel {
    final details = [registrationNumber, make, model]
        .where((e) => e != null && e.isNotEmpty)
        .join(' · ');
    return details.isEmpty ? 'Unknown vehicle' : details;
  }

  @override
  List<Object?> get props => [id, roNumber];
}
