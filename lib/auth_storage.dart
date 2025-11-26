import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();
  static final AuthStorage instance = AuthStorage._();
  final _storage = const FlutterSecureStorage();

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kSessionId = 'session_id';
  static const _kRegisterToken = 'register_token';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _kAccessToken, value: token);
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: _kAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _kRefreshToken, value: token);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _kRefreshToken);
  }

  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _kSessionId, value: sessionId);
  }

  Future<String?> readSessionId() async {
    return _storage.read(key: _kSessionId);
  }

  Future<void> saveRegisterToken(String token) async {
    await _storage.write(key: _kRegisterToken, value: token);
  }

  Future<String?> readRegisterToken() async {
    return _storage.read(key: _kRegisterToken);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
