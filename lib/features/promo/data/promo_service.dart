import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/features/promo/domain/models/promo_model.dart';

final promoServiceProvider = Provider<PromoService>((ref) {
  return PromoService(ref.watch(dioProvider));
});

class PromoService {
  final Dio _dio;
  PromoService(this._dio);

  Future<List<PromoData>> fetchPromos() async {
    try {
      final response = await _dio.get('/promos');
      final list = response.data['data'] as List;
      return list.map((e) => PromoData.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat promo');
    }
  }

  Future<PromoData> fetchPromoDetail(int id) async {
    try {
      final response = await _dio.get('/promos/$id');
      return PromoData.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat detail promo');
    }
  }
}