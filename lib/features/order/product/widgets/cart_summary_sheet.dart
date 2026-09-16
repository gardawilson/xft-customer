import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:xft/core/theme/app_colors.dart';
import '../models/product_model.dart';
import 'product_detail_sheet.dart';

class CartSummarySheet extends StatefulWidget {
  final List<Product> cartProducts;
  final int totalPrice;
  final int outletId;
  final String Function(int) formatPrice;
  final VoidCallback? onCartUpdated;

  const CartSummarySheet({
    super.key,
    required this.cartProducts,
    required this.totalPrice,
    required this.outletId,
    required this.formatPrice,
    this.onCartUpdated,
  });

  @override
  State<CartSummarySheet> createState() => _CartSummarySheetState();
}

class _CartSummarySheetState extends State<CartSummarySheet> {
  int _parsePrice(Product p) {
    return int.tryParse(p.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  int get _calculatedTotal {
    int total = 0;
    for (final p in widget.cartProducts) {
      total += _parsePrice(p) * (p.quantity ?? 0);
    }
    return total;
  }

  void _editProduct(Product product) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(
        product: product,
        outletId: widget.outletId,
        isEdit: true,
        initialQuantity: product.quantity ?? 1,
      ),
    ).then((updated) {
      if (updated == true) {
        widget.onCartUpdated?.call();
      }
    });
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Produk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus produk ini dari pesanan?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Hapus dari keranjang -- akan disambungkan saat implementasi state cart
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.xftPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGroup(Product p) {
    final qty = p.quantity ?? 0;
    final unitPrice = _parsePrice(p);
    final totalPrice = unitPrice * qty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
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
                p.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(LucideIcons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.xftSurface,
                  ),
                ),
                if (p.hasVariants) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ukuran: ${p.variants.firstWhere((v) => _parsePrice(p) == v.price, orElse: () => p.variants.first).name}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '$qty x ${widget.formatPrice(unitPrice)}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${widget.formatPrice(totalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.xftSurface,
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _editProduct(p),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(LucideIcons.pencil, size: 16, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _confirmDelete(p),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(LucideIcons.trash, size: 16, color: AppColors.xftPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, int amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.xftSurface : Colors.black87,
          ),
        ),
        Text(
          widget.formatPrice(amount),
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: AppColors.xftSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.xftSurface),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.cartProducts.map((p) => _buildProductGroup(p)),
                  const Divider(height: 32, color: Colors.black12),
                  _buildSummaryRow('Subtotal', _calculatedTotal),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total', _calculatedTotal, isTotal: true),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(LucideIcons.shield_check, size: 14, color: Colors.black45),
                      SizedBox(width: 6),
                      Text(
                        'Dibayar online lewat Virtual Account',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.xftSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Lanjutkan Pembayaran',
                  style: TextStyle(color: AppColors.xftAccent, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}