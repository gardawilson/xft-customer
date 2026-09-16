import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/home/data/home_service.dart';
import 'package:xft/features/home/domain/models/recommended_product_model.dart';

class RecommendedProductListNotifier extends AsyncNotifier<List<RecommendedProduct>> {
  @override
  Future<List<RecommendedProduct>> build() {
    return ref.read(homeServiceProvider).fetchRecommendations();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final recommendedProductListProvider =
AsyncNotifierProvider<RecommendedProductListNotifier, List<RecommendedProduct>>(
  RecommendedProductListNotifier.new,
);