import 'package:equatable/equatable.dart';

class Spare extends Equatable {
  const Spare({
    required this.id,
    required this.partName,
    this.partNumber,
    required this.quantity,
    required this.status,
    this.repairOrderId,
    this.roNumber,
    this.registrationNumber,
  });

  final String id;
  final String partName;
  final String? partNumber;
  final double quantity;
  final String status;
  final String? repairOrderId;
  final String? roNumber;
  final String? registrationNumber;

  @override
  List<Object?> get props => [id, partName, status];
}
