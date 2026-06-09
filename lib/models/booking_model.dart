import 'package:cloud_firestore/cloud_firestore.dart';
import 'hotel_model.dart';

class BookingModel {
  final String? id;
  final String userId;
  final String userName;
  final String userEmail;
  final String hotelId;
  final String hotelName;
  final String hotelCity;
  final String checkIn;
  final String checkOut;
  final int guests;
  final int rooms;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;
  
  // Optional detailed hotel for view layer (if you ever join manually)
  final HotelModel? hotel;

  BookingModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.hotelId,
    required this.hotelName,
    required this.hotelCity,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.rooms,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.hotel,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'hotelCity': hotelCity,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
      'rooms': rooms,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String documentId, {HotelModel? hotel}) {
    return BookingModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Inconnu',
      userEmail: map['userEmail'] ?? '',
      hotelId: map['hotelId'] ?? '',
      hotelName: map['hotelName'] ?? 'Hôtel inconnu',
      hotelCity: map['hotelCity'] ?? '',
      checkIn: map['checkIn'] ?? '',
      checkOut: map['checkOut'] ?? '',
      guests: map['guests'] ?? 1,
      rooms: map['rooms'] ?? 1,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      hotel: hotel,
    );
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? hotelId,
    String? hotelName,
    String? hotelCity,
    String? checkIn,
    String? checkOut,
    int? guests,
    int? rooms,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    HotelModel? hotel,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      hotelCity: hotelCity ?? this.hotelCity,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      hotel: hotel ?? this.hotel,
    );
  }
}
