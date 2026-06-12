import '../entities/inspection_item.dart';

abstract class InspectionRepository {
  Future<List<InspectionItem>> getInspectionItems(
    String repairOrderId, {
    String? type,
  });

  Future<List<InspectionItem>> initializeInspection(
    String repairOrderId, {
    String inspectionType = 'pre',
  });

  Future<InspectionItem> updateInspectionItem(
    String itemId, {
    InspectionStatus? status,
    String? comment,
    String? imageUrl,
  });
}
