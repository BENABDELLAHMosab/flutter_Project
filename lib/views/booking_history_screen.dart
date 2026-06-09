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
  
  String? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = await _authController.getCurrentUserId();
    final userRole = await _authController.getCurrentUserRole();
    if (mounted) {
      setState(() {
        _userId = userId;
        _userRole = userRole;
      });
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
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
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation annulée avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations'),
        automaticallyImplyLeading: false, // In bottom nav
      ),
      body: _userId == null 
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<BookingModel>>(
              stream: _userRole == 'admin' 
                  ? _bookingController.getAllBookingsForAdminStream()
                  : _bookingController.getBookingsByUserStream(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement."));
                }
                
                final bookings = snapshot.data ?? [];
                
                if (bookings.isEmpty) {
                  return const EmptyState(
                    icon: Icons.book_online_outlined,
                    message: 'Aucune réservation',
                    subMessage: 'Vos futures réservations apparaîtront ici.',
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return BookingCard(
                      booking: booking,
                      onCancel: () => _cancelBooking(booking.id!),
                    );
                  },
                );
              },
            ),
    );
  }
}
