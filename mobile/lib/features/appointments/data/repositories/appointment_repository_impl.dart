import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl(this._datasource);

  final AppointmentRemoteDatasource _datasource;

  @override
  Future<List<Appointment>> getAppointments({
    String? category,
    String? search,
    String? date,
  }) {
    return _datasource.fetchAppointments(
      category: category,
      search: search,
      date: date,
    );
  }

  @override
  Future<Appointment> getAppointmentById(String id) {
    return _datasource.fetchAppointmentById(id);
  }
}
