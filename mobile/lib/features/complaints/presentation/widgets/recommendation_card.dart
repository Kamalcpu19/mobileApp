import 'package:flutter/material.dart';

import '../../domain/entities/complaint.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onToggle,
  });

  final AiRecommendation recommendation;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: recommendation.isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: CheckboxListTile(
        value: recommendation.isSelected,
        onChanged: (v) => onToggle(v ?? false),
        title: Text(recommendation.title),
        subtitle: recommendation.description != null
            ? Text(recommendation.description!)
            : null,
        secondary: Chip(
          label: Text(
            recommendation.recommendationType,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
