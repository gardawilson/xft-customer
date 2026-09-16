import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/features/order/cart/data/cart_service.dart';
import 'package:xft/features/order/cart/domain/models/cart_item_model.dart';

class CartNotifier extends AsyncNotifier<CartData> {
  @override
  Future<CartData> build() {
    return ref.read(cartServiceProvider).fetchCart();
  }

  Future<void> addItem({
    required int outletId,
    required int productId,
    required int quantity,
    int? variantId,
    String? notes,
    Map<String, dynamic>? selectedModifiers,
  }) async {
    await ref.read(cartServiceProvider).addToCart(
      outletId: outletId,
      productId: productId,
      quantity: quantity,
      variantId: variantId,
      notes: notes,
      selectedModifiers: selectedModifiers,
    );
    await refresh();
  }

  Future<void> removeItem(int cartItemId) async {
    await ref.read(cartServiceProvider).deleteCartItem(cartItemId);
    await refresh();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartData>(CartNotifier.new);