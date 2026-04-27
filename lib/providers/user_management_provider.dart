import 'package:flutter/material.dart';
import '../core/network/user_management_service.dart';
import '../data/models/user_model.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementService _service = UserManagementService();

  List<UserModel> pendingUsers = [];
  bool isLoading = false;
  String? errorMessage;

  int get pendingCount => pendingUsers.length;

  Future<void> loadPending() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      pendingUsers = await _service.getPending();
    } on Exception catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(int userId) async {
    try {
      await _service.approve(userId);
      pendingUsers.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(int userId) async {
    try {
      await _service.reject(userId);
      pendingUsers.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
