import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/promo/data/promo_service.dart';
import 'package:xft/features/promo/domain/models/promo_model.dart';

class PromoListNotifier extends AsyncNotifier<List<PromoData>> {
  @override
  Future<List<PromoData>> build() {
    return ref.read(promoServiceProvider).fetchPromos();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final promoListProvider =
AsyncNotifierProvider<PromoListNotifier, List<PromoData>>(PromoListNotifier.new);

/// Fetches full detail (including `content`) for a single promo by id.
final promoDetailProvider =
FutureProvider.autoDispose.family<PromoData, int>((ref, id) {
  return ref.watch(promoServiceProvider).fetchPromoDetail(id);
});