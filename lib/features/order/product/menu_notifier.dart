import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/order/product/data/menu_service.dart';
import 'package:xft/features/order/product/models/product_model.dart';

class MenuListNotifier extends AsyncNotifier<List<Category>> {
  MenuListNotifier(this.outletId);
  final int outletId;

  @override
  Future<List<Category>> build() {
    return ref.read(menuServiceProvider).fetchMenusByOutlet(outletId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final menuListProvider =
AsyncNotifierProvider.autoDispose.family<MenuListNotifier, List<Category>, int>(
  MenuListNotifier.new,
);