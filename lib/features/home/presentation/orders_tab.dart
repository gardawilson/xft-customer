import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/presentation/widgets/filter_chip_row.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';
import 'package:xft/features/home/domain/models/order_model.dart';
import 'package:xft/features/home/presentation/widgets/order_accordion_card.dart';
import 'package:xft/features/order/history/presentation/order_history_notifier.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kCategories = ['Aktif', 'Pesanan Selesai', 'Riwayat'];

// ── Tab ───────────────────────────────────────────────────────────────────────

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});

  @override
  ConsumerState<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<OrdersTab> {
  String _selectedCategory = _kCategories.first;

  // "Pesanan Selesai" dan "Riwayat" menampilkan data yang sama (semua
  // pesanan tidak aktif: selesai/batal/ditolak) -- bedanya cuma cara
  // tampilnya: "Riwayat" dikelompokkan per lokasi outlet.
  List<Order> _filterOrders(List<Order> orders) => orders
      .where((o) => _selectedCategory == 'Aktif' ? o.isActive : !o.isActive)
      .toList();

  /// Kelompokkan pesanan berdasarkan nama outlet, urutan grup mengikuti
  /// kemunculan pertama tiap outlet di list (list dari backend sudah terurut
  /// dari yang terbaru), jadi outlet dengan transaksi terbaru muncul duluan.
  Map<String, List<Order>> _groupByOutlet(List<Order> orders) {
    final grouped = <String, List<Order>>{};
    for (final order in orders) {
      grouped.putIfAbsent(order.pickupLocationName, () => []).add(order);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.asData?.value?.data;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.xftBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Ups, kamu belum login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Yuk login dulu biar bisa melihat daftar pesananmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login Sekarang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.xftBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterChipRow(
              categories: _kCategories,
              selected: _selectedCategory,
              onSelected: (v) => setState(() => _selectedCategory = v),
            ),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final ordersAsync = ref.watch(orderHistoryProvider);

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(error),
      data: (orders) {
        final filtered = _filterOrders(orders);

        if (filtered.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref.read(orderHistoryProvider.notifier).refresh(),
            child: ListView(
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text(
                    'Tidak ada pesanan',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ],
            ),
          );
        }

        if (_selectedCategory == 'Riwayat') {
          return _buildGroupedList(filtered);
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(orderHistoryProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                OrderAccordionCard(order: filtered[index]),
          ),
        );
      },
    );
  }

  /// Tampilan tab "Riwayat": semua pesanan (berhasil maupun gagal/batal)
  /// dikelompokkan per lokasi outlet, dengan judul nama outlet di tiap grup.
  Widget _buildGroupedList(List<Order> orders) {
    final grouped = _groupByOutlet(orders);

    return RefreshIndicator(
      onRefresh: () => ref.read(orderHistoryProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: grouped.entries.expand((entry) {
          final outletName = entry.key;
          final outletOrders = entry.value;

          return [
            Padding(
              padding: const EdgeInsets.only(bottom: 10, top: 4),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    outletName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Divider(color: Colors.black.withValues(alpha: 0.1))),
                ],
              ),
            ),
            ...outletOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OrderAccordionCard(order: order),
              ),
            ),
            const SizedBox(height: 8),
          ];
        }).toList(),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return RefreshIndicator(
      onRefresh: () => ref.read(orderHistoryProvider.notifier).refresh(),
      child: ListView(
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: Colors.black26,
          ),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat daftar pesanan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => ref.read(orderHistoryProvider.notifier).refresh(),
              child: const Text('Coba Lagi'),
            ),
          ),
        ],
      ),
    );
  }
}
