enum InspectionStatus { pending, ok, actionRequired, urgent }

extension InspectionStatusExt on InspectionStatus {
  String get apiValue {
    switch (this) {
      case InspectionStatus.pending:
        return 'pending';
      case InspectionStatus.ok:
        return 'ok';
      case InspectionStatus.actionRequired:
        return 'action_required';
      case InspectionStatus.urgent:
        return 'urgent';
    }
  }

  static InspectionStatus fromApi(String value) {
    switch (value) {
      case 'ok':
        return InspectionStatus.ok;
      case 'action_required':
        return InspectionStatus.actionRequired;
      case 'urgent':
        return InspectionStatus.urgent;
      default:
        return InspectionStatus.pending;
    }
  }
}

class InspectionItem {
  const InspectionItem({
    required this.id,
    required this.itemName,
    required this.category,
    required this.status,
    this.comment,
    this.imageUrl,
    this.inspectionType = 'pre',
    this.templateId,
  });

  final String id;
  final String itemName;
  final String category;
  final InspectionStatus status;
  final String? comment;
  final String? imageUrl;
  final String inspectionType;
  final String? templateId;
}
