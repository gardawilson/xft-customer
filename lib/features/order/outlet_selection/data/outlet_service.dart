import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/features/order/outlet_selection/models/outlet_model.dart';

final outletServiceProvider = Provider<OutletService>((ref) {
  return OutletService(ref.watch(dioProvider));
});

class OutletService {
  final Dio _dio;
  OutletService(this._dio);

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi (GPS) tidak aktif. Aktifkan GPS terlebih dahulu.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak. Aktifkan izin lokasi untuk melihat outlet terdekat.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<OutletListResult> fetchNearestOutlets() async {
    final position = await _determinePosition();

    try {
      final response = await _dio.get('/outlets/nearest', queryParameters: {
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
      final data = response.data['data'];

      final closest = data['closest_outlet'] != null
          ? OutletModel.fromJson(data['closest_outlet'] as Map<String, dynamic>)
          : null;
      final others = (data['other_outlets'] as List)
          .map((e) => OutletModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return OutletListResult(closest: closest, others: others);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal memuat outlet terdekat');
    }
  }
}