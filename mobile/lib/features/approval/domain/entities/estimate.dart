import 'package:equatable/equatable.dart';

import 'estimate_line_item.dart';

class Estimate extends Equatable {
  const Estimate({
    required this.id,
    required this.estimateNumber,
    required this.status,
    required this.lineItems,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.repairOrderId,
    this.approvalToken,
  });

  final String id;
  final String estimateNumber;
  final String status;
  final List<EstimateLineItem> lineItems;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String? repairOrderId;
  final String? approvalToken;

  bool get allApproved =>
      lineItems.every((item) => item.approvalStatus == LineItemApprovalStatus.approved);

  bool get hasPending =>
      lineItems.any((item) => item.approvalStatus == LineItemApprovalStatus.pending);

  @override
  List<Object?> get props => [id, estimateNumber, status, lineItems];
}
