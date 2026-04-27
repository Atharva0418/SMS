class UserModel {
  final int    id;
  final String name;
  final String email;
  final String role;    // "ADMIN" | "STAFF" | "RESIDENT"
  final String status;  // "PENDING" | "APPROVED" | "REJECTED"
  final int?   flatNumber;
  final String? phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.flatNumber,
    this.phone,
  });

  bool get isAdmin    => role == 'ADMIN';
  bool get isStaff    => role == 'STAFF';
  bool get isResident => role == 'RESIDENT';
  bool get isPending  => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:         json['id'],
        name:       json['name'],
        email:      json['email'],
        role:       json['role'],
        status:     json['status'] ?? 'PENDING',
        flatNumber: json['flatNumber'],
        phone:      json['phone'],
      );
}
