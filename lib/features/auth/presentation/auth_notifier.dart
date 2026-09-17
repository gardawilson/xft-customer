import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xft/features/auth/data/auth_service.dart';
import 'package:xft/features/auth/domain/models/auth_response.dart';
import 'package:xft/features/auth/domain/models/user_model.dart';
import 'package:xft/core/storage/storage_service.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthResponse?> build() async {
    // Check if we are in the middle of a reset password flow
    final prefs = ref.read(prefsServiceProvider);
    final resetEmail = await prefs.readString('reset_password_email');
    if (resetEmail != null) {
      // We don't change the state here, but we can use this information in the router
    }

    // Restore session from secure storage
    final secureStorage = ref.read(secureStorageServiceProvider);
    final storedToken = await secureStorage.read('access_token');
    if (storedToken == null) return null;

    final userData = await prefs.readJson('user_data');
    if (userData == null) return null;

    return AuthResponse(
      success: true,
      message: 'Session restored',
      data: AuthData(
        token: storedToken,
        user: UserModel.fromJson(userData),
      ),
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      return await authService.login(email, password);
    });
  }

  Future<void> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      return await authService.register(fullName, email, phone, password);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      return null;
    });
  }

  Future<bool> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.forgotPassword(email);
      if (success) {
        final prefs = ref.read(prefsServiceProvider);
        await prefs.writeString('reset_password_email', email);
        state = const AsyncValue.data(null);
        return true;
      }
      state = const AsyncValue.data(null);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> resetPassword(String otp, String newPassword) async {
    state = const AsyncValue.loading();
    try {
      final prefs = ref.read(prefsServiceProvider);
      final email = await prefs.readString('reset_password_email');
      if (email == null) throw Exception('No reset email found');

      final authService = ref.read(authServiceProvider);
      final success = await authService.resetPassword(email, otp, newPassword);
      if (success) {
        await prefs.delete('reset_password_email');
        state = const AsyncValue.data(null);
        return true;
      }
      state = const AsyncValue.data(null);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> cancelResetPassword() async {
    final prefs = ref.read(prefsServiceProvider);
    await prefs.delete('reset_password_email');
    ref.invalidateSelf();
  }

  /// Update profil (nama, telepon, foto). Sengaja TIDAK set state ke
  /// AsyncValue.loading() di sini supaya data user yang sedang tampil di
  /// layar lain tidak sempat hilang/blank selama proses berjalan — cukup
  /// pakai loading indicator lokal di halaman edit profil.
  Future<bool> updateProfile({
    required String name,
    required String phone,
    File? avatarFile,
    bool removeAvatar = false,
  }) async {
    final previousState = state;
    try {
      final authService = ref.read(authServiceProvider);
      final updatedUser = await authService.updateProfile(
        name: name,
        phone: phone,
        avatarFile: avatarFile,
        removeAvatar: removeAvatar,
      );

      final current = previousState.value;
      if (current?.data != null) {
        state = AsyncValue.data(
          current!.copyWith(data: current.data!.copyWith(user: updatedUser)),
        );
      }
      return true;
    } catch (e, stack) {
      // Kembalikan state ke data sebelumnya supaya UI lain (yang menampilkan
      // nama/foto user) tidak ikut rusak gara-gara error di halaman ini.
      // Error-nya tetap dilempar ke pemanggil (halaman edit profil) supaya
      // bisa ditampilkan lewat SnackBar di sana.
      state = previousState;
      Error.throwWithStackTrace(e, stack);
    }
  }

  /// Ganti password akun yang sedang login. Tidak memengaruhi state user
  /// (nama/email/dll tidak berubah), jadi tidak perlu utak-atik `state`
  /// di sini -- cukup teruskan ke AuthService dan biarkan error (kalau ada)
  /// naik ke halaman pemanggil untuk ditampilkan lewat SnackBar.
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final authService = ref.read(authServiceProvider);
    return authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  /// Kirim ulang email verifikasi. Tidak memengaruhi state user, sama
  /// seperti changePassword -- cukup teruskan ke AuthService.
  Future<bool> resendVerificationEmail() async {
    final authService = ref.read(authServiceProvider);
    return authService.resendVerificationEmail();
  }
}

@riverpod
Future<String?> resetPasswordEmail(Ref ref) async {
  final prefs = ref.watch(prefsServiceProvider);
  return await prefs.readString('reset_password_email');
}
