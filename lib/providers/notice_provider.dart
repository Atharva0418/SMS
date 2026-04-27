import 'package:flutter/material.dart';
import 'package:sms/core/local/hive_service.dart';
import 'package:sms/core/network/connectivity_service.dart';
import '../core/network/notice_service.dart';
import '../data/models/notice_model.dart';

class NoticeProvider extends ChangeNotifier {
  final NoticeService _service = NoticeService();

  List<NoticeModel> notices = [];
  bool isLoading = false;
  String? errorMessage;

  bool _isSyncing = false;

  int get pendingSyncCount => HiveService.getUnsyncedNotices().length;
  bool get hasPendingSync => HiveService.getUnsyncedNotices().isNotEmpty;

  NoticeProvider() {
    _loadLocal();
  }

  // ── Local read ─────────────────────────────────────────────────────────────

  void _loadLocal() {
    notices = HiveService.getAllNotices();
    notifyListeners();
  }

  // ── Remote fetch (with local cache fallback) ───────────────────────────────

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final online = await ConnectivityService.isOnline();
    if (online) {
      try {
        final fresh = await _service.getAll();
        // Persist fresh list to Hive so it is available offline next time.
        await HiveService.replaceAllNotices(fresh);
      } on Exception catch (e) {
        errorMessage = e.toString();
      }
    }
    // Always surface whatever is in Hive (either freshly written or cached).
    _loadLocal();
    isLoading = false;
    notifyListeners();
  }

  // ── Create (offline-first, identical pattern to ComplaintProvider) ─────────

  Future<bool> create(String title, String body) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final notice = NoticeModel(title: title, body: body);
      await HiveService.saveNotice(notice);
      _loadLocal();

      final online = await ConnectivityService.isOnline();
      if (online) {
        await _syncNotice(notice);
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

  // ── Update ─────────────────────────────────────────────────────────────────

  Future<bool> update(int id, String title, String body) async {
    try {
      final online = await ConnectivityService.isOnline();
      if (!online) {
        errorMessage = 'Cannot update notice while offline.';
        notifyListeners();
        return false;
      }
      final updated = await _service.update(id, title, body);
      // Refresh the local cache entry.
      await HiveService.replaceAllNotices(await _service.getAll());
      _loadLocal();
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<bool> delete(int id) async {
    try {
      final online = await ConnectivityService.isOnline();
      if (!online) {
        errorMessage = 'Cannot delete notice while offline.';
        notifyListeners();
        return false;
      }
      await _service.delete(id);
      await HiveService.deleteNoticeById(id);
      _loadLocal();
      return true;
    } on Exception catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Sync helpers ───────────────────────────────────────────────────────────

  Future<void> _syncNotice(NoticeModel notice) async {
    try {
      final synced = await _service.create(notice.title, notice.body);
      await HiveService.markNoticeSynced(notice, synced.id!);
    } on Exception {
      // Stays unsynced; retried on next reconnect via syncPending().
    }
  }

  /// Called by ConnectivityWrapper when connectivity is restored.
  Future<void> syncPending() async {
    if (_isSyncing) return;

    final online = await ConnectivityService.isOnline();
    if (!online) return;

    _isSyncing = true;
    try {
      final pending = HiveService.getUnsyncedNotices();
      for (final notice in pending) {
        final stillOnline = await ConnectivityService.isOnline();
        if (!stillOnline) break;
        await _syncNotice(notice);
      }
    } finally {
      _isSyncing = false;
      _loadLocal();
    }
  }
}
