import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';

class ContactLink {
  final String label;
  final String value;
  final String url;

  ContactLink({required this.label, required this.value, required this.url});

  factory ContactLink.fromJson(Map<String, dynamic> json) => ContactLink(
    label: json['label'] as String? ?? '',
    value: json['value'] as String? ?? '',
    url: json['url'] as String? ?? '',
  );
}

class ContactInfo {
  final ContactLink? whatsapp;
  final ContactLink? instagram;

  ContactInfo({this.whatsapp, this.instagram});
}

final contactUsServiceProvider = Provider<ContactUsService>((ref) {
  return ContactUsService(ref.watch(dioProvider));
});

class ContactUsService {
  final Dio _dio;
  ContactUsService(this._dio);

  Future<ContactInfo> getContactUs() async {
    try {
      final response = await _dio.get('/contact-us');
      final data = response.data['data'] as Map<String, dynamic>;
      return ContactInfo(
        whatsapp: data['whatsapp'] != null
            ? ContactLink.fromJson(data['whatsapp'] as Map<String, dynamic>)
            : null,
        instagram: data['instagram'] != null
            ? ContactLink.fromJson(data['instagram'] as Map<String, dynamic>)
            : null,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal memuat data kontak',
      );
    } catch (e) {
      throw Exception('Gagal terhubung ke server');
    }
  }
}

/// autoDispose supaya data di-fetch ulang tiap kali halaman Hubungi Kami
/// dibuka (data kontak jarang berubah, tapi ini mencegah data basi
/// nyangkut lama di memori kalau admin update nomor WA/IG dari backend).
final contactUsProvider = FutureProvider.autoDispose<ContactInfo>((ref) async {
  final service = ref.watch(contactUsServiceProvider);
  return service.getContactUs();
});
