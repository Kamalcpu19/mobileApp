class Complaint {
  const Complaint({
    required this.id,
    required this.description,
    required this.source,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String description;
  final String source;
  final String status;
  final DateTime createdAt;
}

class AiRecommendation {
  const AiRecommendation({
    required this.id,
    required this.recommendationType,
    required this.title,
    this.description,
    this.isSelected = false,
  });

  final String id;
  final String recommendationType;
  final String title;
  final String? description;
  final bool isSelected;
}
