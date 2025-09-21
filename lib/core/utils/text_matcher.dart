import 'dart:math';

class TextMatcher {
  // Levenshtein distance for typo tolerance
  static int levenshteinDistance(String s1, String s2) {
    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce(min);
      }
    }

    return matrix[s1.length][s2.length];
  }

  // Calculate similarity score (0-1)
  static double calculateSimilarity(String query, String target) {
    query = query.toLowerCase().trim();
    target = target.toLowerCase().trim();

    // Perfect match
    if (query == target) return 1.0;

    // Contains match
    if (target.contains(query) || query.contains(target)) {
      return 0.9;
    }

    // Word-based matching
    List<String> queryWords = query.split(' ');
    List<String> targetWords = target.split(' ');

    double wordMatchScore = 0;
    for (String qWord in queryWords) {
      for (String tWord in targetWords) {
        if (qWord == tWord) {
          wordMatchScore += 1.0;
        } else if (tWord.contains(qWord) || qWord.contains(tWord)) {
          wordMatchScore += 0.8;
        } else {
          // Fuzzy match for typos
          int distance = levenshteinDistance(qWord, tWord);
          int maxLen = max(qWord.length, tWord.length);
          if (distance <= maxLen * 0.3) {
            // Allow 30% character difference
            wordMatchScore += 0.6 * (1 - distance / maxLen);
          }
        }
      }
    }

    double normalizedWordScore = wordMatchScore / queryWords.length;

    // Levenshtein distance for overall similarity
    int distance = levenshteinDistance(query, target);
    int maxLen = max(query.length, target.length);
    double levenshteinScore = 1 - (distance / maxLen);

    // Combine scores
    return (normalizedWordScore * 0.7 + levenshteinScore * 0.3).clamp(0.0, 1.0);
  }

  // Common food synonyms and variations
  static final Map<String, List<String>> synonyms = {
    'biryani': ['biriyani', 'briyani', 'biriani'],
    'pasta': ['spaghetti', 'penne', 'fusilli', 'macaroni'],
    'pizza': ['pizzas', 'piza'],
    'burger': ['burgers', 'hamburger'],
    'sandwich': ['sandwiches', 'sandwhich'],
    'coffee': ['koffee', 'kaapi', 'cafe'],
    'tea': ['chai', 'cha'],
    'chicken': ['chiken', 'chickin'],
    'paneer': ['panir', 'cottage cheese'],
    'rice': ['chawal', 'bhat'],
    'bread': ['roti', 'chapati', 'naan'],
  };

  static List<String> expandQuery(String query) {
    List<String> expanded = [query];
    String lowerQuery = query.toLowerCase();

    // Check for synonyms
    for (var entry in synonyms.entries) {
      if (entry.key == lowerQuery || entry.value.contains(lowerQuery)) {
        expanded.add(entry.key);
        expanded.addAll(entry.value);
      }
    }

    return expanded.toSet().toList();
  }
}
