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

  bool _isSyncing = false;

  /// The flat number of the logged-in resident, or null for ADMIN/STAFF.
  /// Set this immediately after login via [setResidentFlat].
  int?   _residentFlat;
  String _role = '';

  bool get hasPendingSync  => HiveService.getUnsyncedVisitors().isNotEmpty;
  int  get pendingSyncCount => HiveService.getUnsyncedVisitors().length;

  VisitorProvider() {
    _loadLocal();
  }

  /// Called from the widget tree (or main) once auth state is known.
  void configure({required String role, int? flatNumber}) {
    _role         = role;
    _residentFlat = flatNumber;
    _loadLocal();
  }

  void _loadLocal() {
    final all = HiveService.getAllVisitors();
    visitors = _filter(all);
    notifyListeners();
  }

  /// Mirrors the server-side rule:
  ///   ADMIN / STAFF — all entries
  ///   RESIDENT      — only entries whose flatNumber matches theirs
  List<VisitorModel> _filter(List<VisitorModel> all) {
    if (_role == 'RESIDENT' && _residentFlat != null) {
      return all.where((v) => v.flatNumber == _residentFlat).toList();
    }
    return all;
  }

  Future<bool> addVisitor(VisitorModel visitor) async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();

    try {
      await HiveService.saveVisitor(visitor);
      _loadLocal();

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
    } on Exception {
      // Stays unsynced; retried on next reconnect.
    }
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;

    final online = await ConnectivityService.isOnline();
    if (!online) return;

    _isSyncing = true;
    try {
      final pending = HiveService.getUnsyncedVisitors();
      for (final visitor in pending) {
        final stillOnline = await ConnectivityService.isOnline();
        if (!stillOnline) break;
        await _syncVisitor(visitor);
      }
    } finally {
      _isSyncing = false;
      _loadLocal();
    }
  }
}
