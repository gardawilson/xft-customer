int _parseIntSafe(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return double.tryParse(value)?.round() ?? 0;
  return 0;
}

class CartItem {
  final int id;
  final int outletId;
  final int productId;
  final int? variantId;
  final String productName;
  final String? variantName;
  final String? imageUrl;
  final int price;
  final int quantity;
  final String? notes;
  final int subtotal;
  final Map<String, dynamic>? selectedModifiers;

  const CartItem({
    required this.id,
    required this.outletId,
    required this.productId,
    this.variantId,
    required this.productName,
    this.variantName,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.notes,
    required this.subtotal,
    this.selectedModifiers,
  });

  String get displayName {
    if (variantName != null && variantName!.isNotEmpty) {
      return '$productName ($variantName)';
    }
    return productName;
  }

  String? get modifierSummary {
    if (selectedModifiers == null || selectedModifiers!.isEmpty) return null;
    final parts = <String>[];
    for (final entry in selectedModifiers!.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        parts.add(value.join(', '));
      } else if (value is String && value.isNotEmpty) {
        parts.add(value);
      }
    }
    return parts.isEmpty ? null : parts.join(' • ');
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _parseIntSafe(json['id']),
      outletId: _parseIntSafe(json['outlet_id']),
      productId: _parseIntSafe(json['product_id']),
      variantId: json['variant_id'] != null ? _parseIntSafe(json['variant_id']) : null,
      productName: json['product_name'] as String? ?? '',
      variantName: json['variant_name'] as String?,
      imageUrl: json['image_url'] as String?,
      price: _parseIntSafe(json['price']),
      quantity: _parseIntSafe(json['quantity']),
      notes: json['notes'] as String?,
      subtotal: _parseIntSafe(json['subtotal']),
      selectedModifiers: json['selected_modifiers'] != null
          ? Map<String, dynamic>.from(json['selected_modifiers'] as Map)
          : null,
    );
  }
}

class CartData {
  final List<CartItem> items;
  final int totalPrice;
  final int totalItems;

  const CartData({
    required this.items,
    required this.totalPrice,
    required this.totalItems,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List;
    return CartData(
      items: list.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
      totalPrice: _parseIntSafe(json['total_price']),
      totalItems: _parseIntSafe(json['total_items']),
    );
  }

  static const empty = CartData(items: [], totalPrice: 0, totalItems: 0);
}
