import 'package:hive/hive.dart';

part 'visitor_model.g.dart';

@HiveType(typeId: 0)
class VisitorModel extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late int flatNumber;

  @HiveField(4)
  String? checkInTime;

  @HiveField(5)
  String? checkOutTime;

  @HiveField(6)
  String? status;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  late DateTime createdAt;

  VisitorModel({
    this.id,
    required this.name,
    required this.phone,
    required this.flatNumber,
    this.checkInTime,
    this.checkOutTime,
    this.status,
    this.isSynced = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'flatNumber': flatNumber,
  };

  factory VisitorModel.fromJson(Map<String, dynamic> json) => VisitorModel(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    flatNumber: json['flatNumber'],
    checkInTime: json['checkInTime'],
    checkOutTime: json['checkOutTime'],
    status: json['status'],
    isSynced: true,
  );
}
