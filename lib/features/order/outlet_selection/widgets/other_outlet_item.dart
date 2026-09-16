import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/order/outlet_selection/models/outlet_model.dart';

class OtherOutletItem extends StatelessWidget {
  final OutletModel outlet;

  const OtherOutletItem({super.key, required this.outlet});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/list-product', extra: outlet),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: AppColors.xftAccent, borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Icon(Icons.location_on, color: AppColors.xftPrimary, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outlet.name,
                    style: const TextStyle(color: AppColors.xftSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(outlet.address, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(outlet.distance, style: const TextStyle(color: AppColors.xftPrimary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(outlet.status, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              height: 54,
              child: Center(child: Icon(Icons.chevron_right, color: Colors.black54, size: 24)),
            ),
          ],
        ),
      ),
    );
  }
}