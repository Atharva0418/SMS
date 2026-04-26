import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../local/secure_storage.dart';

class AuthService {
  final Dio _dio;

  AuthService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? '',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  /// Returns the role string on success so the caller can route accordingly.
  Future<String> login(String email, String password) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    await SecureStorage.saveAuth(
      token: data['token'],
      role: data['role'],
      userId: data['userId'],
      name: data['name'],
    );

    return data['role'] as String;
  }

  /// Sends registration request. Returns normally on HTTP 201.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    int? flatNumber,
  }) async {
    await _dio.post(
      '/api/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (flatNumber != null) 'flatNumber': flatNumber,
      },
    );
  }

  Future<void> logout() => SecureStorage.clear();
}
