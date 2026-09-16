import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/presentation/widgets/filter_chip_row.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/notification/domain/models/notification_model.dart';
import 'package:xft/features/notification/presentation/notification_notifier.dart';
import 'package:xft/features/notification/presentation/widgets/notification_detail_sheet.dart';

export 'package:xft/features/notification/presentation/notification_notifier.dart'
    show notificationListProvider, unreadNotificationCountProvider;

// ── Constants ─────────────────────────────────────────────────────────────────

const _kCategories = ['Semua Notifikasi', 'Pesanan', 'Promo'];

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 60) return '${diff.inMinutes} mnt yang lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
  if (diff.inDays == 1) return 'Kemarin';

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

// ── Page ──────────────────────────────────────────────────────────────────────

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  String _selectedCategory = _kCategories.first;

  @override
  void initState() {
    super.initState();
    // Refresh langsung begitu halaman dibuka, jangan cuma andalkan cache
    // provider yang mungkin sudah agak basi (di-fetch dari sesi sebelumnya).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListProvider.notifier).refresh();
    });
  }

  void _openDetail(NotificationItem item) {
    ref.read(notificationListProvider.notifier).markAsRead(item.id);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => NotificationDetailSheet(
        item: item,
        formatDate: _formatDate,
      ),
    );
  }

  List<NotificationItem> _filter(List<NotificationItem> all) {
    if (_selectedCategory == 'Pesanan') {
      return all.where((n) => n.category == 'Pesanan').toList();
    }
    if (_selectedCategory == 'Promo') {
      return all.where((n) => n.category == 'Promo').toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: () =>
                    ref.read(notificationListProvider.notifier).markAllAsRead(),
                child: const Text(
                  'Tandai semua dibaca',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilterChipRow(
            categories: _kCategories,
            selected: _selectedCategory,
            onSelected: (v) => setState(() => _selectedCategory = v),
          ),
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Gagal memuat notifikasi'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.read(notificationListProvider.notifier).refresh(),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
              data: (notifications) {
                final filtered = _filter(notifications);
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationListProvider.notifier).refresh(),
                  child: filtered.isEmpty
                      ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      _EmptyState(),
                    ],
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.black12,
                    ),
                    itemBuilder: (context, index) => _NotificationTile(
                      item: filtered[index],
                      formatDate: _formatDate,
                      onTap: () => _openDetail(filtered[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.item,
    required this.formatDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            if (item.isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6, right: 12),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: item.isUnread
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.category} • ${formatDate(item.date)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: item.isUnread
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
