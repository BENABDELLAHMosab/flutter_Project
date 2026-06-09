import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_colors.dart';
import 'booking_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  final HotelModel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final _favoriteController = FavoriteController();
  final _authController = AuthController();
  bool _isFavorite = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    _userId = await _authController.getCurrentUserId();
    if (_userId != null && widget.hotel.id != null) {
      final isFav = await _favoriteController.isFavorite(_userId!, widget.hotel.id!);
      if (mounted) {
        setState(() => _isFavorite = isFav);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null || widget.hotel.id == null) return;
    
    final newState = await _favoriteController.toggleFavorite(_userId!, widget.hotel.id!);
    setState(() => _isFavorite = newState);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newState ? 'Ajouté aux favoris' : 'Retiré des favoris'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildFacility(IconData icon, String text, bool isAvailable) {
    if (!isAvailable) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppColors.accentColor : Colors.grey,
                  ),
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.hotel.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.hotel,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.hotel.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            widget.hotel.rating.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.hotel.city,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.hotel.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Équipements',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFacility(Icons.wifi, 'Wi-Fi gratuit', widget.hotel.hasWifi),
                  _buildFacility(Icons.local_parking, 'Parking', widget.hotel.hasParking),
                  _buildFacility(Icons.pool, 'Piscine', widget.hotel.hasPool),
                  _buildFacility(Icons.restaurant, 'Restaurant', widget.hotel.hasRestaurant),
                  _buildFacility(Icons.ac_unit, 'Climatisation', widget.hotel.hasAC),
                  const SizedBox(height: 80), // padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prix', style: TextStyle(color: Colors.grey)),
                Text(
                  '${widget.hotel.pricePerNight} DH',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const Text('/ nuit'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(hotel: widget.hotel),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Réserver', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
