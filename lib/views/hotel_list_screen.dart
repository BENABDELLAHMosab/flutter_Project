import 'package:flutter/material.dart';
import '../controllers/hotel_controller.dart';
import '../models/hotel_model.dart';
import '../widgets/hotel_card.dart';
import '../widgets/empty_state.dart';
import 'hotel_detail_screen.dart';

class HotelListScreen extends StatefulWidget {
  final String? searchQuery;
  final String? initialQuery;

  const HotelListScreen({super.key, this.searchQuery, this.initialQuery});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  final _hotelController = HotelController();
  final _searchController = TextEditingController();
  
  String _currentQuery = '';
  double? _maxPrice;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    final query = widget.initialQuery ?? widget.searchQuery;
    if (query != null && query.isNotEmpty) {
      _searchController.text = query;
      _currentQuery = query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _currentQuery = query.trim();
    });
  }

  Stream<List<HotelModel>> _getHotelsStream() {
    if (_currentQuery.isNotEmpty) {
      return _hotelController.searchHotelsStream(_currentQuery);
    } else if (_maxPrice != null || _minRating != null) {
      return _hotelController.filterHotelsStream(
        maxPrice: _maxPrice,
        minRating: _minRating,
      );
    } else {
      return _hotelController.getHotelsStream();
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double tempMaxPrice = _maxPrice ?? 2000;
        double tempMinRating = _minRating ?? 1.0;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filtres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Text('Prix maximum par nuit: ${tempMaxPrice.toInt()} DH'),
                  Slider(
                    value: tempMaxPrice,
                    min: 100,
                    max: 5000,
                    divisions: 49,
                    label: tempMaxPrice.round().toString(),
                    onChanged: (value) {
                      setModalState(() => tempMaxPrice = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Note minimum: ${tempMinRating.toStringAsFixed(1)}'),
                  Slider(
                    value: tempMinRating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    label: tempMinRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setModalState(() => tempMinRating = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _maxPrice = null;
                              _minRating = null;
                              _currentQuery = '';
                              _searchController.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _maxPrice = tempMaxPrice;
                              _minRating = tempMinRating;
                              _currentQuery = '';
                              _searchController.clear();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hôtels'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: _showFilterDialog,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<HotelModel>>(
        stream: _getHotelsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement."));
          }
          final hotels = snapshot.data ?? [];

          if (hotels.isEmpty) {
            return const EmptyState(
              icon: Icons.search_off,
              message: 'Aucun hôtel trouvé',
              subMessage: 'Essayez de modifier vos filtres',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hotels.length,
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
    );
  }
}
