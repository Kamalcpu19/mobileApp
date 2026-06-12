import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  ComplaintRepositoryImpl(this._datasource);

  final ComplaintRemoteDatasource _datasource;

  @override
  Future<List<Complaint>> getComplaints(String repairOrderId) {
    return _datasource.fetchComplaints(repairOrderId);
  }

  @override
  Future<Complaint> addComplaint(
    String repairOrderId,
    String description, {
    String source = 'manual',
  }) {
    return _datasource.addComplaint(repairOrderId, description, source: source);
  }

  @override
  Future<List<AiRecommendation>> analyzeComplaints(String repairOrderId) {
    return _datasource.analyzeComplaints(repairOrderId);
  }

  @override
  Future<List<AiRecommendation>> getRecommendations(String repairOrderId) {
    return _datasource.fetchRecommendations(repairOrderId);
  }

  @override
  Future<AiRecommendation> toggleRecommendation(String id, bool isSelected) {
    return _datasource.toggleRecommendation(id, isSelected);
  }
}
