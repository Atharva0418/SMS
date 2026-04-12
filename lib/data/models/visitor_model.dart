class VisitorModel {
  final int? id;
  final String name;
  final String phone;
  final int flatNumber;
  final String? checkInTime;
  final String? checkOutTime;
  final String? status;

  VisitorModel({
    this.id,
    required this.name,
    required this.phone,
    required this.flatNumber,
    this.checkInTime,
    this.checkOutTime,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'flatNumber': flatNumber,
  };

  factory VisitorModel.fromJson(Map<String, dynamic> json) =>
      VisitorModel(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        flatNumber: json['flatNumber'],
        checkInTime: json['checkInTime'],
        checkOutTime: json['checkOutTime'],
        status: json['status'],
      );
}