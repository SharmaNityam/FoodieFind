import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/dish.dart';

class DietaryFilterChips extends StatelessWidget {
  final DietaryPreference? selectedPreference;
  final Function(DietaryPreference?) onSelected;

  const DietaryFilterChips({
    super.key,
    required this.selectedPreference,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildChip(
          label: 'All',
          icon: Icons.restaurant,
          isSelected: selectedPreference == null,
          color: const Color(0xFF6C63FF),
          onTap: () => onSelected(null),
        ),
        _buildChip(
          label: 'Veg',
          icon: Icons.eco,
          isSelected: selectedPreference == DietaryPreference.veg,
          color: const Color(0xFF00B894),
          onTap: () => onSelected(DietaryPreference.veg),
        ),
        _buildChip(
          label: 'Non-Veg',
          icon: Icons.restaurant_menu,
          isSelected: selectedPreference == DietaryPreference.nonVeg,
          color: const Color(0xFFFF6B6B),
          onTap: () => onSelected(DietaryPreference.nonVeg),
        ),
        _buildChip(
          label: 'Vegan',
          icon: Icons.nature_people,
          isSelected: selectedPreference == DietaryPreference.vegan,
          color: const Color(0xFF00CEC9),
          onTap: () => onSelected(DietaryPreference.vegan),
        ),
        _buildChip(
          label: 'Eggetarian',
          icon: Icons.egg,
          isSelected: selectedPreference == DietaryPreference.eggetarian,
          color: const Color(0xFFFDAB3D),
          onTap: () => onSelected(DietaryPreference.eggetarian),
        ),
        _buildChip(
          label: 'Jain',
          icon: Icons.spa,
          isSelected: selectedPreference == DietaryPreference.jain,
          color: const Color(0xFFA29BFE),
          onTap: () => onSelected(DietaryPreference.jain),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF2D3436),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}
