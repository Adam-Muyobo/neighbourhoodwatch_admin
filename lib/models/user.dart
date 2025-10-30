class User {
  final int? userId;
  final String userUUID;
  final String name;
  final String? phoneNumber;
  final String email;
  final String role;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.userId,
    required this.userUUID,
    required this.name,
    this.phoneNumber,
    required this.email,
    required this.role,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userUUID: json['userUUID'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'MEMBER',
      status: json['status'] ?? 'INACTIVE',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userUUID': userUUID,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'status': status,
    };
  }

  User copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? role,
    String? status,
  }) {
    return User(
      userId: userId,
      userUUID: userUUID,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}