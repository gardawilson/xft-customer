import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:xft/core/theme/app_colors.dart';
import '../models/product_model.dart';

class ProductBadgeWidget extends StatelessWidget {
  final ProductBadge badge;
  final bool showLabel;

  const ProductBadgeWidget({
    super.key,
    required this.badge,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSignature = badge == ProductBadge.signature;
    return Container(
      padding: showLabel
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isSignature ? AppColors.xftBackground : AppColors.xftSurface,
        shape: showLabel ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: showLabel ? BorderRadius.circular(100) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSignature ? LucideIcons.crown : LucideIcons.star,
            color: isSignature ? AppColors.xftPrimary : AppColors.xftBackground,
            size: 12,
          ),
          if (showLabel) ...[
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
        ],
      ),
    );
  }
}
