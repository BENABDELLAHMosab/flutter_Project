import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';
import '../models/favorite_model.dart';

class FavoriteController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _hotelsRef = FirebaseFirestore.instance.collection('hotels');

  CollectionReference _userFavoritesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

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
    await _userFavoritesRef(userId).doc(hotelId).set(favorite.toMap());
  }

  Future<void> removeFavorite(String userId, String hotelId) async {
    await _userFavoritesRef(userId).doc(hotelId).delete();
  }

  Future<bool> isFavorite(String userId, String hotelId) async {
    final doc = await _userFavoritesRef(userId).doc(hotelId).get();
    return doc.exists;
  }

  Stream<bool> isFavoriteStream(String userId, String hotelId) {
    return _userFavoritesRef(userId).doc(hotelId).snapshots().map((doc) => doc.exists);
  }

  Stream<List<HotelModel>> getUserFavoritesStream(String userId) {
    return _userFavoritesRef(userId).snapshots().asyncMap((snapshot) async {
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
    return _userFavoritesRef(userId).snapshots().map((snapshot) => snapshot.docs.length);
  }
}
