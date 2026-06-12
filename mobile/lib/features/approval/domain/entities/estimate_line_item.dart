import 'package:equatable/equatable.dart';

enum LineItemApprovalStatus { pending, approved, rejected }

class EstimateLineItem extends Equatable {
  const EstimateLineItem({
    required this.id,
    required this.name,
    this.description,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.approvalStatus,
    this.partNumber,
  });

  final String id;
  final String name;
  final String? description;
  final String itemType;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final LineItemApprovalStatus approvalStatus;
  final String? partNumber;

  EstimateLineItem copyWith({LineItemApprovalStatus? approvalStatus}) {
    return EstimateLineItem(
      id: id,
      name: name,
      description: description,
      itemType: itemType,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      partNumber: partNumber,
    );
  }

  @override
  List<Object?> get props => [id, name, approvalStatus, totalPrice];
}
