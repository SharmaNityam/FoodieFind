import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final int rank;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDetailsDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getRankColors(rank),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dish Name
                      Text(
                        recommendation.dish.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Restaurant Name
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 16,
                            color: Color(0xFF74B9FF),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              recommendation.dish.restaurantName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tags Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          // Distance
                          _buildInfoChip(
                            icon: Icons.location_on,
                            label:
                                '${recommendation.distance.toStringAsFixed(1)} km',
                            color: const Color(0xFF00B894),
                          ),
                          // Rating
                          _buildInfoChip(
                            icon: Icons.star,
                            label: recommendation.dish.rating.toString(),
                            color: const Color(0xFFFDAB3D),
                          ),
                          // Price
                          _buildInfoChip(
                            icon: Icons.currency_rupee,
                            label: recommendation.dish.price.toStringAsFixed(0),
                            color: const Color(0xFF6C63FF),
                          ),
                          // Dietary Type
                          _buildDietaryChip(recommendation.dish.dietaryType),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Relevance Score Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Match Score',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(
                                          recommendation.relevanceScore)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getScoreColor(
                                            recommendation.relevanceScore)
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${(recommendation.relevanceScore * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(
                                        recommendation.relevanceScore),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: const Color(0xFFE5E7EB),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: recommendation.relevanceScore,
                                minHeight: 8,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getScoreColor(recommendation.relevanceScore),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getRankColors(int rank) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      default:
        return [const Color(0xFF6C63FF), const Color(0xFF5A52D5)];
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return const Color(0xFF00B894);
    if (score >= 0.6) return const Color(0xFFFDAB3D);
    return const Color(0xFF6C63FF);
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryChip(DietaryPreference type) {
    IconData icon;
    Color color;
    String label;

    switch (type) {
      case DietaryPreference.veg:
        icon = Icons.eco;
        color = const Color(0xFF00B894);
        label = 'Veg';
        break;
      case DietaryPreference.nonVeg:
        icon = Icons.restaurant_menu;
        color = const Color(0xFFFF6B6B);
        label = 'Non-Veg';
        break;
      case DietaryPreference.vegan:
        icon = Icons.nature_people;
        color = const Color(0xFF00CEC9);
        label = 'Vegan';
        break;
      case DietaryPreference.eggetarian:
        icon = Icons.egg;
        color = const Color(0xFFFDAB3D);
        label = 'Egg';
        break;
      case DietaryPreference.jain:
        icon = Icons.spa;
        color = const Color(0xFFA29BFE);
        label = 'Jain';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recommendation.dish.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recommendation.dish.restaurantName,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                recommendation.dish.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Score Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 12),
              ...recommendation.scoreBreakdown.entries.map((entry) {
                // Use clean, user-friendly labels with icons
                final labelData = {
                  'textSimilarity': {
                    'label': 'Text Match',
                    'icon': Icons.text_fields,
                    'color': const Color(0xFF00B894)
                  },
                  'distanceScore': {
                    'label': 'Distance',
                    'icon': Icons.location_on,
                    'color': const Color(0xFF6C63FF)
                  },
                  'ratingScore': {
                    'label': 'Rating',
                    'icon': Icons.star,
                    'color': const Color(0xFFFDAB3D)
                  },
                  'priceScore': {
                    'label': 'Price',
                    'icon': Icons.attach_money,
                    'color': const Color(0xFFFF6B6B)
                  },
                };
                final data = labelData[entry.key];
                final label = data?['label'] as String? ?? entry.key;
                final icon = data?['icon'] as IconData? ?? Icons.info;
                final color =
                    data?['color'] as Color? ?? const Color(0xFF6C63FF);
                final percentage = (entry.value * 100).toStringAsFixed(0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms),
    );
  }
}
