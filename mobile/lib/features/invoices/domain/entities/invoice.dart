import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.repairOrderId,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.status,
    this.dueDate,
    this.pdfUrl,
    this.paymentLink,
  });

  final String id;
  final String invoiceNumber;
  final String repairOrderId;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double dueAmount;
  final String status;
  final DateTime? dueDate;
  final String? pdfUrl;
  final String? paymentLink;

  bool get isPaid => status == 'paid' || dueAmount <= 0;

  @override
  List<Object?> get props => [id, invoiceNumber, status, dueAmount];
}
