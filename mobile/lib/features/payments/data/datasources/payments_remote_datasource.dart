import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/pending_payment.dart';
import '../models/pending_payment_model.dart';

class PaymentsRemoteDataSource {
  PaymentsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<PendingPaymentModel>> getPendingPayments() async {
    final response = await _client.get<List<dynamic>>('/invoices/pending');
    return (response.data ?? [])
        .map((e) => PendingPaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> generateReminderMessage({
    required ReminderMessageType type,
    required String customerName,
    required double amount,
    required DateTime dueDate,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '${ApiConstants.ai}/payment-reminder',
      data: {
        'type': type.apiValue,
        'customerName': customerName,
        'amount': amount,
        'dueDate': dueDate.toIso8601String().split('T').first,
      },
    );
    return response.data?['message'] as String? ?? 'Reminder message unavailable';
  }
}
