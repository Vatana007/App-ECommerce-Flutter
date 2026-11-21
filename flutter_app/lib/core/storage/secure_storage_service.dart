import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'auth_id_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserId = 'user_uid';
  static const String _keyCustomerUser = 'customer_user_data';

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveUserId(String uid) async {
    await _storage.write(key: _keyUserId, value: uid);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<void> saveCustomerUser(String jsonStr) async {
    await _storage.write(key: _keyCustomerUser, value: jsonStr);
  }

  Future<String?> getCustomerUser() async {
    return await _storage.read(key: _keyCustomerUser);
  }

  Future<void> clearCustomerUser() async {
    await clearAuth();
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyCustomerUser);
  }
}
