import 'package:equatable/equatable.dart';

enum ReminderMessageType { friendly, dueToday, overdue, finalNotice }

extension ReminderMessageTypeX on ReminderMessageType {
  String get apiValue => switch (this) {
        ReminderMessageType.friendly => 'friendly',
        ReminderMessageType.dueToday => 'due_today',
        ReminderMessageType.overdue => 'overdue',
        ReminderMessageType.finalNotice => 'final',
      };

  String get label => switch (this) {
        ReminderMessageType.friendly => 'Friendly',
        ReminderMessageType.dueToday => 'Due Today',
        ReminderMessageType.overdue => 'Overdue',
        ReminderMessageType.finalNotice => 'Final Notice',
      };
}

class PendingPayment extends Equatable {
  const PendingPayment({
    required this.id,
    required this.invoiceNumber,
    required this.dueAmount,
    required this.status,
    this.repairOrderId,
    this.roNumber,
    this.customerName,
    this.customerMobile,
    this.customerEmail,
    this.registrationNumber,
    this.jobCardNumber,
    this.dueDate,
    this.paymentLink,
  });

  final String id;
  final String invoiceNumber;
  final double dueAmount;
  final String status;
  final String? repairOrderId;
  final String? roNumber;
  final String? customerName;
  final String? customerMobile;
  final String? customerEmail;
  final String? registrationNumber;
  final String? jobCardNumber;
  final DateTime? dueDate;
  final String? paymentLink;

  String get vehicleLabel => registrationNumber ?? '—';

  @override
  List<Object?> get props => [id, invoiceNumber, dueAmount];
}
