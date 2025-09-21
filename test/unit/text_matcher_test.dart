import 'package:flutter_test/flutter_test.dart';
import 'package:food_discovery_app/core/utils/text_matcher.dart';

void main() {
  group('TextMatcher', () {
    group('levenshteinDistance', () {
      test('should return 0 for identical strings', () {
        expect(TextMatcher.levenshteinDistance('biryani', 'biryani'), 0);
      });

      test('should calculate correct distance for typos', () {
        expect(TextMatcher.levenshteinDistance('biryani', 'briyani'),
            2); // swapped 'ir' to 'ri'
        expect(TextMatcher.levenshteinDistance('biryani', 'biriyani'),
            1); // added 'i'
        expect(
            TextMatcher.levenshteinDistance('pizza', 'piza'), 1); // removed 'z'
      });

      test('should be case insensitive', () {
        expect(TextMatcher.levenshteinDistance('Pizza', 'pizza'), 0);
        expect(TextMatcher.levenshteinDistance('BIRYANI', 'biryani'), 0);
      });
    });

    group('calculateSimilarity', () {
      test('should return 1.0 for exact matches', () {
        expect(TextMatcher.calculateSimilarity('pizza', 'pizza'), 1.0);
        expect(TextMatcher.calculateSimilarity('Pizza', 'PIZZA'), 1.0);
      });

      test('should return high score for contains match', () {
        expect(TextMatcher.calculateSimilarity('pasta', 'Penne Pasta'), 0.9);
        expect(TextMatcher.calculateSimilarity('burger', 'Cheese Burger'), 0.9);
      });

      test('should handle typos with reasonable scores', () {
        final score = TextMatcher.calculateSimilarity('briyani', 'biryani');
        expect(score, greaterThan(0.5)); // Adjusted threshold
        expect(score, lessThan(1.0));
      });

      test('should handle partial word matches', () {
        final score = TextMatcher.calculateSimilarity('veg', 'vegetarian');
        expect(score, greaterThan(0.5));
      });

      test('should return low scores for unrelated strings', () {
        expect(
            TextMatcher.calculateSimilarity('pizza', 'biryani'), lessThan(0.3));
        expect(
            TextMatcher.calculateSimilarity('pasta', 'burger'), lessThan(0.3));
      });
    });

    group('expandQuery', () {
      test('should expand known synonyms', () {
        final expanded = TextMatcher.expandQuery('biryani');
        expect(expanded, contains('biryani'));
        expect(expanded, contains('biriyani'));
        expect(expanded, contains('briyani'));
      });

      test('should handle reverse synonym lookup', () {
        final expanded = TextMatcher.expandQuery('briyani');
        expect(expanded, contains('biryani'));
      });

      test('should return single item for unknown queries', () {
        final expanded = TextMatcher.expandQuery('unknown_food');
        expect(expanded.length, 1);
        expect(expanded.first, 'unknown_food');
      });

      test('should be case insensitive', () {
        final expanded = TextMatcher.expandQuery('PIZZA');
        expect(expanded.length, greaterThan(1));
      });
    });
  });
}
