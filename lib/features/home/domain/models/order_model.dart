int _parseIntSafe(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return double.tryParse(value)?.round() ?? 0;
  return 0;
}

int? _parseIntSafeNullable(dynamic value) {
  if (value == null) return null;
  return _parseIntSafe(value);
}

/// Status of an order in the Xing Fu Tang pipeline.
///
/// [completed] is the terminal *success* state -- distinct from
/// [readyForPickup], which is still awaiting pickup and should show the
/// "Pickup Pesanan" action. [canceled] and [rejected] are terminal,
/// non-success states — the UI should show a distinct label for them
/// instead of the 3-step progress stepper used for
/// [waiting] / [preparing] / [readyForPickup] / [completed].
enum OrderStatus { waiting, preparing, readyForPickup, completed, canceled, rejected }

/// Maps the backend's `orders.status` enum
/// (`pending|processing|ready|completed|canceled|rejected`) to [OrderStatus].
OrderStatus orderStatusFromBackend(String? value) {
  switch (value) {
    case 'pending':
      return OrderStatus.waiting;
    case 'processing':
      return OrderStatus.preparing;
    case 'ready':
      return OrderStatus.readyForPickup;
    case 'completed':
      return OrderStatus.completed;
    case 'canceled':
      return OrderStatus.canceled;
    case 'rejected':
      return OrderStatus.rejected;
    default:
      return OrderStatus.waiting;
  }
}

/// A single add-on option selected for an [OrderItem].
class OrderItemAddOn {
  final String name;
  const OrderItemAddOn(this.name);

  factory OrderItemAddOn.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return OrderItemAddOn((json['name'] ?? '').toString());
    }
    return OrderItemAddOn(json?.toString() ?? '');
  }
}

/// A single product line within an [Order].
class OrderItem {
  final String imageUrl;
  final String productName;
  final int quantity;
  final String size;
  final String ice;
  final String sugar;
  final List<OrderItemAddOn> addOns;
  final int price;
  final String? variantName;
  final Map<String, dynamic>? selectedModifiers;

  const OrderItem({
    required this.imageUrl,
    required this.productName,
    required this.quantity,
    required this.size,
    required this.ice,
    required this.sugar,
    this.addOns = const [],
    required this.price,
    this.variantName,
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

  static String _fallback(dynamic value, [String fallback = '-']) {
    final s = value?.toString().trim();
    return (s == null || s.isEmpty) ? fallback : s;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final mods = json['selected_modifiers'] != null
        ? Map<String, dynamic>.from(json['selected_modifiers'] as Map)
        : null;
    return OrderItem(
      imageUrl: (json['image_url'] as String?) ?? '',
      productName: _fallback(json['product_name'], 'Produk'),
      quantity: _parseIntSafe(json['quantity']) == 0 ? 1 : _parseIntSafe(json['quantity']),
      size: _fallback(json['size']),
      ice: _fallback(json['ice']),
      sugar: _fallback(json['sugar']),
      addOns: (json['add_ons'] as List<dynamic>? ?? const [])
          .map((e) => OrderItemAddOn.fromJson(e))
          .where((a) => a.name.isNotEmpty)
          .toList(),
      price: _parseIntSafe(json['price']),
      variantName: json['variant_name'] as String?,
      selectedModifiers: mods,
    );
  }
}

/// A complete customer order.
class Order {
  final String orderId;
  final DateTime orderDate;
  final List<OrderItem> items;
  final int subTotal;
  final int? promoDiscount;
  final String? promoLabel;
  final int totalPayment;
  final String paymentMethod;
  final String pickupLocationName;
  final String pickupLocationAddress;
  final OrderStatus status;
  final bool isActive;

  const Order({
    required this.orderId,
    required this.orderDate,
    required this.items,
    required this.subTotal,
    this.promoDiscount,
    this.promoLabel,
    required this.totalPayment,
    required this.paymentMethod,
    required this.pickupLocationName,
    required this.pickupLocationAddress,
    required this.status,
    required this.isActive,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: (json['order_id'] as String?) ?? '-',
      orderDate:
          DateTime.tryParse(json['order_date'] as String? ?? '') ??
              DateTime.now(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subTotal: _parseIntSafe(json['sub_total']),
      promoDiscount: _parseIntSafeNullable(json['promo_discount']),
      promoLabel: json['promo_label'] as String?,
      totalPayment: _parseIntSafe(json['total_payment']),
      paymentMethod: (json['payment_method'] as String?) ?? '-',
      pickupLocationName: (json['pickup_location_name'] as String?) ?? '-',
      pickupLocationAddress:
          (json['pickup_location_address'] as String?) ?? '-',
      status: orderStatusFromBackend(json['status'] as String?),
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
