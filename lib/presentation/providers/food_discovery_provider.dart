import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/algorithms/food_discovery_algorithm.dart';
import '../../data/datasources/mumbai_dishes_dataset.dart';
import '../../domain/entities/dish.dart';
import '../../domain/entities/recommendation.dart';

class FoodDiscoveryProvider extends ChangeNotifier {
  List<Recommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  DietaryPreference? _selectedDietaryPreference;
  String _searchQuery = '';

  // Mumbai default location (if GPS fails)
  static const double defaultLat = 19.0760;
  static const double defaultLon = 72.8777;

  List<Recommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  DietaryPreference? get selectedDietaryPreference =>
      _selectedDietaryPreference;
  String get searchQuery => _searchQuery;

  FoodDiscoveryProvider() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error =
            'Location services are disabled. Using default Mumbai location.';
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error =
              'Location permissions are denied. Using default Mumbai location.';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error =
            'Location permissions are permanently denied. Using default Mumbai location.';
        notifyListeners();
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
    } catch (e) {
      _error =
          'Failed to get location: ${e.toString()}. Using default Mumbai location.';
      notifyListeners();
    }
  }

  void setDietaryPreference(DietaryPreference? preference) {
    _selectedDietaryPreference = preference;
    notifyListeners();

    // Re-search if there's an active query
    if (_searchQuery.isNotEmpty) {
      searchDishes(_searchQuery);
    }
  }

  Future<void> searchDishes(String query) async {
    if (query.trim().isEmpty) {
      _recommendations = [];
      _error = null;
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get user location or use default
      final lat = _currentPosition?.latitude ?? defaultLat;
      final lon = _currentPosition?.longitude ?? defaultLon;

      // Get all dishes
      final allDishes = MumbaiDishesDataset.getDishes();

      // Run the discovery algorithm
      _recommendations = FoodDiscoveryAlgorithm.findRecommendations(
        query: query,
        userLat: lat,
        userLon: lon,
        dietaryPreference: _selectedDietaryPreference,
        allDishes: allDishes,
      );

      if (_recommendations.isEmpty) {
        _error =
            'No dishes found matching your criteria. Try different keywords or expand your dietary preferences.';
      }
    } catch (e) {
      _error = 'Error searching dishes: ${e.toString()}';
      _recommendations = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _recommendations = [];
    _error = null;
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    await _initializeLocation();

    // Re-search if there's an active query
    if (_searchQuery.isNotEmpty) {
      searchDishes(_searchQuery);
    }
  }
}
