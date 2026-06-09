import '../database/app_database.dart';
import '../models/booking_model.dart';

class BookingController {
  final AppDatabase _db = AppDatabase.instance;

  Future<bool> createBooking(BookingModel booking) async {
    final id = await _db.insertBooking(booking);
    return id > 0;
  }

  Future<List<BookingModel>> getUserBookings(int userId) async {
    return await _db.getBookingsWithHotelDetails(userId);
  }

  Future<bool> cancelBooking(int bookingId) async {
    final count = await _db.cancelBooking(bookingId);
    return count > 0;
  }
  
  Future<int> getTotalBookingsCount() async {
    return await _db.getTotalBookings();
  }
  
  Future<double> getTotalBookingAmount(int userId) async {
    return await _db.getTotalBookingAmount(userId);
  }
}
