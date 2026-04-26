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

  // Prevents concurrent sync runs (e.g. rapid reconnect events firing twice).
  bool _isSyncing = false;

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

  /// Uploads a single [visitor] to the backend and marks it synced on success.
  /// Failures are intentionally swallowed: the entry stays [isSynced]=false
  /// and will be retried by [syncPending] on the next reconnect.
  Future<void> _syncVisitor(VisitorModel visitor) async {
    try {
      final synced = await _apiService.createVisitor(visitor);
      await HiveService.markSynced(visitor, synced.id!);
    } on Exception {
      // Sync failed — entry stays unsynced and will be retried later.
    }
  }

  /// Uploads all locally-stored unsynced entries to the backend.
  ///
  /// Each entry is attempted independently — a failure for one entry does not
  /// block the others. A [_isSyncing] guard ensures only one bulk-sync runs at
  /// a time, preventing duplicate POST calls when [syncPending] is triggered
  /// multiple times in quick succession (e.g. flapping connectivity).
  Future<void> syncPending() async {
    if (_isSyncing) return;

    final online = await ConnectivityService.isOnline();
    if (!online) return;

    _isSyncing = true;
    try {
      final pending = HiveService.getUnsyncedVisitors();
      for (final visitor in pending) {
        // Re-check online status between entries so we stop early on drop-out.
        final stillOnline = await ConnectivityService.isOnline();
        if (!stillOnline) break;
        await _syncVisitor(visitor);
      }
    } finally {
      _isSyncing = false;
      // Refresh list and pending count regardless of how sync went.
      visitors = HiveService.getAllVisitors();
      notifyListeners();
    }
  }
}
