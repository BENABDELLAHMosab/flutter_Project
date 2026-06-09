import 'package:flutter/material.dart';
import '../controllers/hotel_controller.dart';
import '../controllers/booking_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/favorite_controller.dart';
import '../utils/app_colors.dart';
import 'admin_hotel_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _hotelController = HotelController();
  final _bookingController = BookingController();
  final _favoriteController = FavoriteController();
  final _authController = AuthController();

  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = await _authController.getCurrentUserId();
    if (mounted) {
      setState(() {
        _userId = userId;
      });
    }
  }

  Widget _buildStatCard(String title, Stream<num> stream, IconData icon, Color color, {bool isCurrency = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            StreamBuilder<num>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                final value = snapshot.data ?? 0;
                final displayValue = isCurrency ? '${value.toStringAsFixed(0)} DH' : value.toString();
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    displayValue,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        automaticallyImplyLeading: false, // Inside bottom nav
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  _buildStatCard(
                    'Total Hôtels', 
                    _hotelController.getHotelsStream().map((list) => list.length), 
                    Icons.hotel, Colors.blue
                  ),
                  _buildStatCard(
                    'Total Réservations', 
                    _bookingController.getTotalBookingsCountStream(), 
                    Icons.book_online, Colors.green
                  ),
                  _buildStatCard(
                    'Mes Favoris', 
                    _favoriteController.getTotalFavoritesCountStream(_userId!), 
                    Icons.favorite, Colors.red
                  ),
                  _buildStatCard(
                    'Revenus globaux', 
                    _bookingController.getTotalBookingAmountStream(), 
                    Icons.attach_money, Colors.orange,
                    isCurrency: true
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Administration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.settings_applications),
                title: const Text('Gestion CRUD des hôtels'),
                trailing: const Icon(Icons.chevron_right),
                tileColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminHotelScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
