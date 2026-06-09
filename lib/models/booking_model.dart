import 'hotel_model.dart';

class BookingModel {
  final int? id;
  final int userId;
  final int hotelId;
  final String checkIn;
  final String checkOut;
  final int guests;
  final int rooms;
  final double totalPrice;
  final String status;
  
  // Optional detailed hotel for view layer
  final HotelModel? hotel;

  BookingModel({
    this.id,
    required this.userId,
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.rooms,
    required this.totalPrice,
    required this.status,
    this.hotel,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'hotelId': hotelId,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
      'rooms': rooms,
      'totalPrice': totalPrice,
      'status': status,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, {HotelModel? hotel}) {
    return BookingModel(
      id: map['id'],
      userId: map['userId'],
      hotelId: map['hotelId'],
      checkIn: map['checkIn'],
      checkOut: map['checkOut'],
      guests: map['guests'],
      rooms: map['rooms'],
      totalPrice: map['totalPrice'],
      status: map['status'],
      hotel: hotel,
    );
  }

  BookingModel copyWith({
    int? id,
    int? userId,
    int? hotelId,
    String? checkIn,
    String? checkOut,
    int? guests,
    int? rooms,
    double? totalPrice,
    String? status,
    HotelModel? hotel,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      rooms: rooms ?? this.rooms,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      hotel: hotel ?? this.hotel,
    );
  }
}
