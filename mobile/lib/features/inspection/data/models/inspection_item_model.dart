import '../../domain/entities/inspection_item.dart';

class InspectionItemModel extends InspectionItem {
  const InspectionItemModel({
    required super.id,
    required super.itemName,
    required super.category,
    required super.status,
    super.comment,
    super.imageUrl,
    super.inspectionType,
    super.templateId,
  });

  factory InspectionItemModel.fromJson(Map<String, dynamic> json) {
    return InspectionItemModel(
      id: json['id'] as String,
      itemName: json['item_name'] as String,
      category: json['category'] as String? ?? 'General',
      status: InspectionStatusExt.fromApi(json['status'] as String? ?? 'pending'),
      comment: json['comment'] as String?,
      imageUrl: json['image_url'] as String?,
      inspectionType: json['inspection_type'] as String? ?? 'pre',
      templateId: json['template_id'] as String?,
    );
  }
}
