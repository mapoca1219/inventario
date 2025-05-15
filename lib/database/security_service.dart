
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveSession(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getSession() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteSession() async {
    await _storage.delete(key: 'auth_token');
  }
}