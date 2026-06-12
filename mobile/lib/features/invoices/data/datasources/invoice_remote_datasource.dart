import '../../../../core/network/api_client.dart';
import '../models/invoice_model.dart';

class InvoiceRemoteDataSource {
  InvoiceRemoteDataSource(this._client);

  final ApiClient _client;

  Future<InvoiceModel?> getInvoice(String repairOrderId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/invoices/$repairOrderId');
      if (response.data == null) return null;
      return InvoiceModel.fromJson(response.data!);
    } catch (_) {
      return null;
    }
  }

  Future<InvoiceModel> generateInvoice(String repairOrderId) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/invoices/$repairOrderId/generate',
    );
    return InvoiceModel.fromJson(response.data!);
  }

  Future<InvoiceModel> recordPayment(
    String invoiceId,
    double amount, {
    String? method,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/invoices/$invoiceId/pay',
      data: {
        'amount': amount,
        if (method != null) 'method': method,
      },
    );
    return InvoiceModel.fromJson(response.data!);
  }
}
