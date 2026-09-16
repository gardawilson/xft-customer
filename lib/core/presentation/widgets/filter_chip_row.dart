import 'package:flutter/material.dart';
import 'package:xft/core/theme/app_colors.dart';

/// A horizontally-scrollable row of pill-shaped filter/category chips.
///
/// Used by [OrdersTab], [NotificationPage], and anywhere a tab-chip row
/// is needed without a full [TabBar].
///
/// ```dart
/// FilterChipRow(
///   categories: const ['Semua', 'Pesanan', 'Promo'],
///   selected: _selected,
///   onSelected: (value) => setState(() => _selected = value),
/// )
/// ```
class FilterChipRow extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterChipRow({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _FilterChip(
              label: categories[i],
              isSelected: selected == categories[i],
              onTap: () => onSelected(categories[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surface
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.accent : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
