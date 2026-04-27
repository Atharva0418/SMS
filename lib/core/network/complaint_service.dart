import '../../data/models/complaint_model.dart';
import 'api_client.dart';

/// Uses the shared [ApiClient] so every request carries the JWT automatically.
/// Same fix as visitor_service.dart — bare Dio caused 401s to be swallowed
/// during sync, leaving complaints permanently stuck as unsynced.
class ComplaintService {
  Future<ComplaintModel> createComplaint(ComplaintModel complaint) async {
    final response = await ApiClient.instance.post(
      '/api/complaints',
      data: complaint.toJson(),
    );
    return ComplaintModel.fromJson(response.data);
  }

  Future<List<ComplaintModel>> getComplaints() async {
    final response = await ApiClient.instance.get('/api/complaints');
    return (response.data as List)
        .map((e) => ComplaintModel.fromJson(e))
        .toList();
  }
}
