import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/home/domain/models/order_model.dart';
import 'package:xft/features/home/presentation/widgets/order_accordion_card.dart';
import 'package:xft/features/order/history/presentation/order_history_notifier.dart';

class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);

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
        title: Text(
          orderId,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString().replaceFirst('Exception: ', '')),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(orderHistoryProvider.notifier).refresh(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (orders) {
          final order = orders.where((o) => o.orderId == orderId).firstOrNull;
          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.circle_alert, size: 40, color: Colors.black38),
                  const SizedBox(height: 12),
                  const Text('Pesanan tidak ditemukan', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: OrderAccordionCard(order: order),
          );
        },
      ),
    );
  }
}
