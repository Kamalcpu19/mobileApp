import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAppointments({
    String? category,
    String? search,
    String? date,
  });

  Future<Appointment> getAppointmentById(String id);
}
