import 'package:hive_flutter/hive_flutter.dart';
import 'package:sms/data/models/visitor_model.dart';
import 'package:sms/data/models/complaint_model.dart';

class HiveService {
  static const String visitorBoxName = 'visitors';
  static const String complaintBoxName = 'complaints';

  static Future<void> init() async {
    Hive.registerAdapter(VisitorModelAdapter());
    Hive.registerAdapter(ComplaintModelAdapter());
    await Hive.openBox<VisitorModel>(visitorBoxName);
    await Hive.openBox<ComplaintModel>(complaintBoxName);
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
}
