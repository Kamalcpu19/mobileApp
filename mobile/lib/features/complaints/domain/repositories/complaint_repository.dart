import '../entities/complaint.dart';

abstract class ComplaintRepository {
  Future<List<Complaint>> getComplaints(String repairOrderId);

  Future<Complaint> addComplaint(
    String repairOrderId,
    String description, {
    String source = 'manual',
  });

  Future<List<AiRecommendation>> analyzeComplaints(String repairOrderId);

  Future<List<AiRecommendation>> getRecommendations(String repairOrderId);

  Future<AiRecommendation> toggleRecommendation(String id, bool isSelected);
}
