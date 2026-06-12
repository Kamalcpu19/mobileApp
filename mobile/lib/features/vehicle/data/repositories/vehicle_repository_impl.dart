import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';
import '../models/vehicle_model.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._datasource);

  final VehicleRemoteDatasource _datasource;

  @override
  Future<Vehicle?> lookupVehicle(String registrationNumber) {
    return _datasource.lookupVehicle(registrationNumber);
  }

  @override
  Future<OcrResult> recognizePlate(String imageBase64) {
    return _datasource.recognizePlate(imageBase64);
  }

  @override
  Future<Vehicle> createOrUpdateVehicle(Map<String, dynamic> data) {
    return _datasource.createOrUpdateVehicle(data);
  }

  @override
  Future<List<VehicleImage>> getVehicleImages(String vehicleId) {
    return _datasource.fetchVehicleImages(vehicleId);
  }

  @override
  Future<void> saveVehicleImage(
    String vehicleId,
    String imageType,
    String imageUrl,
  ) {
    return _datasource.saveVehicleImage(vehicleId, imageType, imageUrl);
  }

  @override
  Future<List<ServiceHistoryEntry>> getServiceHistory(String vehicleId) {
    return _datasource.fetchServiceHistory(vehicleId);
  }
}
