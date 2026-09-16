import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/home/domain/models/recommended_product_model.dart';
import 'package:xft/features/home/presentation/recommendation_notifier.dart';
import 'package:xft/features/home/presentation/widgets/product_badge_widget.dart';
import 'package:xft/features/home/presentation/widgets/cta_card_product.dart';

class ProductCtaPanel extends ConsumerWidget {
  const ProductCtaPanel({super.key});

  void _showDetail(BuildContext context, RecommendedProduct product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => _ProductDetailSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendedProductListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Kamu harus coba',
              style: TextStyle(color: AppColors.surface, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.push('/list-outlet'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Lihat Semua', style: TextStyle(color: AppColors.surface, fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        recommendationsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Text('Gagal memuat produk rekomendasi'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.read(recommendedProductListProvider.notifier).refresh(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
          data: (products) {
            if (products.isEmpty) return const SizedBox.shrink();
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final product = products[i];
                return CtaCardProduct(
                  image: product.imageUrl ?? '',
                  category: product.category ?? '',
                  productName: product.name,
                  badge: product.totalSold > 0 ? ProductBadge.favorite : null,
                  onTap: () => _showDetail(context, product),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ── Product detail bottom sheet ────────────────────────────────────────────────

class _ProductDetailSheet extends StatelessWidget {
  final RecommendedProduct product;
  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 150,
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => const Icon(LucideIcons.image_off),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.totalSold > 0) ...[
                        const ProductBadgeWidget(badge: ProductBadge.favorite),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        product.name,
                        style: GoogleFonts.inter(color: AppColors.surface, fontSize: 26, fontWeight: FontWeight.bold, height: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.formattedPrice,
                        style: GoogleFonts.inter(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      if (product.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          product.description!,
                          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/list-outlet');
                },
                child: Text(
                  'Mau pesan? Lihat outlet terdekat',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}