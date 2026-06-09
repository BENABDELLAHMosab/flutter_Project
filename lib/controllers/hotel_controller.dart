import '../database/app_database.dart';
import '../models/hotel_model.dart';

class HotelController {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<HotelModel>> getHotels() async {
    return await _db.getAllHotels();
  }

  Future<HotelModel?> getHotel(int id) async {
    return await _db.getHotelById(id);
  }

  Future<List<HotelModel>> searchHotels(String query) async {
    return await _db.searchHotels(query);
  }

  Future<List<HotelModel>> filterHotels({double? maxPrice, double? minRating}) async {
    return await _db.filterHotels(maxPrice: maxPrice, minRating: minRating);
  }

  Future<bool> addHotel(HotelModel hotel) async {
    final id = await _db.insertHotel(hotel);
    return id > 0;
  }

  Future<bool> updateHotel(HotelModel hotel) async {
    final count = await _db.updateHotel(hotel);
    return count > 0;
  }

  Future<bool> deleteHotel(int id) async {
    final count = await _db.deleteHotel(id);
    return count > 0;
  }
  
  Future<int> getTotalHotelsCount() async {
    return await _db.getTotalHotels();
  }
}
