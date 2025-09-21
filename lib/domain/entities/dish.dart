import 'package:equatable/equatable.dart';

enum DietaryPreference {
  veg,
  nonVeg,
  vegan,
  eggetarian,
  jain,
}

class Dish extends Equatable {
  final String id;
  final String name;
  final String restaurantName;
  final String restaurantId;
  final double latitude;
  final double longitude;
  final DietaryPreference dietaryType;
  final double rating;
  final double price;
  final String cuisine;
  final String description;
  final List<String> tags;

  const Dish({
    required this.id,
    required this.name,
    required this.restaurantName,
    required this.restaurantId,
    required this.latitude,
    required this.longitude,
    required this.dietaryType,
    required this.rating,
    required this.price,
    required this.cuisine,
    required this.description,
    required this.tags,
  });

  @override
  List<Object> get props => [
        id,
        name,
        restaurantName,
        restaurantId,
        latitude,
        longitude,
        dietaryType,
        rating,
        price,
        cuisine,
        description,
        tags,
      ];
}
