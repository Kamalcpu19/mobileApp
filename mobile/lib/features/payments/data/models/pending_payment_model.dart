import '../../domain/entities/pending_payment.dart';

class PendingPaymentModel extends PendingPayment {
  const PendingPaymentModel({
    required super.id,
    required super.invoiceNumber,
    required super.dueAmount,
    required super.status,
    super.repairOrderId,
    super.roNumber,
    super.customerName,
    super.customerMobile,
    super.customerEmail,
    super.registrationNumber,
    super.jobCardNumber,
    super.dueDate,
    super.paymentLink,
  });

  factory PendingPaymentModel.fromJson(Map<String, dynamic> json) {
    return PendingPaymentModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      dueAmount: _toDouble(json['due_amount']),
      status: json['status'] as String? ?? 'pending',
      repairOrderId: json['repair_order_id'] as String?,
      roNumber: json['ro_number'] as String?,
      customerName: json['customer_name'] as String?,
      customerMobile: json['customer_mobile'] as String?,
      customerEmail: json['customer_email'] as String?,
      registrationNumber: json['registration_number'] as String?,
      jobCardNumber: json['job_card_number'] as String?,
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
      paymentLink: json['payment_link'] as String?,
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
