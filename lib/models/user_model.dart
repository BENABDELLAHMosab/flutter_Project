class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String role; // 'admin' ou 'client'

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.role = 'client', // Default to client
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
      role: map['role'] ?? 'client',
    );
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
