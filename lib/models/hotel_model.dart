class HotelModel {
  final int? id;
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
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'city': city,
      'address': address,
      'description': description,
      'pricePerNight': pricePerNight,
      'rating': rating,
      'imageUrl': imageUrl,
      'hasWifi': hasWifi ? 1 : 0,
      'hasParking': hasParking ? 1 : 0,
      'hasPool': hasPool ? 1 : 0,
      'hasRestaurant': hasRestaurant ? 1 : 0,
      'hasAC': hasAC ? 1 : 0,
    };
  }

  factory HotelModel.fromMap(Map<String, dynamic> map) {
    return HotelModel(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      address: map['address'],
      description: map['description'],
      pricePerNight: map['pricePerNight'],
      rating: map['rating'],
      imageUrl: map['imageUrl'],
      hasWifi: map['hasWifi'] == 1,
      hasParking: map['hasParking'] == 1,
      hasPool: map['hasPool'] == 1,
      hasRestaurant: map['hasRestaurant'] == 1,
      hasAC: map['hasAC'] == 1,
    );
  }

  HotelModel copyWith({
    int? id,
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
    );
  }
}
