enum AppointmentCategory {
  all,
  am,
  pm,
  app,
  callIn,
  autoReminder,
}

class Appointment {
  const Appointment({
    required this.id,
    required this.category,
    required this.appointmentDate,
    this.appointmentTime,
    required this.status,
    this.customerName,
    this.customerMobile,
    this.registrationNumber,
    this.make,
    this.model,
    this.notes,
    this.isAutoReminder = false,
    this.customerId,
    this.vehicleId,
  });

  final String id;
  final String category;
  final DateTime appointmentDate;
  final String? appointmentTime;
  final String status;
  final String? customerName;
  final String? customerMobile;
  final String? registrationNumber;
  final String? make;
  final String? model;
  final String? notes;
  final bool isAutoReminder;
  final String? customerId;
  final String? vehicleId;

  String get vehicleDisplay {
    if (registrationNumber == null) return 'No vehicle';
    final parts = [registrationNumber, make, model].where((e) => e != null);
    return parts.join(' · ');
  }
}
