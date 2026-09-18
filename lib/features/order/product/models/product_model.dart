enum ProductBadge {
  signature,
  favorite;

  static ProductBadge? fromString(String? value) {
    if (value == 'signature') return ProductBadge.signature;
    if (value == 'favorite') return ProductBadge.favorite;
    return null;
  }
}

int _parseIntSafe(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return double.tryParse(value)?.round() ?? 0;
  return 0;
}

class ProductVariant {
  final int id;
  final String name;
  final int price;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: _parseIntSafe(json['id']),
      name: json['name'] as String? ?? '',
      price: _parseIntSafe(json['price']),
    );
  }
}

class ModifierOption {
  final int id;
  final String name;
  final int additionalPrice;

  const ModifierOption({
    required this.id,
    required this.name,
    this.additionalPrice = 0,
  });

  factory ModifierOption.fromJson(Map<String, dynamic> json) {
    return ModifierOption(
      id: _parseIntSafe(json['id']),
      name: json['name'] as String? ?? '',
      additionalPrice: _parseIntSafe(json['additional_price']),
    );
  }
}

class ModifierGroup {
  final int id;
  final String name;
  final bool isRequired;
  final int minSelect;
  final int maxSelect;
  final List<ModifierOption> options;

  const ModifierGroup({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.minSelect = 0,
    this.maxSelect = 1,
    this.options = const [],
  });

  bool get isSingleSelect => maxSelect == 1;

  factory ModifierGroup.fromJson(Map<String, dynamic> json) {
    return ModifierGroup(
      id: _parseIntSafe(json['id']),
      name: json['name'] as String? ?? '',
      isRequired: json['is_required'] == true,
      minSelect: _parseIntSafe(json['min_select']),
      maxSelect: _parseIntSafe(json['max_select']),
      options: (json['options'] as List?)
              ?.map((o) => ModifierOption.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final String imageUrl;
  final int? quantity;
  final bool isSoldOut;
  final ProductBadge? badge;
  final List<ProductVariant> variants;
  final List<ModifierGroup> modifierGroups;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.quantity,
    this.isSoldOut = false,
    this.badge,
    this.variants = const [],
    this.modifierGroups = const [],
  });

  Product copyWith({
    int? id,
    String? name,
    String? description,
    String? price,
    String? imageUrl,
    int? quantity,
    bool? isSoldOut,
    ProductBadge? badge,
    List<ProductVariant>? variants,
    List<ModifierGroup>? modifierGroups,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      badge: badge ?? this.badge,
      variants: variants ?? this.variants,
      modifierGroups: modifierGroups ?? this.modifierGroups,
    );
  }

  bool get hasVariants => variants.isNotEmpty;
  bool get hasModifiers => modifierGroups.isNotEmpty;

  int get minPrice {
    if (variants.isEmpty) {
      return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
  }

  int get maxPrice {
    if (variants.isEmpty) {
      return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final isFavorite = json['is_favorite'] == true;
    final variantsList = (json['variants'] as List?)
            ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    final modifierGroupsList = (json['modifier_groups'] as List?)
            ?.map((m) => ModifierGroup.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return Product(
      id: _parseIntSafe(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: formatPrice(_parseIntSafe(json['price'])),
      imageUrl: json['image_url'] as String? ?? '',
      badge: isFavorite ? ProductBadge.favorite : null,
      variants: variantsList,
      modifierGroups: modifierGroupsList,
    );
  }

  static String formatPrice(int price) {
    final s = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }
}

class Category {
  final int? id;
  final String name;
  final List<Product> products;

  const Category({this.id, required this.name, required this.products});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id'] != null ? _parseIntSafe(json['category_id']) : null,
      name: json['category_name'] as String? ?? '',
      products: (json['items'] as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}