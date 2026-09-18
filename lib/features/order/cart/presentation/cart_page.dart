import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'cart_notifier.dart';
import '../domain/models/cart_item_model.dart';
import 'package:xft/features/order/payment/data/order_service.dart';
// Espay VA disembunyikan sementara -- pembayaran online masih ditutup
// sampai integrasi Espay selesai. Import dibiarkan di-comment biar gampang
// diaktifkan lagi nanti (bukan dihapus).
// import 'package:xft/features/order/payment/presentation/espay_va_page.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _isCheckingOut = false;

  String _formatPrice(int price) {
    final s = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }

  Future<void> _handleCheckout(int outletId) async {
    setState(() => _isCheckingOut = true);
    try {
      // Pembayaran online (Espay) masih ditutup sementara -- checkout
      // langsung pakai "Bayar di Toko". Ganti balik ke default (espay)
      // begitu integrasi online payment sudah siap dipakai lagi.
      final result = await ref.read(orderServiceProvider).checkout(
        outletId,
        paymentMethod: 'pay_at_store',
      );
      if (!mounted) return;

      await ref.read(cartProvider.notifier).refresh();

      context.push(
        '/payment-result?status=pay_at_store&order_number=${result.orderNumber}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.xftBackground,
      appBar: AppBar(
        backgroundColor: AppColors.xftBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Keranjang',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString().replaceFirst('Exception: ', '')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(cartProvider.notifier).refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (cart) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Text('Keranjang kamu masih kosong', style: TextStyle(color: Colors.black54)),
            );
          }

          final outletId = cart.items.first.outletId;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const Divider(height: 24, color: Colors.black12),
                  itemBuilder: (context, index) => _CartItemTile(
                    item: cart.items[index],
                    formatPrice: _formatPrice,
                    onDelete: () => ref.read(cartProvider.notifier).removeItem(cart.items[index].id),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.xftSurface)),
                          Text(
                            _formatPrice(cart.totalPrice),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.xftSurface),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          Icon(LucideIcons.store, size: 14, color: Colors.black45),
                          SizedBox(width: 6),
                          Text('Dibayar tunai/QRIS langsung di kasir outlet', style: TextStyle(fontSize: 12, color: Colors.black45)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isCheckingOut ? null : () => _handleCheckout(outletId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.xftSurface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isCheckingOut
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text(
                          'Buat Pesanan',
                          style: TextStyle(color: AppColors.xftAccent, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final String Function(int) formatPrice;
  final VoidCallback onDelete;

  const _CartItemTile({required this.item, required this.formatPrice, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            color: AppColors.xftAccent,
            padding: const EdgeInsets.all(8),
            child: Image.network(
              item.imageUrl ?? '',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.image, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.xftSurface)),
              if (item.modifierSummary != null) ...[
                const SizedBox(height: 2),
                Text(item.modifierSummary!, style: const TextStyle(fontSize: 12, color: Colors.black45)),
              ],
              const SizedBox(height: 4),
              Text('${item.quantity} x ${formatPrice(item.price)}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 6),
              Text(formatPrice(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.xftSurface)),
            ],
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(LucideIcons.trash, size: 20, color: AppColors.xftPrimary),
        ),
      ],
    );
  }
}