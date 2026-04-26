class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;   // "ADMIN" | "STAFF" | "RESIDENT"
  final int? flatNumber;
  final String? phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.flatNumber,
    this.phone,
  });

  bool get isAdmin    => role == 'ADMIN';
  bool get isStaff    => role == 'STAFF';
  bool get isResident => role == 'RESIDENT';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:         json['id'],
        name:       json['name'],
        email:      json['email'],
        role:       json['role'],
        flatNumber: json['flatNumber'],
        phone:      json['phone'],
      );
}
