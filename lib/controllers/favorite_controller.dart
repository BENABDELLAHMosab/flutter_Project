import '../database/app_database.dart';
import '../models/hotel_model.dart';

class FavoriteController {
  final AppDatabase _db = AppDatabase.instance;

  Future<bool> toggleFavorite(int userId, int hotelId) async {
    final isFav = await _db.isFavorite(userId, hotelId);
    if (isFav) {
      await _db.removeFavorite(userId, hotelId);
      return false; // Not a favorite anymore
    } else {
      await _db.addFavorite(userId, hotelId);
      return true; // Is now a favorite
    }
  }

  Future<bool> isFavorite(int userId, int hotelId) async {
    return await _db.isFavorite(userId, hotelId);
  }

  Future<List<HotelModel>> getUserFavorites(int userId) async {
    return await _db.getFavoritesByUser(userId);
  }
  
  Future<int> getTotalFavoritesCount(int userId) async {
    return await _db.getTotalFavorites(userId);
  }
}
