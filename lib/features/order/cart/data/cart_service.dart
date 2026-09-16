import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/features/order/cart/domain/models/cart_item_model.dart';

final cartServiceProvider = Provider<CartService>((ref) {
  return CartService(ref.watch(dioProvider));
});

class CartService {
  final Dio _dio;
  CartService(this._dio);

  Future<CartData> fetchCart() async {
    try {
      final response = await _dio.get('/cart');
      return CartData.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat keranjang');
    }
  }

  Future<void> addToCart({
    required int outletId,
    required int productId,
    required int quantity,
    int? variantId,
    String? notes,
    Map<String, dynamic>? selectedModifiers,
  }) async {
    try {
      await _dio.post('/cart/add', data: {
        'outlet_id': outletId,
        'product_id': productId,
        'variant_id': variantId,
        'quantity': quantity,
        'notes': notes,
        if (selectedModifiers != null) 'selected_modifiers': selectedModifiers,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal menambahkan ke keranjang');
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    try {
      await _dio.delete('/cart/$cartItemId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal menghapus item keranjang');
    }
  }
}