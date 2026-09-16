import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/features/notification/domain/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(dioProvider));
});

class NotificationFetchResult {
  final List<NotificationItem> items;
  final int unreadCount;
  NotificationFetchResult(this.items, this.unreadCount);
}

class NotificationService {
  final Dio _dio;
  NotificationService(this._dio);

  Future<NotificationFetchResult> fetchNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      final data = response.data['data'];
      final items = (data['notifications'] as List)
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return NotificationFetchResult(items, data['unread_count'] as int);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal memuat notifikasi';
      throw Exception(message);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal menandai notifikasi';
      throw Exception(message);
    }
  }
}