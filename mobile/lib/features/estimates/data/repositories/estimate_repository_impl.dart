import '../../domain/entities/estimate.dart';
import '../../domain/repositories/estimate_repository.dart';
import '../datasources/estimate_remote_datasource.dart';

class EstimateRepositoryImpl implements EstimateRepository {
  EstimateRepositoryImpl(this._datasource);

  final EstimateRemoteDatasource _datasource;

  @override
  Future<Estimate?> getEstimate(String repairOrderId) {
    return _datasource.fetchEstimate(repairOrderId);
  }

  @override
  Future<Estimate> createEstimate(String repairOrderId) {
    return _datasource.createEstimate(repairOrderId);
  }

  @override
  Future<EstimateLineItem> addLineItem(
    String estimateId,
    Map<String, dynamic> item,
  ) {
    return _datasource.addLineItem(estimateId, item);
  }

  @override
  Future<Estimate> submitForApproval(String estimateId) {
    return _datasource.submitForApproval(estimateId);
  }

  @override
  Future<Estimate> generateAiEstimate(String repairOrderId) {
    return _datasource.generateAiEstimate(repairOrderId);
  }
}
