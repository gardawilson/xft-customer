import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/home/data/home_service.dart';
import 'package:xft/features/home/domain/models/banner_model.dart';

class BannerListNotifier extends AsyncNotifier<List<BannerModel>> {
  @override
  Future<List<BannerModel>> build() async {
    return ref.read(homeServiceProvider).fetchBanners();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final bannerListProvider =
AsyncNotifierProvider<BannerListNotifier, List<BannerModel>>(
  BannerListNotifier.new,
);