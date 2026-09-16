import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/home/domain/models/order_model.dart';
import 'package:xft/features/order/history/data/order_history_service.dart';

// ── Notifier ──────────────────────────────────────────────────────────────────

class OrderHistoryNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    return ref.read(orderHistoryServiceProvider).fetchOrders();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Refresh di background (dipakai oleh polling otomatis) tanpa memicu
  /// state loading -- supaya list yang sedang tampil tidak berkedip tiap
  /// beberapa detik. Kalau gagal (misal koneksi putus sesaat), diamkan saja
  /// dan biarkan data lama tetap tampil sampai polling berikutnya berhasil.
  Future<void> silentRefresh() async {
    try {
      final orders = await ref.read(orderHistoryServiceProvider).fetchOrders();
      state = AsyncData(orders);
    } catch (_) {
      // sengaja diabaikan
    }
  }

  /// Customer konfirmasi sudah mengambil pesanan di outlet, lalu refresh
  /// list supaya pesanan itu pindah ke tab "Pesanan Selesai".
  Future<void> confirmPickup(String orderId) async {
    await ref.read(orderHistoryServiceProvider).confirmPickup(orderId);
    await refresh();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final orderHistoryProvider =
    AsyncNotifierProvider<OrderHistoryNotifier, List<Order>>(
  OrderHistoryNotifier.new,
);
