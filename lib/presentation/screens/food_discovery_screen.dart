import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/food_discovery_provider.dart';
import '../widgets/dietary_filter_chips.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/search_bar_widget.dart';

class FoodDiscoveryScreen extends StatelessWidget {
  const FoodDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer<FoodDiscoveryProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                // App Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF8E53)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: Colors.white,
                                size: 28,
                              ),
                            ).animate().scale(duration: 400.ms),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Food Discovery',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ).animate().fadeIn(duration: 500.ms),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: provider.currentPosition != null
                                            ? const Color(0xFF00B894)
                                            : const Color(0xFFFF6B6B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        provider.currentPosition != null
                                            ? 'Location found'
                                            : 'Using Mumbai location',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 200.ms),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: provider.refreshLocation,
                              icon: const Icon(Icons.my_location),
                              color: const Color(0xFF6C63FF),
                            ).animate().fadeIn(delay: 300.ms),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Search Bar
                        SearchBarWidget(
                          onSearch: provider.searchDishes,
                          initialValue: provider.searchQuery,
                        ).animate().slideY(
                              begin: 0.2,
                              duration: 600.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      ],
                    ),
                  ),
                ),

                // Dietary Filters
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dietary Preference',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3436),
                          ),
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 12),
                        DietaryFilterChips(
                          selectedPreference:
                              provider.selectedDietaryPreference,
                          onSelected: provider.setDietaryPreference,
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                ),

                // Results Section
                if (provider.isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: List.generate(
                          3,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildShimmerCard(),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (provider.error != null)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFFFFDDDD),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF6B6B),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF2D3436),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 400.ms),
                  )
                else if (provider.recommendations.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recommendation =
                              provider.recommendations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: RecommendationCard(
                              recommendation: recommendation,
                              rank: index + 1,
                            ).animate().slideX(
                                  begin: 0.2,
                                  delay: (index * 100).ms,
                                  duration: 600.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                          );
                        },
                        childCount: provider.recommendations.length,
                      ),
                    ),
                  )
                else if (provider.searchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 400.ms),
                  )
                else
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6C63FF).withOpacity(0.1),
                                  const Color(0xFFFF6B6B).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.search,
                              size: 48,
                              color: Color(0xFF6C63FF),
                            ),
                          ).animate().scale(duration: 600.ms).then().shimmer(
                              duration: const Duration(seconds: 2),
                              delay: const Duration(seconds: 1)),
                          const SizedBox(height: 20),
                          const Text(
                            'Discover Amazing Food',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Search for your favorite dishes\nfrom restaurants near you',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
