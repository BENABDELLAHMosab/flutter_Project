import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';
import '../models/favorite_model.dart';

class FavoriteController {
  final CollectionReference _favoritesRef = FirebaseFirestore.instance.collection('favorites');
  final CollectionReference _hotelsRef = FirebaseFirestore.instance.collection('hotels');

  Future<bool> toggleFavorite(String userId, String hotelId) async {
    final isFav = await isFavorite(userId, hotelId);
    if (isFav) {
      await removeFavorite(userId, hotelId);
      return false; // Not a favorite anymore
    } else {
      await addFavorite(userId, hotelId);
      return true; // Is now a favorite
    }
  }

  Future<void> addFavorite(String userId, String hotelId) async {
    final favorite = FavoriteModel(
      userId: userId,
      hotelId: hotelId,
    );
    // Use a custom document ID based on userId and hotelId to avoid duplicates and allow easy checking
    await _favoritesRef.doc('${userId}_$hotelId').set(favorite.toMap());
  }

  Future<void> removeFavorite(String userId, String hotelId) async {
    await _favoritesRef.doc('${userId}_$hotelId').delete();
  }

  Future<bool> isFavorite(String userId, String hotelId) async {
    final doc = await _favoritesRef.doc('${userId}_$hotelId').get();
    return doc.exists;
  }

  Stream<bool> isFavoriteStream(String userId, String hotelId) {
    return _favoritesRef.doc('${userId}_$hotelId').snapshots().map((doc) => doc.exists);
  }

  Stream<List<HotelModel>> getUserFavoritesStream(String userId) {
    // We listen to the user's favorites
    return _favoritesRef.where('userId', isEqualTo: userId).snapshots().asyncMap((snapshot) async {
      List<HotelModel> favoriteHotels = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final hotelId = data['hotelId'] as String;
        final hotelDoc = await _hotelsRef.doc(hotelId).get();
        if (hotelDoc.exists && hotelDoc.data() != null) {
          favoriteHotels.add(HotelModel.fromMap(hotelDoc.data() as Map<String, dynamic>, hotelDoc.id));
        }
      }
      return favoriteHotels;
    });
  }
  
  Stream<int> getTotalFavoritesCountStream(String userId) {
    return _favoritesRef.where('userId', isEqualTo: userId).snapshots().map((snapshot) => snapshot.docs.length);
  }
}
