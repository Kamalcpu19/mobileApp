import '../entities/estimate.dart';

abstract class EstimateRepository {
  Future<Estimate?> getEstimate(String repairOrderId);

  Future<Estimate> createEstimate(String repairOrderId);

  Future<EstimateLineItem> addLineItem(
    String estimateId,
    Map<String, dynamic> item,
  );

  Future<Estimate> submitForApproval(String estimateId);

  Future<Estimate> generateAiEstimate(String repairOrderId);
}
