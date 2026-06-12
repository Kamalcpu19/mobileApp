import 'package:equatable/equatable.dart';

class WorkflowOrder extends Equatable {
  const WorkflowOrder({
    required this.id,
    required this.roNumber,
    required this.stage,
    this.customerName,
    this.customerMobile,
    this.registrationNumber,
    this.make,
    this.model,
    this.jobCardNumber,
    this.odometerIn,
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
  final String? jobCardNumber;
  final int? odometerIn;
  final DateTime? updatedAt;

  String get vehicleLabel {
    if (registrationNumber != null) {
      final details = [make, model].where((e) => e != null && e.isNotEmpty).join(' ');
      return details.isEmpty ? registrationNumber! : '$registrationNumber · $details';
    }
    return 'Unknown vehicle';
  }

  @override
  List<Object?> get props => [id, roNumber, stage];
}

class StageTimelineEntry extends Equatable {
  const StageTimelineEntry({
    required this.id,
    required this.toStage,
    this.fromStage,
    this.changedByName,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String toStage;
  final String? fromStage;
  final String? changedByName;
  final String? notes;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, toStage, createdAt];
}
