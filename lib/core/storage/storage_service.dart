import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Abstract contract ─────────────────────────────────────────────────────────

abstract class StorageService {
  Future<void> write(String key, String? value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> clearAll();
}

// ── Secure storage (tokens) ───────────────────────────────────────────────────

class SecureStorageService implements StorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Future<void> write(String key, String? value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clearAll() => _storage.deleteAll();
}

// ── Prefs storage (user data, non-sensitive) ──────────────────────────────────

class PrefsStorageService {
  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> writeString(String key, String value) async {
    await _init();
    await _prefs?.setString(key, value);
  }

  Future<String?> readString(String key) async {
    await _init();
    return _prefs?.getString(key);
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await _init();
    await _prefs?.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readJson(String key) async {
    await _init();
    final data = _prefs?.getString(key);
    if (data != null) return jsonDecode(data) as Map<String, dynamic>;
    return null;
  }

  Future<void> delete(String key) async {
    await _init();
    await _prefs?.remove(key);
  }

  Future<void> clearAll() async {
    await _init();
    await _prefs?.clear();
  }
}

// ── Riverpod providers ────────────────────────────────────────────────────────

/// Provider for [PrefsStorageService] (non-sensitive, SharedPreferences-backed).
final prefsServiceProvider = Provider<PrefsStorageService>(
  (_) => PrefsStorageService(),
);
