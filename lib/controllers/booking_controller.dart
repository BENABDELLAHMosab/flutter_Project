import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

class BookingController {
  final CollectionReference _bookingsRef = FirebaseFirestore.instance.collection('bookings');

  Future<bool> createBooking(BookingModel booking) async {
    try {
      await _bookingsRef.add(booking.toMap());
      return true;
    } catch (e) {
      debugPrint('Erreur createBooking: $e');
      return false;
    }
  }

  Stream<List<BookingModel>> getBookingsByUserStream(String userId) {
    return _bookingsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final bookings = snapshot.docs.map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    });
  }

  Stream<List<BookingModel>> getAllBookingsForAdminStream() {
    return _bookingsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _bookingsRef.doc(bookingId).update({'status': 'cancelled'});
      return true;
    } catch (e) {
      debugPrint('Erreur cancelBooking: $e');
      return false;
    }
  }
  
  Stream<int> getTotalBookingsCountStream() {
    return _bookingsRef.snapshots().map((snapshot) => snapshot.docs.length);
  }
  
  Stream<double> getTotalBookingAmountStream() {
    return _bookingsRef.snapshots().map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['totalPrice'] ?? 0).toDouble();
      }
      return total;
    });
  }
}
