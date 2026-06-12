import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDatasource {
  AppointmentRemoteDatasource(this._client);

  final ApiClient _client;

  Future<List<AppointmentModel>> fetchAppointments({
    String? category,
    String? search,
    String? date,
  }) async {
    final params = <String, dynamic>{};
    if (category != null && category != 'All') params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (date != null) params['date'] = date;

    final response = await _client.get(
      ApiConstants.appointments,
      queryParameters: params,
    );
    final data = response.data as List;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppointmentModel> fetchAppointmentById(String id) async {
    final response = await _client.get('${ApiConstants.appointments}/$id');
    return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
  }
}
