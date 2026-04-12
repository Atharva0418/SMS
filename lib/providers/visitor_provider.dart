import 'package:flutter/material.dart';
import 'package:sms/core/local/hive_service.dart';
import 'package:sms/core/network/connectivity_service.dart';
import 'package:sms/core/network/visitor_service.dart';
import 'package:sms/data/models/visitor_model.dart';

class VisitorProvider extends ChangeNotifier {
  final VisitorService _apiService = VisitorService();

  bool isLoading = false;
  String? errorMessage;
  List<VisitorModel> visitors = [];

  bool get hasPendingSync => HiveService.getUnsyncedVisitors().isNotEmpty;

  int get pendingSyncCount => HiveService.getUnsyncedVisitors().length;

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
      await HiveService.saveVisitor(visitor);
      visitors = HiveService.getAllVisitors();

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

  Future<void> syncPending() async {
    final online = await ConnectivityService.isOnline();
    if (!online) return;

    final pending = HiveService.getUnsyncedVisitors();
    for (final visitor in pending) {
      await _syncVisitor(visitor);
    }
  }
}
