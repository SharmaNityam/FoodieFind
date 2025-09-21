import 'package:equatable/equatable.dart';
import 'dish.dart';

class Recommendation extends Equatable {
  final Dish dish;
  final double distance; // in kilometers
  final double relevanceScore;
  final Map<String, double> scoreBreakdown;

  const Recommendation({
    required this.dish,
    required this.distance,
    required this.relevanceScore,
    required this.scoreBreakdown,
  });

  @override
  List<Object> get props => [dish, distance, relevanceScore, scoreBreakdown];
}
