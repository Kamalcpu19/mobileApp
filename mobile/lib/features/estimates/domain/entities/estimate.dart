class Estimate {
  const Estimate({
    required this.id,
    required this.estimateNumber,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.lineItems = const [],
    this.repairOrderId,
  });

  final String id;
  final String estimateNumber;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final List<EstimateLineItem> lineItems;
  final String? repairOrderId;
}

class EstimateLineItem {
  const EstimateLineItem({
    required this.id,
    required this.itemType,
    required this.name,
    this.description,
    this.partNumber,
    this.quantity = 1,
    this.unitPrice = 0,
    this.totalPrice = 0,
    this.approvalStatus = 'pending',
  });

  final String id;
  final String itemType;
  final String name;
  final String? description;
  final String? partNumber;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String approvalStatus;
}
