class UserModel {
  final int? id;
  final String fullName;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
    );
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
