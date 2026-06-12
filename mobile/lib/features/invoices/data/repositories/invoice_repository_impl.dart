import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_remote_datasource.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  InvoiceRepositoryImpl(this._remoteDataSource);

  final InvoiceRemoteDataSource _remoteDataSource;

  @override
  Future<Invoice?> getInvoice(String repairOrderId) {
    return _remoteDataSource.getInvoice(repairOrderId);
  }

  @override
  Future<Invoice> generateInvoice(String repairOrderId) {
    return _remoteDataSource.generateInvoice(repairOrderId);
  }

  @override
  Future<Invoice> recordPayment(String invoiceId, double amount, {String? method}) {
    return _remoteDataSource.recordPayment(invoiceId, amount, method: method);
  }
}
