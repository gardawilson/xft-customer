import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/features/home/domain/models/order_model.dart';

final orderHistoryServiceProvider = Provider<OrderHistoryService>((ref) {
  return OrderHistoryService(ref.watch(dioProvider));
});

class OrderHistoryService {
  final Dio _dio;
  OrderHistoryService(this._dio);

  /// Ambil seluruh pesanan milik customer yang sedang login (aktif + selesai).
  /// Filter tab "Aktif" / "Pesanan Selesai" dilakukan di sisi UI berdasarkan
  /// [Order.isActive] yang sudah dihitung backend.
  Future<List<Order>> fetchOrders() async {
    try {
      final response = await _dio.get('/orders');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal memuat daftar pesanan';
      throw Exception(message);
    }
  }

  /// Customer konfirmasi sudah mengambil pesanannya di outlet.
  /// Hanya boleh dipanggil kalau status order sedang 'ready'.
  Future<void> confirmPickup(String orderId) async {
    try {
      await _dio.post('/orders/$orderId/pickup');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal mengonfirmasi pengambilan pesanan';
      throw Exception(message);
    }
  }
}
