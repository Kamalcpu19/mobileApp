import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../models/vehicle_model.dart';

class VehicleRemoteDatasource {
  VehicleRemoteDatasource(this._client);

  final ApiClient _client;

  Future<VehicleModel?> lookupVehicle(String registrationNumber) async {
    try {
      final response = await _client.get(
        '${ApiConstants.vehicles}/lookup/$registrationNumber',
      );
      return VehicleModel.fromJson(response.data as Map<String, dynamic>);
    } on ApiException catch (_) {
      return null;
    }
  }

  Future<OcrResultModel> recognizePlate(String imageBase64) async {
    final response = await _client.post(
      '${ApiConstants.vehicles}/ocr',
      data: {'imageBase64': imageBase64},
    );
    return OcrResultModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VehicleModel> createOrUpdateVehicle(Map<String, dynamic> body) async {
    final response = await _client.post(ApiConstants.vehicles, data: body);
    return VehicleModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<VehicleImageModel>> fetchVehicleImages(String vehicleId) async {
    final response =
        await _client.get('${ApiConstants.vehicles}/$vehicleId/images');
    final data = response.data as List;
    return data
        .map((e) => VehicleImageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveVehicleImage(
    String vehicleId,
    String imageType,
    String imageUrl,
  ) async {
    await _client.post(
      '${ApiConstants.vehicles}/$vehicleId/images',
      data: {'imageType': imageType, 'imageUrl': imageUrl},
    );
  }

  Future<List<ServiceHistoryModel>> fetchServiceHistory(String vehicleId) async {
    final response =
        await _client.get('${ApiConstants.vehicles}/$vehicleId/history');
    final raw = response.data;
    final list = raw is Map ? raw['history'] ?? raw['entries'] ?? [] : raw;
    return (list as List)
        .map((e) => ServiceHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
