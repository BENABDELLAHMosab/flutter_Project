import 'package:flutter/material.dart';
import '../controllers/hotel_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/hotel_model.dart';
import '../widgets/hotel_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/section_title.dart';
import '../utils/app_colors.dart';
import 'hotel_list_screen.dart';
import 'hotel_detail_screen.dart';
import 'favorites_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'dashboard_screen.dart';
import 'admin_hotel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _userRole = 'client';
  final _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _authController.getCurrentUserRole();
    if (mounted) {
      setState(() {
        _userRole = role ?? 'client';
      });
    }
  }

  Widget _buildBody() {
    if (_userRole == 'admin') {
      switch (_currentIndex) {
        case 0: return const _HomeContent();
        case 1: return const DashboardScreen();
        case 2: return const AdminHotelScreen();
        case 3: return const ProfileScreen();
        default: return const _HomeContent();
      }
    } else {
      switch (_currentIndex) {
        case 0: return const _HomeContent();
        case 1: return const FavoritesScreen();
        case 2: return const BookingHistoryScreen();
        case 3: return const ProfileScreen();
        default: return const _HomeContent();
      }
    }
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    if (_userRole == 'admin') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Gérer hôtels'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
        BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Réservations'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Avoids overlapping
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _buildNavItems(),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    if (_searchController.text.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HotelListScreen(initialQuery: _searchController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Prevents overflow on the title
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Découvrez',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const Text(
                        'Des hôtels exceptionnels',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(Icons.person, color: Colors.white),
                )
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un hôtel, une ville...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).hintColor,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) {
                      // Optionnel: filtrage en temps réel
                    },
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HotelListScreen()),
                      );
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            SectionTitle(
              title: 'Hôtels Populaires',
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HotelListScreen()),
                );
              },
            ),
            StreamBuilder<List<HotelModel>>(
              stream: _hotelController.getHotelsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun hôtel trouvé."));
                }
                
                final hotels = snapshot.data!;
                final displayCount = hotels.length > 5 ? 5 : hotels.length;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayCount,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
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
          ],
        ),
      ),
    );
  }
}
