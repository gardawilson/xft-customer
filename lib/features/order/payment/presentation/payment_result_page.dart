import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';

class PaymentResultPage extends StatelessWidget {
  final String status;
  final String orderNumber;

  const PaymentResultPage({
    super.key,
    required this.status,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'processing' || status == 'completed';

    return Scaffold(
      backgroundColor: AppColors.xftBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  color: isSuccess ? Colors.green : AppColors.xftPrimary,
                  size: 72,
                ),
                const SizedBox(height: 20),
                Text(
                  isSuccess ? 'Pembayaran Berhasil!' : 'Pembayaran Belum Selesai',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.xftSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'No. Pesanan: $orderNumber',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.xftSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Kembali ke Beranda',
                      style: TextStyle(color: AppColors.xftAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}