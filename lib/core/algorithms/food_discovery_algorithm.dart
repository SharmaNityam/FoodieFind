import 'dart:math';
import '../../domain/entities/dish.dart';
import '../../domain/entities/recommendation.dart';
import '../utils/text_matcher.dart';
import '../utils/location_utils.dart';

class FoodDiscoveryAlgorithm {
  static const double initialRadiusKm = 5.0;
  static const double radiusIncrementKm = 2.0;
  static const double maxRadiusKm = 25.0;
  static const int targetRecommendations = 3;

  static List<Recommendation> findRecommendations({
    required String query,
    required double userLat,
    required double userLon,
    required DietaryPreference? dietaryPreference,
    required List<Dish> allDishes,
  }) {
    final stopwatch = Stopwatch()..start();

    // Expand query to include synonyms
    final expandedQueries = TextMatcher.expandQuery(query);

    // Start with initial radius
    double currentRadius = initialRadiusKm;
    List<Recommendation> recommendations = [];

    while (recommendations.length < targetRecommendations &&
        currentRadius <= maxRadiusKm) {
      // Filter dishes within radius and dietary preference
      final eligibleDishes = allDishes.where((dish) {
        // Check dietary preference
        if (!_isDietaryCompatible(dish.dietaryType, dietaryPreference)) {
          return false;
        }

        // Check distance
        final distance = LocationUtils.calculateDistance(
          userLat,
          userLon,
          dish.latitude,
          dish.longitude,
        );
        return distance <= currentRadius;
      }).toList();

      // Score and rank dishes
      final scoredDishes = <_ScoredDish>[];

      for (final dish in eligibleDishes) {
        // Skip if already recommended
        if (recommendations.any((r) => r.dish.id == dish.id)) {
          continue;
        }

        final distance = LocationUtils.calculateDistance(
          userLat,
          userLon,
          dish.latitude,
          dish.longitude,
        );

        // Calculate text similarity
        double maxSimilarity = 0;
        for (final expandedQuery in expandedQueries) {
          // Check dish name
          final nameSimilarity = TextMatcher.calculateSimilarity(
            expandedQuery,
            dish.name,
          );
          maxSimilarity = max(maxSimilarity, nameSimilarity);

          // Check tags
          for (final tag in dish.tags) {
            final tagSimilarity = TextMatcher.calculateSimilarity(
              expandedQuery,
              tag,
            );
            maxSimilarity = max(maxSimilarity, tagSimilarity * 0.8);
          }

          // Check cuisine
          final cuisineSimilarity = TextMatcher.calculateSimilarity(
            expandedQuery,
            dish.cuisine,
          );
          maxSimilarity = max(maxSimilarity, cuisineSimilarity * 0.7);

          // Check description
          final descriptionWords = dish.description.toLowerCase().split(' ');
          for (final word in descriptionWords) {
            if (word.length > 3) {
              // Skip small words
              final wordSimilarity = TextMatcher.calculateSimilarity(
                expandedQuery,
                word,
              );
              maxSimilarity = max(maxSimilarity, wordSimilarity * 0.5);
            }
          }
        }

        // Calculate distance score (closer is better)
        final distanceScore = 1 - (distance / maxRadiusKm).clamp(0.0, 1.0);

        // Calculate rating score
        final ratingScore = dish.rating / 5.0;

        // Calculate price score (moderate prices preferred)
        final priceScore = _calculatePriceScore(dish.price);

        // Combine scores - only include if text match is meaningful
        if (maxSimilarity > 0.5) {
          // Increased minimum text match threshold to prevent false matches
          final relevanceScore = _calculateRelevanceScore(
            textSimilarity: maxSimilarity,
            distanceScore: distanceScore,
            ratingScore: ratingScore,
            priceScore: priceScore,
          );
          scoredDishes.add(_ScoredDish(
            dish: dish,
            distance: distance,
            relevanceScore: relevanceScore,
            scoreBreakdown: {
              'textSimilarity': maxSimilarity,
              'distanceScore': distanceScore,
              'ratingScore': ratingScore,
              'priceScore': priceScore,
            },
          ));
        }
      }

      // Sort by relevance score
      scoredDishes.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      // Add top recommendations
      for (final scored in scoredDishes) {
        if (recommendations.length < targetRecommendations) {
          recommendations.add(Recommendation(
            dish: scored.dish,
            distance: scored.distance,
            relevanceScore: scored.relevanceScore,
            scoreBreakdown: scored.scoreBreakdown,
          ));
        }
      }

      // Expand radius if needed
      if (recommendations.length < targetRecommendations) {
        currentRadius += radiusIncrementKm;
      }
    }

    // If still not enough recommendations, add best matches regardless of radius
    if (recommendations.length < targetRecommendations) {
      final remainingDishes = allDishes.where((dish) {
        return _isDietaryCompatible(dish.dietaryType, dietaryPreference) &&
            !recommendations.any((r) => r.dish.id == dish.id);
      }).toList();

      // Score remaining dishes
      final scoredRemaining = <_ScoredDish>[];
      for (final dish in remainingDishes) {
        final distance = LocationUtils.calculateDistance(
          userLat,
          userLon,
          dish.latitude,
          dish.longitude,
        );

        double maxSimilarity = 0;
        for (final expandedQuery in expandedQueries) {
          final similarity = TextMatcher.calculateSimilarity(
            expandedQuery,
            dish.name,
          );
          maxSimilarity = max(maxSimilarity, similarity);
        }

        if (maxSimilarity > 0.5) {
          scoredRemaining.add(_ScoredDish(
            dish: dish,
            distance: distance,
            relevanceScore: maxSimilarity * dish.rating / 5.0,
            scoreBreakdown: {
              'textSimilarity': maxSimilarity,
              'distanceScore': 0.0,
              'ratingScore': dish.rating / 5.0,
              'priceScore': _calculatePriceScore(dish.price),
            },
          ));
        }
      }

      scoredRemaining
          .sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      for (final scored in scoredRemaining) {
        if (recommendations.length < targetRecommendations) {
          recommendations.add(Recommendation(
            dish: scored.dish,
            distance: scored.distance,
            relevanceScore: scored.relevanceScore,
            scoreBreakdown: scored.scoreBreakdown,
          ));
        }
      }
    }

    stopwatch.stop();
    print('Search completed in ${stopwatch.elapsedMilliseconds}ms');

    return recommendations.take(targetRecommendations).toList();
  }

  static bool _isDietaryCompatible(
    DietaryPreference dishType,
    DietaryPreference? userPreference,
  ) {
    if (userPreference == null) return true;

    // Show only dishes that exactly match the selected dietary preference
    return dishType == userPreference;
  }

  static double _calculatePriceScore(double price) {
    // Prefer moderate prices (200-400 range)
    if (price >= 200 && price <= 400) {
      return 1.0;
    } else if (price < 200) {
      return 0.8 + (price / 1000); // Slight preference for not too cheap
    } else {
      return 0.8 - ((price - 400) / 2000).clamp(0.0, 0.6);
    }
  }

  static double _calculateRelevanceScore({
    required double textSimilarity,
    required double distanceScore,
    required double ratingScore,
    required double priceScore,
  }) {
    // Weighted combination - prioritize text relevance over distance
    return (textSimilarity * 0.7) +
        (distanceScore * 0.1) +
        (ratingScore * 0.15) +
        (priceScore * 0.05);
  }
}

class _ScoredDish {
  final Dish dish;
  final double distance;
  final double relevanceScore;
  final Map<String, double> scoreBreakdown;

  _ScoredDish({
    required this.dish,
    required this.distance,
    required this.relevanceScore,
    required this.scoreBreakdown,
  });
}
