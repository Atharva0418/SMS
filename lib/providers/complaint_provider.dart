import 'package:flutter/material.dart';
import 'package:sms/core/local/hive_service.dart';
import 'package:sms/core/network/complaint_service.dart';
import 'package:sms/core/network/connectivity_service.dart';
import 'package:sms/data/models/complaint_model.dart';

class ComplaintProvider extends ChangeNotifier {
  final ComplaintService _apiService = ComplaintService();

  bool isLoading = false;
  String? errorMessage;
  List<ComplaintModel> complaints = [];

  bool _isSyncing = false;

  bool get hasPendingSync => HiveService.getUnsyncedComplaints().isNotEmpty;
  int get pendingSyncCount => HiveService.getUnsyncedComplaints().length;

  ComplaintProvider() {
    _loadLocal();
    // Fetch from server on startup so every device always has up-to-date data.
    _fetchFromServer();
  }

  void _loadLocal() {
    // No role filter — all users see all complaints.
    complaints = HiveService.getAllComplaints();
    notifyListeners();
  }

  /// Pull all complaints from MySQL, replace the local Hive cache
  /// (preserving any unsynced offline entries), then reload the view.
  Future<void> _fetchFromServer() async {
    final online = await ConnectivityService.isOnline();
    if (!online) return;

    try {
      final serverComplaints = await _apiService.getComplaints();

      final unsynced = HiveService.getUnsyncedComplaints();
      await HiveService.complaintBox.clear();

      for (final c in unsynced) {
        await HiveService.saveComplaint(c);
      }
      for (final c in serverComplaints) {
        await HiveService.saveComplaint(c);
      }

      _loadLocal();
    } on Exception {
      // Server unreachable — keep showing local cache.
    }
  }

  Future<bool> addComplaint(ComplaintModel complaint) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await HiveService.saveComplaint(complaint);
      complaints = HiveService.getAllComplaints();

      final online = await ConnectivityService.isOnline();
      if (online) {
        await _syncComplaint(complaint);
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

  Future<void> _syncComplaint(ComplaintModel complaint) async {
    try {
      final synced = await _apiService.createComplaint(complaint);
      await HiveService.markComplaintSynced(complaint, synced.id!);
    } on Exception {
      // Stays unsynced; retried on next reconnect.
    }
  }

  /// Called by ConnectivityWrapper when connectivity is restored.
  Future<void> syncPending() async {
    if (_isSyncing) return;

    final online = await ConnectivityService.isOnline();
    if (!online) return;

    _isSyncing = true;
    try {
      final pending = HiveService.getUnsyncedComplaints();
      for (final complaint in pending) {
        final stillOnline = await ConnectivityService.isOnline();
        if (!stillOnline) break;
        await _syncComplaint(complaint);
      }
    } finally {
      _isSyncing = false;
      complaints = HiveService.getAllComplaints();
      notifyListeners();
    }
  }
}
