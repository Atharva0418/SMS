import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/models/complaint_model.dart';

class ComplaintService {
  final Dio _dio;

  ComplaintService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: '${dotenv.env['BASE_URL']}',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

  Future<ComplaintModel> createComplaint(ComplaintModel complaint) async {
    final response = await _dio.post(
      '/api/complaints',
      data: complaint.toJson(),
    );
    return ComplaintModel.fromJson(response.data);
  }

  Future<List<ComplaintModel>> getComplaints() async {
    final response = await _dio.get('/api/complaints');
    return (response.data as List)
        .map((e) => ComplaintModel.fromJson(e))
        .toList();
  }
}
