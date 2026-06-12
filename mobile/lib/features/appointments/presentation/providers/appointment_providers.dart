import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

final appointmentDatasourceProvider = Provider<AppointmentRemoteDatasource>(
  (ref) => AppointmentRemoteDatasource(ref.watch(apiClientProvider)),
);

final appointmentRepositoryProvider = Provider<AppointmentRepository>(
  (ref) => AppointmentRepositoryImpl(ref.watch(appointmentDatasourceProvider)),
);

class AppointmentFilter {
  const AppointmentFilter({this.category = 'All', this.search = ''});

  final String category;
  final String search;

  AppointmentFilter copyWith({String? category, String? search}) {
    return AppointmentFilter(
      category: category ?? this.category,
      search: search ?? this.search,
    );
  }
}

final appointmentFilterProvider =
    StateProvider<AppointmentFilter>((ref) => const AppointmentFilter());

final appointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) {
  final filter = ref.watch(appointmentFilterProvider);
  final repo = ref.watch(appointmentRepositoryProvider);
  return repo.getAppointments(
    category: filter.category == 'All' ? null : filter.category,
    search: filter.search.isEmpty ? null : filter.search,
  );
});

final appointmentDetailProvider =
    FutureProvider.autoDispose.family<Appointment, String>((ref, id) {
  final repo = ref.watch(appointmentRepositoryProvider);
  return repo.getAppointmentById(id);
});
