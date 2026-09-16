import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/promo/domain/models/promo_model.dart';
import 'package:xft/features/promo/presentation/promo_notifier.dart';

// ── Tab ───────────────────────────────────────────────────────────────────────

class PromosTab extends ConsumerWidget {
  const PromosTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(promoListProvider);

    return Scaffold(
      backgroundColor: AppColors.xftBackground,
      body: promosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gagal memuat promo'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(promoListProvider.notifier).refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (promos) {
          if (promos.isEmpty) {
            return const Center(child: Text('Belum ada promo saat ini.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(promoListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: promos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) => _PromoCard(promo: promos[index]),
            ),
          );
        },
      ),
    );
  }
}

// ── Promo card ────────────────────────────────────────────────────────────────

class _PromoCard extends StatelessWidget {
  final PromoData promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/promo-detail', extra: promo.id),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              promo.imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            promo.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            promo.postDate,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.surface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            promo.summary,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.surface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}