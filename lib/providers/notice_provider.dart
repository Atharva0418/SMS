import 'package:flutter/material.dart';
import '../core/network/notice_service.dart';
import '../data/models/notice_model.dart';

class NoticeProvider extends ChangeNotifier {
  final NoticeService _service = NoticeService();

  List<NoticeModel> notices = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      notices = await _service.getAll();
    } on Exception catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String title, String body) async {
    try {
      final notice = await _service.create(title, body);
      notices.insert(0, notice);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, String title, String body) async {
    try {
      final updated = await _service.update(id, title, body);
      final idx = notices.indexWhere((n) => n.id == id);
      if (idx != -1) notices[idx] = updated;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _service.delete(id);
      notices.removeWhere((n) => n.id == id);
      notifyListeners();
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
