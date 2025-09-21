import 'package:flutter_test/flutter_test.dart';
import 'package:food_discovery_app/core/algorithms/food_discovery_algorithm.dart';
import 'package:food_discovery_app/domain/entities/dish.dart';
import 'package:food_discovery_app/data/datasources/mumbai_dishes_dataset.dart';

void main() {
  group('FoodDiscoveryAlgorithm', () {
    late List<Dish> testDishes;
    const double userLat = 19.0760; // Mumbai location
    const double userLon = 72.8777;

    setUp(() {
      testDishes = MumbaiDishesDataset.getDishes();
    });

    test('should find exactly 3 recommendations for valid query', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'biryani',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: null,
        allDishes: testDishes,
      );

      expect(recommendations.length, 3);
      // Should prioritize biryani dishes
      expect(recommendations.first.dish.name.toLowerCase().contains('biryani'),
          true);
    });

    test('should handle typos and return relevant results', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'briyani', // Typo
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: null,
        allDishes: testDishes,
      );

      expect(recommendations.length, 3);
      // Should find biryani despite typo
      expect(recommendations.first.dish.name.toLowerCase().contains('biryani'),
          true);
    });

    test('should handle partial matches', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'pasta',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: null,
        allDishes: testDishes,
      );

      expect(recommendations.length, 3);
      // Should find pasta dishes
      expect(
        recommendations.first.dish.name.toLowerCase().contains('pasta') ||
            recommendations.first.dish.tags.any((tag) => tag.contains('pasta')),
        true,
      );
    });

    test('should respect vegetarian dietary preference', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'biryani',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: DietaryPreference.veg,
        allDishes: testDishes,
      );

      expect(recommendations.length, greaterThan(0));
      expect(
        recommendations.every((r) =>
            r.dish.dietaryType == DietaryPreference.veg ||
            r.dish.dietaryType == DietaryPreference.vegan ||
            r.dish.dietaryType == DietaryPreference.jain),
        true,
      );
    });

    test('should never show non-veg items to veg users', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'chicken',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: DietaryPreference.veg,
        allDishes: testDishes,
      );

      // Should return veg alternatives or empty
      expect(
        recommendations.every((r) =>
            r.dish.dietaryType != DietaryPreference.nonVeg &&
            r.dish.dietaryType != DietaryPreference.eggetarian),
        true,
      );
    });

    test('should expand search radius when insufficient results', () {
      // Test with a location far from restaurants
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'pizza',
        userLat: 19.5000, // Far north location
        userLon: 72.8777,
        dietaryPreference: null,
        allDishes: testDishes,
      );

      expect(recommendations.length, 3);
      // Should find results even from far locations
      expect(recommendations.any((r) => r.distance > 2.0), true);
    });

    test('should rank by relevance score', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'pizza',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: null,
        allDishes: testDishes,
      );

      // Check that recommendations are sorted by relevance
      for (int i = 0; i < recommendations.length - 1; i++) {
        expect(
          recommendations[i].relevanceScore >=
              recommendations[i + 1].relevanceScore,
          true,
        );
      }
    });

    test('should complete search within 200ms', () {
      final stopwatch = Stopwatch()..start();

      FoodDiscoveryAlgorithm.findRecommendations(
        query: 'biryani',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: null,
        allDishes: testDishes,
      );

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('should handle jain dietary preference correctly', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'pizza',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: DietaryPreference.jain,
        allDishes: testDishes,
      );

      expect(
        recommendations
            .every((r) => r.dish.dietaryType == DietaryPreference.jain),
        true,
      );
    });

    test('should handle eggetarian preference correctly', () {
      final recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: 'noodles',
        userLat: userLat,
        userLon: userLon,
        dietaryPreference: DietaryPreference.eggetarian,
        allDishes: testDishes,
      );

      expect(
        recommendations.every((r) =>
            r.dish.dietaryType == DietaryPreference.veg ||
            r.dish.dietaryType == DietaryPreference.vegan ||
            r.dish.dietaryType == DietaryPreference.jain ||
            r.dish.dietaryType == DietaryPreference.eggetarian),
        true,
      );
    });
  });
}
