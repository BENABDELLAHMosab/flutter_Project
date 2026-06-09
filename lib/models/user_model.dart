import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String fullName;
  final String email;
  final String? password; // Optional for Firebase
  final String role; // 'admin' ou 'client'
  final String? photoUrl;
  final DateTime? createdAt;

  UserModel({
    this.uid,
    required this.fullName,
    required this.email,
    this.password,
    this.role = 'client', // Default to client
    this.photoUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (uid != null) 'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      fullName: map['fullName'] ?? 'Inconnu',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? password,
    String? role,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
