import '../../domain/entities/inspection_item.dart';
import '../../domain/repositories/inspection_repository.dart';
import '../datasources/inspection_remote_datasource.dart';

class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl(this._datasource);

  final InspectionRemoteDatasource _datasource;

  @override
  Future<List<InspectionItem>> getInspectionItems(
    String repairOrderId, {
    String? type,
  }) {
    return _datasource.fetchInspectionItems(repairOrderId, type: type);
  }

  @override
  Future<List<InspectionItem>> initializeInspection(
    String repairOrderId, {
    String inspectionType = 'pre',
  }) {
    return _datasource.initializeInspection(
      repairOrderId,
      inspectionType: inspectionType,
    );
  }

  @override
  Future<InspectionItem> updateInspectionItem(
    String itemId, {
    InspectionStatus? status,
    String? comment,
    String? imageUrl,
  }) {
    return _datasource.updateInspectionItem(
      itemId,
      status: status,
      comment: comment,
      imageUrl: imageUrl,
    );
  }
}
