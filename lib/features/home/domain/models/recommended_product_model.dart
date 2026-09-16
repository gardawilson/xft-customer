int _parseIntSafe(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return double.tryParse(value)?.round() ?? 0;
  return 0;
}

class RecommendedProduct {
  final int id;
  final String name;
  final String? category;
  final String? description;
  final String? imageUrl;
  final int basePrice;
  final int totalSold;

  const RecommendedProduct({
    required this.id,
    required this.name,
    this.category,
    this.description,
    this.imageUrl,
    required this.basePrice,
    required this.totalSold,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: _parseIntSafe(json['id']),
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      // base_price (kolom decimal) dan total_sold (hasil SUM() agregat)
      // sama-sama sering dibalikin Laravel sebagai teks, bukan angka native
      // -- di-parse pakai fungsi yang terima format apapun dengan aman.
      basePrice: _parseIntSafe(json['base_price']),
      totalSold: _parseIntSafe(json['total_sold']),
    );
  }

  String get formattedPrice {
    final s = basePrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return 'Rp $buffer';
  }
}