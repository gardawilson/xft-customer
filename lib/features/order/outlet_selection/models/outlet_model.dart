class OutletModel {
  final int id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
  final String distance;
  final String status;

  const OutletModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    required this.distance,
    required this.status,
  });

  factory OutletModel.fromJson(Map<String, dynamic> json) {
    return OutletModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      distance: json['distance_formatted'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class OutletListResult {
  final OutletModel? closest;
  final List<OutletModel> others;

  const OutletListResult({required this.closest, required this.others});
}