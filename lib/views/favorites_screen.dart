import 'package:flutter/material.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/hotel_model.dart';
import '../widgets/hotel_card.dart';
import '../widgets/empty_state.dart';
import 'hotel_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoriteController = FavoriteController();
  final _authController = AuthController();
  List<HotelModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final userId = await _authController.getCurrentUserId();
    if (userId != null) {
      final favorites = await _favoriteController.getUserFavorites(userId);
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        automaticallyImplyLeading: false, // In bottom nav
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const EmptyState(
                  icon: Icons.favorite_border,
                  message: 'Aucun favori',
                  subMessage: 'Sauvegardez vos hôtels préférés.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final hotel = _favorites[index];
                    return HotelCard(
                      hotel: hotel,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelDetailScreen(hotel: hotel),
                          ),
                        );
                        // Reload favorites when coming back
                        _loadFavorites();
                      },
                    );
                  },
                ),
    );
  }
}
