import '../../domain/entities/complaint.dart';

class ComplaintModel extends Complaint {
  const ComplaintModel({
    required super.id,
    required super.description,
    required super.source,
    required super.status,
    required super.createdAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      description: json['description'] as String,
      source: json['source'] as String? ?? 'manual',
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AiRecommendationModel extends AiRecommendation {
  const AiRecommendationModel({
    required super.id,
    required super.recommendationType,
    required super.title,
    super.description,
    super.isSelected,
  });

  factory AiRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiRecommendationModel(
      id: json['id'] as String,
      recommendationType: json['recommendation_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }
}
