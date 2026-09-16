import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/theme/app_colors.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String _selectedCategory = 'Aktif';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.xftBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildTabButton('Aktif'),
                const SizedBox(width: 8),
                _buildTabButton('Pesanan Selesai'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String categoryName) {
    final isActive = _selectedCategory == categoryName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.xftSurface
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          categoryName,
          style: TextStyle(
            color: isActive ? AppColors.xftAccent : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
