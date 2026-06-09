import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String? id;
  final String userId;
  final String hotelId;
  final DateTime? createdAt;

  FavoriteModel({
    this.id,
    required this.userId,
    required this.hotelId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'hotelId': hotelId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FavoriteModel(
      id: documentId,
      userId: map['userId'] ?? '',
      hotelId: map['hotelId'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }
}
