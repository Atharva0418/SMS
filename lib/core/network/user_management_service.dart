import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/user_model.dart';
import '../local/secure_storage.dart';

class UserManagementService {
  final Dio _dio;

  UserManagementService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? '',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  Future<Options> _auth() async {
    final token = await SecureStorage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<UserModel>> getPending() async {
    final response = await _dio.get(
      '/api/users/pending',
      options: await _auth(),
    );
    return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel> approve(int userId) async {
    final response = await _dio.patch(
      '/api/users/$userId/approve',
      options: await _auth(),
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> reject(int userId) async {
    final response = await _dio.patch(
      '/api/users/$userId/reject',
      options: await _auth(),
    );
    return UserModel.fromJson(response.data);
  }
}
