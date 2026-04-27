import 'package:hive/hive.dart';

part 'notice_model.g.dart';

@HiveType(typeId: 2)
class NoticeModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String body;

  @HiveField(3)
  late DateTime createdAt;

  /// True once this notice has been confirmed by the server.
  /// Notices created offline are queued and synced when connectivity returns.
  @HiveField(4)
  bool isSynced;

  NoticeModel({
    this.id,
    required this.title,
    required this.body,
    DateTime? createdAt,
    this.isSynced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {'title': title, 'body': body};

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
    title: json['title'],
    body: json['body'],
    isSynced: true,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}
