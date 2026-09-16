import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/notification/data/notification_service.dart';
import 'package:xft/features/notification/domain/models/notification_model.dart';

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationListNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() async {
    final result = await ref.read(notificationServiceProvider).fetchNotifications();
    return result.items;
  }

  Future<void> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update biar UI langsung responsif
    state = AsyncData([
      for (final item in current)
        if (item.id == id) item.copyWith(isUnread: false) else item,
    ]);

    try {
      await ref.read(notificationServiceProvider).markAsRead(id);
    } catch (_) {
      ref.invalidateSelf(); // rollback dengan refetch kalau API gagal
    }
  }

  Future<void> markAllAsRead() async {
    final current = state.value ?? [];
    final unreadIds = current.where((n) => n.isUnread).map((n) => n.id).toList();
    for (final id in unreadIds) {
      await markAsRead(id);
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Refresh di background (dipakai oleh polling otomatis) tanpa memicu
  /// state loading -- supaya badge lonceng & list tidak berkedip tiap kali
  /// di-cek ulang. Kalau gagal, diamkan saja dan biarkan data lama tetap
  /// tampil sampai polling berikutnya berhasil.
  Future<void> silentRefresh() async {
    try {
      final result = await ref.read(notificationServiceProvider).fetchNotifications();
      state = AsyncData(result.items);
    } catch (_) {
      // sengaja diabaikan
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final notificationListProvider =
AsyncNotifierProvider<NotificationListNotifier, List<NotificationItem>>(
  NotificationListNotifier.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).value ?? [];
  return notifications.where((n) => n.isUnread).length;
});