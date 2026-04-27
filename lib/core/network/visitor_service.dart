import '../../data/models/visitor_model.dart';
import 'api_client.dart';

/// Uses the shared [ApiClient] so every request carries the JWT automatically.
/// This fixes the bug where offline-created visitor entries would never sync
/// once the backend required authentication — the old bare Dio had no headers,
/// received HTTP 401, which was silently swallowed, leaving entries unsynced.
class VisitorService {
  Future<VisitorModel> createVisitor(VisitorModel visitor) async {
    final response = await ApiClient.instance.post(
      '/api/visitors',
      data: visitor.toJson(),
    );
    return VisitorModel.fromJson(response.data);
  }

  Future<List<VisitorModel>> getVisitors() async {
    final response = await ApiClient.instance.get('/api/visitors');
    return (response.data as List)
        .map((e) => VisitorModel.fromJson(e))
        .toList();
  }
}
