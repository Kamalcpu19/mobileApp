import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.category,
    required super.appointmentDate,
    super.appointmentTime,
    required super.status,
    super.customerName,
    super.customerMobile,
    super.registrationNumber,
    super.make,
    super.model,
    super.notes,
    super.isAutoReminder,
    super.customerId,
    super.vehicleId,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'AM',
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      appointmentTime: json['appointment_time'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      customerName: json['customer_name'] as String?,
      customerMobile: json['customer_mobile'] as String?,
      registrationNumber: json['registration_number'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      notes: json['notes'] as String?,
      isAutoReminder: json['is_auto_reminder'] as bool? ?? false,
      customerId: json['customer_id'] as String?,
      vehicleId: json['vehicle_id'] as String?,
    );
  }
}
