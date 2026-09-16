import 'package:dio/dio.dart';
import '../storage/storage_service.dart';

/// Menyisipkan Bearer token ke setiap request (kecuali yang ditandai
/// 'SkipAuth'), dan meneruskan error 401 apa adanya ke pemanggil.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (options.headers.containsKey('SkipAuth')) {
      options.headers.remove('SkipAuth');
      return handler.next(options);
    }

    try {
      final token = await _secureStorage.read('access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e, stack) {
      print('!!! ERROR BACA SECURE STORAGE: $e');
      print(stack);
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    return handler.next(err);
  }
}