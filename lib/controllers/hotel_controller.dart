import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/hotel_model.dart';

class HotelController {
  final CollectionReference _hotelsRef = FirebaseFirestore.instance.collection('hotels');

  Stream<List<HotelModel>> getHotelsStream() {
    return _hotelsRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => HotelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<List<HotelModel>> getHotels() async {
    final snapshot = await _hotelsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => HotelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  Future<HotelModel?> getHotel(String id) async {
    final doc = await _hotelsRef.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return HotelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<List<HotelModel>> searchHotelsStream(String query) {
    if (query.isEmpty) return getHotelsStream();
    
    // Simplistic Firestore string search (prefix matching)
    final lowerQuery = query.toLowerCase();
    // Due to Firestore limitations, we just fetch all and filter in memory for complex queries
    return _hotelsRef.snapshots().map((snapshot) {
      final all = snapshot.docs.map((doc) => HotelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      return all.where((h) => 
        h.name.toLowerCase().contains(lowerQuery) || 
        h.city.toLowerCase().contains(lowerQuery)
      ).toList();
    });
  }

  Stream<List<HotelModel>> filterHotelsStream({double? maxPrice, double? minRating}) {
    return _hotelsRef.snapshots().map((snapshot) {
      final all = snapshot.docs.map((doc) => HotelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      return all.where((h) {
        if (maxPrice != null && h.pricePerNight > maxPrice) return false;
        if (minRating != null && h.rating < minRating) return false;
        return true;
      }).toList();
    });
  }

  Future<bool> addHotel(HotelModel hotel) async {
    try {
      await _hotelsRef.add(hotel.toMap());
      return true;
    } catch (e) {
      debugPrint('Erreur addHotel: $e');
      return false;
    }
  }

  Future<bool> updateHotel(HotelModel hotel) async {
    if (hotel.id == null) return false;
    try {
      await _hotelsRef.doc(hotel.id).update(hotel.toMap());
      return true;
    } catch (e) {
      debugPrint('Erreur updateHotel: $e');
      return false;
    }
  }

  Future<bool> deleteHotel(String id) async {
    try {
      await _hotelsRef.doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Erreur deleteHotel: $e');
      return false;
    }
  }

  Future<void> seedHotelsIfEmpty() async {
    try {
      final snapshot = await _hotelsRef.limit(1).get();
      if (snapshot.docs.isEmpty) {
        final initialHotels = [
          HotelModel(
            name: 'Le Grand Mogador',
            city: 'Casablanca',
            address: 'Boulevard Mohamed V',
            description: 'Hôtel 5 étoiles avec vue sur la mer.',
            pricePerNight: 1200.0,
            rating: 4.8,
            imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
            hasWifi: true,
            hasParking: true,
            hasPool: true,
            hasRestaurant: true,
            hasAC: true,
          ),
          HotelModel(
            name: 'Atlas Medina & Spa',
            city: 'Marrakech',
            address: 'Hivernage',
            description: 'Un magnifique riad moderne avec spa.',
            pricePerNight: 850.0,
            rating: 4.5,
            imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
            hasWifi: true,
            hasParking: false,
            hasPool: true,
            hasRestaurant: true,
            hasAC: true,
          ),
          HotelModel(
            name: 'Ibis Rabat Agdal',
            city: 'Rabat',
            address: 'Place de la Gare Agdal',
            description: 'Hôtel économique et confortable.',
            pricePerNight: 400.0,
            rating: 3.8,
            imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
            hasWifi: true,
            hasParking: true,
            hasPool: false,
            hasRestaurant: true,
            hasAC: true,
          ),
          HotelModel(
            name: 'Palais Faraj Suites & Spa',
            city: 'Fès',
            address: 'Bab Ziat',
            description: 'Luxe absolu dans la médina de Fès.',
            pricePerNight: 1500.0,
            rating: 4.9,
            imageUrl: 'https://images.unsplash.com/photo-1542314831-c53cd4b85ca4?w=800',
            hasWifi: true,
            hasParking: true,
            hasPool: true,
            hasRestaurant: true,
            hasAC: true,
          ),
          HotelModel(
            name: 'Marina Smir Hotel',
            city: 'Tétouan',
            address: 'Route de Ceuta',
            description: 'Resort balnéaire exceptionnel.',
            pricePerNight: 950.0,
            rating: 4.2,
            imageUrl: 'https://images.unsplash.com/photo-1582719478491-b99525287515?w=800',
            hasWifi: true,
            hasParking: true,
            hasPool: true,
            hasRestaurant: true,
            hasAC: true,
          ),
        ];

        for (var hotel in initialHotels) {
          await addHotel(hotel);
        }
        print('Seed: 5 hotels added to Firestore');
      }
    } catch (e) {
      print('Erreur seedHotelsIfEmpty: $e');
    }
  }
}
