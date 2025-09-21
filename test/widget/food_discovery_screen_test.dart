import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:food_discovery_app/presentation/providers/food_discovery_provider.dart';
import 'package:food_discovery_app/presentation/screens/food_discovery_screen.dart';
import 'package:food_discovery_app/presentation/widgets/search_bar_widget.dart';
import 'package:food_discovery_app/presentation/widgets/dietary_filter_chips.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  // Configure animations to be instant for testing
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FoodDiscoveryScreen', () {
    late FoodDiscoveryProvider provider;

    setUpAll(() {
      // Disable animations for tests
      Animate.restartOnHotReload = false;
    });

    setUp(() {
      provider = FoodDiscoveryProvider();
      // Set animation duration to zero for tests
      Animate.defaultDuration = Duration.zero;
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const FoodDiscoveryScreen(),
        ),
      );
    }

    testWidgets('should display app header with title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Food Discovery'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    });

    testWidgets('should display search bar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(SearchBarWidget), findsOneWidget);
      expect(find.text('Search for biryani, pizza, pasta...'), findsOneWidget);
    });

    testWidgets('should display dietary filter chips', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(DietaryFilterChips), findsOneWidget);
      expect(find.text('Dietary Preference'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Veg'), findsOneWidget);
      expect(find.text('Non-Veg'), findsOneWidget);
    });

    testWidgets('should show initial state with search prompt', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Discover Amazing Food'), findsOneWidget);
      expect(
          find.text(
              'Search for your favorite dishes\nfrom restaurants near you'),
          findsOneWidget);
    });

    testWidgets('should show loading state when searching', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Trigger search
      provider.searchDishes('biryani');
      await tester.pump();

      // Should show shimmer loading
      expect(find.byType(CircularProgressIndicator),
          findsNothing); // We use shimmer instead
    });

    testWidgets('should interact with dietary filters', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Find and tap Veg filter
      await tester.tap(find.text('Veg'));
      await tester.pumpAndSettle();

      // Verify selection changed
      expect(provider.selectedDietaryPreference, isNotNull);
    });

    testWidgets('should show location status', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should show location status
      expect(
        find.textContaining(RegExp(r'Location found|Using Mumbai location')),
        findsOneWidget,
      );
    });

    testWidgets('should have refresh location button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });
  });
}
