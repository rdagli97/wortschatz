import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Gemini API anahtarını cihazda şifreli olarak saklar (Keychain/Keystore/DPAPI).
class ApiKeyService {
  static const _key = 'gemini_api_key';

  final _storage = const FlutterSecureStorage();

  Future<String?> getApiKey() => _storage.read(key: _key);

  Future<void> saveApiKey(String apiKey) =>
      _storage.write(key: _key, value: apiKey);

  Future<void> clearApiKey() => _storage.delete(key: _key);
}
