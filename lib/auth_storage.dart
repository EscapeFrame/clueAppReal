import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();
  static final AuthStorage instance = AuthStorage._();
  final _storage = const FlutterSecureStorage();

  static const _kAccessToken = 'access_token';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _kAccessToken, value: token);
  }

  Future<String?> readAccessToken() async {
    return _storage.read(key: _kAccessToken);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
