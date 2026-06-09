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

  int _totalHotels = 0;
  int _totalBookings = 0;
  int _totalFavorites = 0;
  double _totalRevenue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    final userId = await _authController.getCurrentUserId();
    
    _totalHotels = await _hotelController.getTotalHotelsCount();
    _totalBookings = await _bookingController.getTotalBookingsCount();
    
    if (userId != null) {
      _totalFavorites = await _favoriteController.getTotalFavoritesCount(userId);
      _totalRevenue = await _bookingController.getTotalBookingAmount(userId);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color), // Reduced icon size
            const SizedBox(height: 8),
            FittedBox( // Prevents vertical overflow for large numbers
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox( // Prevents vertical overflow for long text
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        automaticallyImplyLeading: false, // Inside bottom nav
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SafeArea(
                child: SingleChildScrollView( // Responsive scroll
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
                        childAspectRatio: 1.1, // Adjusted ratio to give more height and prevent overflow
                        children: [
                          _buildStatCard('Total Hôtels', _totalHotels.toString(), Icons.hotel, Colors.blue),
                          _buildStatCard('Total Réservations', _totalBookings.toString(), Icons.book_online, Colors.green),
                          _buildStatCard('Mes Favoris', _totalFavorites.toString(), Icons.favorite, Colors.red),
                          _buildStatCard('Revenus globaux', '${_totalRevenue.toStringAsFixed(0)} DH', Icons.attach_money, Colors.orange),
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
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminHotelScreen()),
                          );
                          _loadDashboardData();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
