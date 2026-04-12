import 'package:flutter/material.dart';
import '../core/local/hive_service.dart';
import '../core/network/connectivity_service.dart';
import '../core/network/visitor_service.dart';
import '../data/models/visitor_model.dart';

class VisitorProvider extends ChangeNotifier {
  final VisitorService _apiService = VisitorService();

  bool isLoading = false;
  String? errorMessage;
  List<VisitorModel> visitors = [];

  VisitorProvider() {
    _loadLocal();
  }

  void _loadLocal() {
    visitors = HiveService.getAllVisitors();
    notifyListeners();
  }

  Future<bool> addVisitor(VisitorModel visitor) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Always save locally first
      await HiveService.saveVisitor(visitor);
      visitors = HiveService.getAllVisitors();

      // Attempt API sync if online
      final online = await ConnectivityService.isOnline();
      if (online) {
        await _syncVisitor(visitor);
      }

      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _syncVisitor(VisitorModel visitor) async {
    try {
      final synced = await _apiService.createVisitor(visitor);
      await HiveService.markSynced(visitor, synced.id!);
      visitors = HiveService.getAllVisitors();
      notifyListeners();
    } on Exception {
      // Sync failed — stays in Hive with isSynced=false
      // Will be retried by syncPending()
    }
  }

  /// Call this on app foreground / reconnect to flush unsynced entries
  Future<void> syncPending() async {
    final online = await ConnectivityService.isOnline();
    if (!online) return;

    final pending = HiveService.getUnsyncedVisitors();
    for (final visitor in pending) {
      await _syncVisitor(visitor);
    }
  }
}
