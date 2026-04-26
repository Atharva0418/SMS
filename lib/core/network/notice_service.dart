import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/notice_model.dart';
import '../local/secure_storage.dart';

class NoticeService {
  final Dio _dio;

  NoticeService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? '',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  Future<Options> _authOptions() async {
    final token = await SecureStorage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<NoticeModel>> getAll() async {
    final response = await _dio.get(
      '/api/notices',
      options: await _authOptions(),
    );
    return (response.data as List).map((e) => NoticeModel.fromJson(e)).toList();
  }

  Future<NoticeModel> create(String title, String body) async {
    final response = await _dio.post(
      '/api/notices',
      data: {'title': title, 'body': body},
      options: await _authOptions(),
    );
    return NoticeModel.fromJson(response.data);
  }

  Future<NoticeModel> update(int id, String title, String body) async {
    final response = await _dio.put(
      '/api/notices/$id',
      data: {'title': title, 'body': body},
      options: await _authOptions(),
    );
    return NoticeModel.fromJson(response.data);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/api/notices/$id', options: await _authOptions());
  }
}
