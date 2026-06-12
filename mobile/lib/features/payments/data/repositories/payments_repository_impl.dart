import '../../domain/entities/pending_payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  PaymentsRepositoryImpl(this._remoteDataSource);

  final PaymentsRemoteDataSource _remoteDataSource;

  @override
  Future<List<PendingPayment>> getPendingPayments() {
    return _remoteDataSource.getPendingPayments();
  }

  @override
  Future<String> generateReminderMessage({
    required ReminderMessageType type,
    required String customerName,
    required double amount,
    required DateTime dueDate,
  }) {
    return _remoteDataSource.generateReminderMessage(
      type: type,
      customerName: customerName,
      amount: amount,
      dueDate: dueDate,
    );
  }
}
