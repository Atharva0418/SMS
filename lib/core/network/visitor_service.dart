import 'package:dio/dio.dart';
import '../../data/models/visitor_model.dart';

class VisitorService {
  final Dio _dio;

  VisitorService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://192.168.1.2:8080',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  Future<VisitorModel> createVisitor(VisitorModel visitor) async {
    final response = await _dio.post('/api/visitors', data: visitor.toJson());
    return VisitorModel.fromJson(response.data);
  }

  Future<List<VisitorModel>> getVisitors() async {
    final response = await _dio.get('/api/visitors');
    return (response.data as List)
        .map((e) => VisitorModel.fromJson(e))
        .toList();
  }
}
