import 'package:cloud_firestore/cloud_firestore.dart';

class HotelModel {
  final String? id;
  final String name;
  final String city;
  final String address;
  final String description;
  final double pricePerNight;
  final double rating;
  final String imageUrl;
  final bool hasWifi;
  final bool hasParking;
  final bool hasPool;
  final bool hasRestaurant;
  final bool hasAC;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HotelModel({
    this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.description,
    required this.pricePerNight,
    required this.rating,
    required this.imageUrl,
    required this.hasWifi,
    required this.hasParking,
    required this.hasPool,
    required this.hasRestaurant,
    required this.hasAC,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
      'address': address,
      'description': description,
      'pricePerNight': pricePerNight,
      'rating': rating,
      'imageUrl': imageUrl,
      'hasWifi': hasWifi,
      'hasParking': hasParking,
      'hasPool': hasPool,
      'hasRestaurant': hasRestaurant,
      'hasAC': hasAC,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory HotelModel.fromMap(Map<String, dynamic> map, String documentId) {
    return HotelModel(
      id: documentId,
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      hasWifi: map['hasWifi'] == true,
      hasParking: map['hasParking'] == true,
      hasPool: map['hasPool'] == true,
      hasRestaurant: map['hasRestaurant'] == true,
      hasAC: map['hasAC'] == true,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  HotelModel copyWith({
    String? id,
    String? name,
    String? city,
    String? address,
    String? description,
    double? pricePerNight,
    double? rating,
    String? imageUrl,
    bool? hasWifi,
    bool? hasParking,
    bool? hasPool,
    bool? hasRestaurant,
    bool? hasAC,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HotelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      description: description ?? this.description,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      hasWifi: hasWifi ?? this.hasWifi,
      hasParking: hasParking ?? this.hasParking,
      hasPool: hasPool ?? this.hasPool,
      hasRestaurant: hasRestaurant ?? this.hasRestaurant,
      hasAC: hasAC ?? this.hasAC,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
