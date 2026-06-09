import 'package:flutter/material.dart';
import '../controllers/booking_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/booking_model.dart';
import '../widgets/booking_card.dart';
import '../widgets/empty_state.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final _bookingController = BookingController();
  final _authController = AuthController();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final userId = await _authController.getCurrentUserId();
    if (userId != null) {
      final bookings = await _bookingController.getUserBookings(userId);
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation ?'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _bookingController.cancelBooking(bookingId);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réservation annulée avec succès')),
          );
        }
        _loadBookings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        automaticallyImplyLeading: false, // In bottom nav
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const EmptyState(
                  icon: Icons.book_online_outlined,
                  message: 'Aucune réservation',
                  subMessage: 'Vos futures réservations apparaîtront ici.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return BookingCard(
                      booking: booking,
                      onCancel: () => _cancelBooking(booking.id!),
                    );
                  },
                ),
    );
  }
}
