import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../storage/storage_service.dart';
import 'auth_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // Baca dari saklar di core/config/app_config.dart -- ganti
      // kUseProduction di situ, bukan baris ini.
      baseUrl: kApiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  final secureStorage = SecureStorageService();

  dio.interceptors.addAll([
    AuthInterceptor(secureStorage),
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ),
  ]);

  return dio;
});

/// Base URL API (termasuk prefix /api), dipakai untuk endpoint yang perlu
/// dibuka langsung di WebView (mis. syarat & ketentuan, kebijakan privasi)
/// alih-alih dipanggil lewat Dio. Selalu sinkron dengan [dioProvider] --
/// kalau baseUrl diganti, ini otomatis ikut berubah juga.
final apiBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(dioProvider).options.baseUrl;
});