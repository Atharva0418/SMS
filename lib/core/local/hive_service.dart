import 'package:hive_flutter/hive_flutter.dart';
import 'package:sms/data/models/visitor_model.dart';

class HiveService {
  static const String visitorBoxName = 'visitors';

  static Future<void> init() async {
    Hive.registerAdapter(VisitorModelAdapter());
    await Hive.openBox<VisitorModel>(visitorBoxName);
  }

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

  static Future<void> markSynced(VisitorModel visitor, int serverId) async {
    visitor.id = serverId;
    visitor.isSynced = true;
    await visitor.save();
  }
}
