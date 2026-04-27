import 'package:hive_flutter/hive_flutter.dart';
import 'package:sms/data/models/visitor_model.dart';
import 'package:sms/data/models/complaint_model.dart';
import 'package:sms/data/models/notice_model.dart';

class HiveService {
  static const String visitorBoxName = 'visitors';
  static const String complaintBoxName = 'complaints';
  static const String noticeBoxName = 'notices';

  static Future<void> init() async {
    Hive.registerAdapter(VisitorModelAdapter());
    Hive.registerAdapter(ComplaintModelAdapter());
    Hive.registerAdapter(NoticeModelAdapter());
    await Hive.openBox<VisitorModel>(visitorBoxName);
    await Hive.openBox<ComplaintModel>(complaintBoxName);
    await Hive.openBox<NoticeModel>(noticeBoxName);
  }

  // ── Visitors ──────────────────────────────────────────────────────────────

  static Box<VisitorModel> get visitorBox =>
      Hive.box<VisitorModel>(visitorBoxName);

  static Future<void> saveVisitor(VisitorModel visitor) async {
    await visitorBox.add(visitor);
  }

  static List<VisitorModel> getAllVisitors() {
    return visitorBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<VisitorModel> getUnsyncedVisitors() {
    return visitorBox.values.where((v) => !v.isSynced).toList();
  }

  static Future<void> markVisitorSynced(
    VisitorModel visitor,
    int serverId,
  ) async {
    visitor.id = serverId;
    visitor.isSynced = true;
    await visitor.save();
  }

  /// Keep old name working so VisitorProvider doesn't need changes.
  static Future<void> markSynced(VisitorModel visitor, int serverId) =>
      markVisitorSynced(visitor, serverId);

  // ── Complaints ────────────────────────────────────────────────────────────

  static Box<ComplaintModel> get complaintBox =>
      Hive.box<ComplaintModel>(complaintBoxName);

  static Future<void> saveComplaint(ComplaintModel complaint) async {
    await complaintBox.add(complaint);
  }

  static List<ComplaintModel> getAllComplaints() {
    return complaintBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<ComplaintModel> getUnsyncedComplaints() {
    return complaintBox.values.where((c) => !c.isSynced).toList();
  }

  static Future<void> markComplaintSynced(
    ComplaintModel complaint,
    int serverId,
  ) async {
    complaint.id = serverId;
    complaint.isSynced = true;
    await complaint.save();
  }

  // ── Notices ───────────────────────────────────────────────────────────────

  static Box<NoticeModel> get noticeBox => Hive.box<NoticeModel>(noticeBoxName);

  static Future<void> saveNotice(NoticeModel notice) async {
    await noticeBox.add(notice);
  }

  /// Replace the entire local notice cache with a fresh server list.
  /// Called after a successful GET /api/notices so the cache stays accurate.
  static Future<void> replaceAllNotices(List<NoticeModel> notices) async {
    await noticeBox.clear();
    for (final n in notices) {
      await noticeBox.add(n);
    }
  }

  static List<NoticeModel> getAllNotices() {
    return noticeBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<NoticeModel> getUnsyncedNotices() {
    return noticeBox.values.where((n) => !n.isSynced).toList();
  }

  static Future<void> markNoticeSynced(NoticeModel notice, int serverId) async {
    notice.id = serverId;
    notice.isSynced = true;
    await notice.save();
  }

  /// Remove a notice from the local cache by server id.
  static Future<void> deleteNoticeById(int serverId) async {
    final key = noticeBox.keys.firstWhere(
      (k) => noticeBox.get(k)?.id == serverId,
      orElse: () => null,
    );
    if (key != null) await noticeBox.delete(key);
  }
}
