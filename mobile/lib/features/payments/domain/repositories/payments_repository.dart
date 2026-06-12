import '../entities/pending_payment.dart';

abstract class PaymentsRepository {
  Future<List<PendingPayment>> getPendingPayments();

  Future<String> generateReminderMessage({
    required ReminderMessageType type,
    required String customerName,
    required double amount,
    required DateTime dueDate,
  });
}
