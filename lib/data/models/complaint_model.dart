import 'package:hive/hive.dart';

part 'complaint_model.g.dart';

@HiveType(typeId: 1)
class ComplaintModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late int flatNumber;

  @HiveField(2)
  late String description;

  @HiveField(3)
  String status;

  @HiveField(4)
  bool isSynced;

  @HiveField(5)
  late DateTime createdAt;

  ComplaintModel({
    this.id,
    required this.flatNumber,
    required this.description,
    this.status = 'OPEN',
    this.isSynced = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'flatNumber': flatNumber,
    'description': description,
  };

  factory ComplaintModel.fromJson(Map<String, dynamic> json) => ComplaintModel(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
    flatNumber: json['flatNumber'],
    description: json['description'],
    status: json['status'] ?? 'OPEN',
    isSynced: true,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}
