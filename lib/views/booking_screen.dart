import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel_model.dart';
import '../models/booking_model.dart';
import '../controllers/booking_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';

class BookingScreen extends StatefulWidget {
  final HotelModel hotel;

  const BookingScreen({super.key, required this.hotel});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _bookingController = BookingController();
  final _authController = AuthController();
  
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  int _rooms = 1;
  bool _isLoading = false;

  double get _totalPrice {
    if (_checkInDate == null || _checkOutDate == null) return 0;
    final nights = _checkOutDate!.difference(_checkInDate!).inDays;
    if (nights <= 0) return 0;
    return nights * widget.hotel.pricePerNight * _rooms;
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner vos dates'), backgroundColor: AppColors.warning),
      );
      return;
    }

    if (_checkOutDate!.difference(_checkInDate!).inDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de départ doit être après la date d\'arrivée'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userId = await _authController.getCurrentUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final userDetails = await _authController.getCurrentUserDetails();

    final dateFormat = DateFormat('yyyy-MM-dd');
    final booking = BookingModel(
      userId: userId,
      userName: userDetails['name'] ?? 'Inconnu',
      userEmail: userDetails['email'] ?? '',
      hotelId: widget.hotel.id!,
      hotelName: widget.hotel.name,
      hotelCity: widget.hotel.city,
      checkIn: dateFormat.format(_checkInDate!),
      checkOut: dateFormat.format(_checkOutDate!),
      guests: _guests,
      rooms: _rooms,
      totalPrice: _totalPrice,
      status: 'Confirmée',
    );

    final success = await _bookingController.createBooking(booking);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 64),
              const SizedBox(height: 16),
              const Text('Réservation Confirmée !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Votre réservation a été effectuée avec succès.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Retour à l\'accueil',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildCounter(String label, int value, VoidCallback onDecrement, VoidCallback onIncrement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 1 ? onDecrement : null,
              color: AppColors.primaryColor,
            ),
            Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrement,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Réserver')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.hotel.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(widget.hotel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(widget.hotel.city),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Vos dates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Arrivée - Départ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            _checkInDate != null && _checkOutDate != null
                                ? '${dateFormat.format(_checkInDate!)} - ${dateFormat.format(_checkOutDate!)}'
                                : 'Sélectionner des dates',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Voyageurs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildCounter('Personnes', _guests, () => setState(() => _guests--), () => setState(() => _guests++)),
                  const Divider(),
                  _buildCounter('Chambres', _rooms, () => setState(() => _rooms--), () => setState(() => _rooms++)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Détails du prix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.hotel.pricePerNight} DH x ${_rooms} chambre(s) x ${_checkInDate != null && _checkOutDate != null ? _checkOutDate!.difference(_checkInDate!).inDays : 0} nuit(s)'),
                Text('${_totalPrice} DH'),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  '${_totalPrice} DH',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Confirmer la réservation',
              onPressed: _confirmBooking,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
