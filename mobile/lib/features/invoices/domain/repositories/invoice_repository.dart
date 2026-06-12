import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<Invoice?> getInvoice(String repairOrderId);

  Future<Invoice> generateInvoice(String repairOrderId);

  Future<Invoice> recordPayment(String invoiceId, double amount, {String? method});
}
