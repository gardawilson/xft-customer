import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/order/outlet_selection/models/outlet_model.dart';

class NearestOutletCard extends StatelessWidget {
  final OutletModel outlet;
  const NearestOutletCard({super.key, required this.outlet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.xftAccent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.xftBackground, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Icon(Icons.location_on, color: AppColors.xftPrimary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terdekat',
                          style: TextStyle(color: AppColors.xftPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outlet.name,
                          style: const TextStyle(color: AppColors.xftSurface, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(outlet.address, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(outlet.distance, style: const TextStyle(color: Colors.green, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(outlet.status, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => context.push('/list-product', extra: outlet),
              child: Container(
                color: AppColors.xftSurface,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(opacity: 0, child: Icon(Icons.chevron_right, size: 24, color: Colors.white)),
                    Text('Pilih outlet ini', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 20, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}