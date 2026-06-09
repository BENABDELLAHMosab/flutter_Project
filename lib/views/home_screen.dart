import 'package:flutter/material.dart';
import '../controllers/hotel_controller.dart';
import '../models/hotel_model.dart';
import '../widgets/hotel_card.dart';
import '../widgets/section_title.dart';
import '../widgets/empty_state.dart';
import '../utils/app_colors.dart';
import 'hotel_detail_screen.dart';
import 'hotel_list_screen.dart';
import 'favorites_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const FavoritesScreen(),
    const BookingHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Favoris'),
          NavigationDestination(icon: Icon(Icons.book_online_outlined), selectedIcon: Icon(Icons.book_online), label: 'Réservations'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _hotelController = HotelController();
  final _searchController = TextEditingController();
  List<HotelModel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHotels() async {
    setState(() => _isLoading = true);
    final hotels = await _hotelController.getHotels();
    if (mounted) {
      setState(() {
        _hotels = hotels;
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelListScreen(searchQuery: query),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadHotels,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Découvrez',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const Text(
                        'Des hôtels exceptionnels',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                onSubmitted: _onSearchSubmit,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom ou ville...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HotelListScreen()),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 24),
              SectionTitle(
                title: 'Hôtels Recommandés',
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HotelListScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_hotels.isEmpty)
                const EmptyState(
                  icon: Icons.hotel_rounded,
                  message: 'Aucun hôtel disponible',
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _hotels.length > 5 ? 5 : _hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _hotels[index];
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
