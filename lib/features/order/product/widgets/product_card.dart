import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:xft/core/theme/app_colors.dart';
import '../models/product_model.dart';
import 'product_badge_widget.dart';
import 'product_detail_sheet.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int outletId;
  final void Function(Product product, int quantity)? onProductAdded;

  const ProductCard({
    super.key,
    required this.product,
    required this.outletId,
    this.onProductAdded,
  });

  void _openDetailSheet(BuildContext context) {
    if (product.isSoldOut) {
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(product: product, outletId: outletId),
    ).then((result) {
      if (result is Map && result['success'] == true) {
        final quantity = result['quantity'] as int? ?? 1;
        onProductAdded?.call(product, quantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: product.isSoldOut ? null : () => _openDetailSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Opacity(
                  opacity: product.isSoldOut ? 0.5 : 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 96,
                      height: 96,
                      padding: const EdgeInsets.all(10),
                      color: AppColors.xftAccent,
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) {
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              LucideIcons.image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (product.badge != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: ProductBadgeWidget(
                      badge: product.badge!,
                      showLabel: false,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: product.isSoldOut ? 0.5 : 1.0,
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        color: AppColors.xftSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Opacity(
                    opacity: product.isSoldOut ? 0.5 : 1.0,
                    child: Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.xftSurface.withValues(
                          alpha: product.isSoldOut ? 0.5 : 1.0,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.hasVariants
                            ? Product.formatPrice(product.minPrice)
                            : product.price,
                        style: TextStyle(
                          color: AppColors.xftSurface.withValues(
                            alpha: product.isSoldOut ? 0.5 : 1.0,
                          ),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.isSoldOut) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'Sold Out',
                          style: TextStyle(
                            color: AppColors.xftPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (!product.isSoldOut)
              Material(
                color: AppColors.xftSurface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openDetailSheet(context),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      LucideIcons.plus,
                      color: AppColors.xftAccent,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}