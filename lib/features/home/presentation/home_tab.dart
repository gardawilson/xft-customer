import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';
import 'package:xft/features/home/presentation/widgets/promotional_carousel.dart';
import 'package:xft/features/home/presentation/widgets/email_verification_card.dart';
import 'package:xft/features/home/presentation/widgets/pickup_button_card.dart';
import 'package:xft/features/home/presentation/widgets/product_cta_panel.dart';

/// The main "Beranda" (home) tab — shows the promotional carousel and CTAs.
///
/// Note: This widget does NOT wrap itself in a [Scaffold] because it is
/// already rendered inside [HomePage]'s [Scaffold].
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tombol "Verifikasi Email" hanya perlu tampil kalau customer BELUM
    // verifikasi emailnya. Kalau sudah, atau data user belum termuat,
    // jangan tampilkan sama sekali.
    final isEmailVerified =
        ref.watch(authProvider).value?.data?.user.isEmailVerified ?? true;

    return Container(
      color: AppColors.xftBackground,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PromotionalCarousel(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                children: [
                  if (!isEmailVerified) ...[
                    const EmailVerificationCard(),
                    const SizedBox(height: 16),
                  ],
                  const PickupButtonCard(),
                  const SizedBox(height: 16),
                  const ProductCtaPanel(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
