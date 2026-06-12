import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<Vehicle?> lookupVehicle(String registrationNumber);

  Future<OcrResult> recognizePlate(String imageBase64);

  Future<Vehicle> createOrUpdateVehicle(Map<String, dynamic> data);

  Future<List<VehicleImage>> getVehicleImages(String vehicleId);

  Future<void> saveVehicleImage(
    String vehicleId,
    String imageType,
    String imageUrl,
  );

  Future<List<ServiceHistoryEntry>> getServiceHistory(String vehicleId);
}
