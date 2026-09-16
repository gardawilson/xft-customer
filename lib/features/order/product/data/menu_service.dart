import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/features/order/product/models/product_model.dart';

final menuServiceProvider = Provider<MenuService>((ref) {
  return MenuService(ref.watch(dioProvider));
});

class MenuService {
  final Dio _dio;
  MenuService(this._dio);

  Future<List<Category>> fetchMenusByOutlet(int outletId) async {
    try {
      final response = await _dio.get('/outlet/menus', queryParameters: {
        'outlet_id': outletId,
      });
      final list = response.data['data'] as List;
      return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat menu outlet');
    }
  }
}