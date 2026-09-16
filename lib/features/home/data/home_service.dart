import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/features/home/domain/models/banner_model.dart';
import 'package:xft/features/home/domain/models/recommended_product_model.dart';

final homeServiceProvider = Provider<HomeService>((ref) {
  return HomeService(ref.watch(dioProvider));
});

class HomeService {
  final Dio _dio;
  HomeService(this._dio);

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _dio.get('/home-highlights');
      final banners = response.data['data']['promo_banners'] as List;
      return banners
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat banner');
    }
  }

  Future<List<RecommendedProduct>> fetchRecommendations() async {
    try {
      final response = await _dio.get('/home-highlights');
      final list = response.data['data']['recommendations'] as List;
      return list
          .map((e) => RecommendedProduct.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat produk rekomendasi');
    }
  }
}