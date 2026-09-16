import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:xft/core/theme/app_colors.dart';

enum ProductBadge {
  signature,
  favorite;

  static ProductBadge? fromString(String? value) {
    if (value == 'signature') return ProductBadge.signature;
    if (value == 'favorite') return ProductBadge.favorite;
    return null;
  }
}

class ProductBadgeWidget extends StatelessWidget {
  final ProductBadge badge;

  const ProductBadgeWidget({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final bool isSignature = badge == ProductBadge.signature;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSignature ? AppColors.xftBackground : AppColors.xftSurface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSignature ? LucideIcons.crown : LucideIcons.star,
            color: isSignature ? AppColors.xftPrimary : AppColors.xftBackground,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            isSignature ? 'Signature' : 'Favorite',
            style: TextStyle(
              color: isSignature
                  ? AppColors.xftPrimary
                  : AppColors.xftBackground,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
