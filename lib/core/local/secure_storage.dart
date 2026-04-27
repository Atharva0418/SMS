import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around flutter_secure_storage.
/// Stores the JWT token and decoded role so the rest of the app
/// can read them without re-parsing the token each time.
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken    = 'jwt_token';
  static const _keyRole     = 'user_role';
  static const _keyUserId   = 'user_id';
  static const _keyName     = 'user_name';
  static const _keyFlat     = 'user_flat';

  static Future<void> saveAuth({
    required String token,
    required String role,
    required int    userId,
    required String name,
    int?            flatNumber,
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken,  value: token),
      _storage.write(key: _keyRole,   value: role),
      _storage.write(key: _keyUserId, value: userId.toString()),
      _storage.write(key: _keyName,   value: name),
      _storage.write(key: _keyFlat,   value: flatNumber?.toString() ?? ''),
    ]);
  }

  static Future<String?> getToken()  => _storage.read(key: _keyToken);
  static Future<String?> getRole()   => _storage.read(key: _keyRole);
  static Future<String?> getName()   => _storage.read(key: _keyName);
  static Future<int?> getUserId() async {
    final raw = await _storage.read(key: _keyUserId);
    return raw != null ? int.tryParse(raw) : null;
  }

  static Future<int?> getFlatNumber() async {
    final raw = await _storage.read(key: _keyFlat);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  static Future<bool> hasToken() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  static Future<void> clear() => _storage.deleteAll();
}
