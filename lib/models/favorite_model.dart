class FavoriteModel {
  final int? id;
  final int userId;
  final int hotelId;

  FavoriteModel({
    this.id,
    required this.userId,
    required this.hotelId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'hotelId': hotelId,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'],
      userId: map['userId'],
      hotelId: map['hotelId'],
    );
  }
}
