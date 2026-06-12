import '../../domain/entities/estimate.dart';
import '../../domain/entities/estimate_line_item.dart';

class EstimateLineItemModel extends EstimateLineItem {
  const EstimateLineItemModel({
    required super.id,
    required super.name,
    super.description,
    required super.itemType,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
    required super.approvalStatus,
    super.partNumber,
  });

  factory EstimateLineItemModel.fromJson(Map<String, dynamic> json) {
    return EstimateLineItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      itemType: json['item_type'] as String? ?? 'part',
      quantity: _toDouble(json['quantity']),
      unitPrice: _toDouble(json['unit_price']),
      totalPrice: _toDouble(json['total_price']),
      approvalStatus: _parseStatus(json['approval_status'] as String?),
      partNumber: json['part_number'] as String?,
    );
  }

  static LineItemApprovalStatus _parseStatus(String? status) {
    return switch (status) {
      'approved' => LineItemApprovalStatus.approved,
      'rejected' => LineItemApprovalStatus.rejected,
      _ => LineItemApprovalStatus.pending,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}

class EstimateModel extends Estimate {
  const EstimateModel({
    required super.id,
    required super.estimateNumber,
    required super.status,
    required super.lineItems,
    required super.subtotal,
    required super.taxAmount,
    required super.totalAmount,
    super.repairOrderId,
    super.approvalToken,
  });

  factory EstimateModel.fromJson(Map<String, dynamic> json) {
    final items = (json['lineItems'] as List<dynamic>? ?? [])
        .map((e) => EstimateLineItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return EstimateModel(
      id: json['id'] as String,
      estimateNumber: json['estimate_number'] as String,
      status: json['status'] as String? ?? 'draft',
      lineItems: items,
      subtotal: EstimateLineItemModel._toDouble(json['subtotal']),
      taxAmount: EstimateLineItemModel._toDouble(json['tax_amount']),
      totalAmount: EstimateLineItemModel._toDouble(json['total_amount']),
      repairOrderId: json['repair_order_id'] as String?,
      approvalToken: json['approval_token'] as String?,
    );
  }
}
