import 'package:flutter/material.dart';
import '../core/network/visitor_service.dart';
import '../data/models/visitor_model.dart';

class VisitorProvider extends ChangeNotifier {
  final VisitorService _service = VisitorService();

  bool isLoading = false;
  String? errorMessage;
  List<VisitorModel> visitors = [];

  Future<bool> addVisitor(VisitorModel visitor) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createVisitor(visitor);
      visitors.insert(0, created);
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
