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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        automaticallyImplyLeading: false, // In bottom nav
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<HotelModel>>(
              stream: _favoriteController.getUserFavoritesStream(_userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement."));
                }
                
                final favorites = snapshot.data ?? [];
                
                if (favorites.isEmpty) {
                  return const EmptyState(
                    icon: Icons.favorite_border,
                    message: 'Aucun favori',
                    subMessage: 'Sauvegardez vos hôtels préférés.',
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final hotel = favorites[index];
                    return HotelCard(
                      hotel: hotel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HotelDetailScreen(hotel: hotel),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
