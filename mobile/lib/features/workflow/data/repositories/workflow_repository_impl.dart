import '../../domain/entities/spare.dart';
import '../../domain/entities/workflow_order.dart';
import '../../domain/repositories/workflow_repository.dart';
import '../datasources/workflow_remote_datasource.dart';

class WorkflowRepositoryImpl implements WorkflowRepository {
  WorkflowRepositoryImpl(this._remoteDataSource);

  final WorkflowRemoteDataSource _remoteDataSource;

  @override
  Future<List<WorkflowOrder>> getOrdersByStage(String stage, {String? search}) {
    return _remoteDataSource.getOrdersByStage(stage, search: search);
  }

  @override
  Future<WorkflowOrder> getOrderById(String id) {
    return _remoteDataSource.getOrderById(id);
  }

  @override
  Future<List<StageTimelineEntry>> getTimeline(String repairOrderId) {
    return _remoteDataSource.getTimeline(repairOrderId);
  }

  @override
  Future<List<Spare>> getSparesForOrder(String repairOrderId) {
    return _remoteDataSource.getSparesForOrder(repairOrderId);
  }

  @override
  Future<WorkflowOrder> updateStage(String repairOrderId, String stage, {String? notes}) {
    return _remoteDataSource.updateStage(repairOrderId, stage, notes: notes);
  }

  @override
  Future<Map<String, dynamic>?> getJobCard(String repairOrderId) {
    return _remoteDataSource.getJobCard(repairOrderId);
  }
}
