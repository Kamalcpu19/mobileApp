import '../../domain/entities/estimate.dart';

class EstimateModel extends Estimate {
  const EstimateModel({
    required super.id,
    required super.estimateNumber,
    required super.status,
    required super.subtotal,
    required super.taxAmount,
    required super.totalAmount,
    super.lineItems,
    super.repairOrderId,
  });

  factory EstimateModel.fromJson(Map<String, dynamic> json) {
    final items = json['line_items'] as List? ?? json['lineItems'] as List? ?? [];
    return EstimateModel(
      id: json['id'] as String,
      estimateNumber: json['estimate_number'] as String,
      status: json['status'] as String? ?? 'draft',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      repairOrderId: json['repair_order_id'] as String?,
      lineItems: items
          .map((e) => EstimateLineItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EstimateLineItemModel extends EstimateLineItem {
  const EstimateLineItemModel({
    required super.id,
    required super.itemType,
    required super.name,
    super.description,
    super.partNumber,
    super.quantity,
    super.unitPrice,
    super.totalPrice,
    super.approvalStatus,
  });

  factory EstimateLineItemModel.fromJson(Map<String, dynamic> json) {
    return EstimateLineItemModel(
      id: json['id'] as String,
      itemType: json['item_type'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      partNumber: json['part_number'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'itemType': itemType,
        'name': name,
        if (description != null) 'description': description,
        if (partNumber != null) 'partNumber': partNumber,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}
