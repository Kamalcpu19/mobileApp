import '../../domain/entities/invoice.dart';

class InvoiceModel extends Invoice {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.repairOrderId,
    required super.subtotal,
    required super.taxAmount,
    required super.totalAmount,
    required super.paidAmount,
    required super.dueAmount,
    required super.status,
    super.dueDate,
    super.pdfUrl,
    super.paymentLink,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      repairOrderId: json['repair_order_id'] as String,
      subtotal: _toDouble(json['subtotal']),
      taxAmount: _toDouble(json['tax_amount']),
      totalAmount: _toDouble(json['total_amount']),
      paidAmount: _toDouble(json['paid_amount']),
      dueAmount: _toDouble(json['due_amount']),
      status: json['status'] as String? ?? 'pending',
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      pdfUrl: json['pdf_url'] as String?,
      paymentLink: json['payment_link'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
