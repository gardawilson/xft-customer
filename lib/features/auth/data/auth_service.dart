import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/core/storage/storage_service.dart';
import 'package:xft/features/auth/domain/models/auth_response.dart';
import 'package:xft/features/auth/domain/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio, SecureStorageService(), PrefsStorageService());
});

class AuthService {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  final PrefsStorageService _prefsStorage;

  AuthService(this._dio, this._secureStorage, this._prefsStorage);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.data != null) {
        // Save tokens securely
        await _secureStorage.write('access_token', authResponse.data!.token);

        // Save user data in shared preferences
        await _prefsStorage.writeJson('user_data', authResponse.data!.user.toJson());
      } else {
        throw Exception(authResponse.message);
      }

      return authResponse;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'An error occurred during login';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to connect to the server');
    }
  }

  Future<AuthResponse> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': fullName,
          'email': email,
          'phone_number': phone,
          'password': password,
          'password_confirmation': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.data != null) {
        // Save tokens securely
        await _secureStorage.write('access_token', authResponse.data!.token);

        // Save user data in shared preferences
        await _prefsStorage.writeJson('user_data', authResponse.data!.user.toJson());
      } else {
        throw Exception(authResponse.message);
      }

      return authResponse;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'An error occurred during registration';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to connect to the server');
    }
  }

  Future<void> logout() async {
    // Remove tokens from secure storage
    await _secureStorage.delete('access_token');
    await _secureStorage.delete('refresh_token');
    await _prefsStorage.delete('user_data');

    // Also clear everything else to be sure
    await _secureStorage.clearAll();
    await _prefsStorage.clearAll();
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/password/forgot',
        data: {'email': email},
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'An error occurred';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<bool> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/password/reset',
        data: {
          'email': email,
          'token': otp,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'An error occurred';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  /// Memperbarui nama, nomor telepon, dan (opsional) foto profil customer.
  /// Endpoint backend TIDAK menerima perubahan email (lihat validasi di
  /// AuthController@updateProfile), jadi email sengaja tidak dikirim di sini.
  Future<UserModel> updateProfile({
    required String name,
    required String phone,
    File? avatarFile,
    bool removeAvatar = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'phone_number': phone,
        if (removeAvatar) 'delete_image': true,
        if (avatarFile != null)
          'image': await MultipartFile.fromFile(
            avatarFile.path,
            filename: avatarFile.path.split('/').last,
          ),
      });

      final response = await _dio.post('/update-profil', data: formData);

      if (response.data['success'] == true) {
        final updatedFields = response.data['data'] as Map<String, dynamic>;

        // Endpoint ini cuma mengembalikan sebagian field (id, name, email,
        // phone_number, profile_picture). Merge dengan data user yang
        // sudah tersimpan supaya field lain (point_balance, is_active, dst)
        // tidak tertimpa jadi nilai default.
        final cachedJson = await _prefsStorage.readJson('user_data');
        final merged = {...?cachedJson, ...updatedFields};
        final updatedUser = UserModel.fromJson(merged);

        await _prefsStorage.writeJson('user_data', updatedUser.toJson());
        return updatedUser;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first is List
          ? (errors!.values.first as List).first
          : null;
      final message =
          firstError ??
          e.response?.data?['message'] ??
          'Gagal memperbarui profil';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung ke server');
    }
  }

  /// Mengubah password customer yang sedang login.
  /// Backend: POST /change-password (butuh Bearer token, sudah otomatis
  /// disisipkan lewat AuthInterceptor untuk semua request).
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/change-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPassword,
        },
      );
      return response.data['success'] == true;
    } on DioException catch (e) {
      final errors = e.response?.data?['errors'] as Map<String, dynamic>?;
      final firstError = errors?.values.first is List
          ? (errors!.values.first as List).first
          : null;
      final message =
          firstError ??
          e.response?.data?['message'] ??
          'Gagal mengubah password';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung ke server');
    }
  }

  /// Kirim ulang email verifikasi untuk customer yang sedang login.
  /// Backend: POST /auth/resend-verification (butuh Bearer token).
  Future<bool> resendVerificationEmail() async {
    try {
      final response = await _dio.post('/auth/resend-verification');
      return response.data['success'] == true;
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Gagal mengirim ulang email verifikasi';
      throw Exception(message);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Gagal terhubung ke server');
    }
  }
}
