import 'package:flutter/material.dart';
import '../controllers/hotel_controller.dart';
import '../models/hotel_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class AdminHotelScreen extends StatefulWidget {
  const AdminHotelScreen({super.key});

  @override
  State<AdminHotelScreen> createState() => _AdminHotelScreenState();
}

class _AdminHotelScreenState extends State<AdminHotelScreen> {
  final _hotelController = HotelController();
  List<HotelModel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHotels();
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

  Future<void> _deleteHotel(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'hôtel ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _hotelController.deleteHotel(id);
      if (success) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hôtel supprimé')));
        _loadHotels();
      }
    }
  }

  void _showHotelForm([HotelModel? hotel]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: HotelFormSheet(
          hotel: hotel,
          onSaved: () {
            Navigator.pop(context);
            _loadHotels();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hotel == null ? 'Hôtel ajouté' : 'Hôtel modifié')));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Hôtels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showHotelForm(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _hotels.length,
              itemBuilder: (context, index) {
                final hotel = _hotels[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(hotel.imageUrl)),
                  title: Text(hotel.name),
                  subtitle: Text(hotel.city),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showHotelForm(hotel)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteHotel(hotel.id!)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class HotelFormSheet extends StatefulWidget {
  final HotelModel? hotel;
  final VoidCallback onSaved;

  const HotelFormSheet({super.key, this.hotel, required this.onSaved});

  @override
  State<HotelFormSheet> createState() => _HotelFormSheetState();
}

class _HotelFormSheetState extends State<HotelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _descController;
  final _hotelController = HotelController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hotel?.name);
    _cityController = TextEditingController(text: widget.hotel?.city);
    _priceController = TextEditingController(text: widget.hotel?.pricePerNight.toString());
    _imageUrlController = TextEditingController(text: widget.hotel?.imageUrl ?? 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800');
    _descController = TextEditingController(text: widget.hotel?.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final hotel = HotelModel(
        id: widget.hotel?.id,
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        address: widget.hotel?.address ?? 'Adresse par défaut',
        description: _descController.text.trim().isEmpty ? 'Pas de description' : _descController.text.trim(),
        pricePerNight: double.parse(_priceController.text.trim()),
        rating: widget.hotel?.rating ?? 4.0,
        imageUrl: _imageUrlController.text.trim(),
        hasWifi: widget.hotel?.hasWifi ?? true,
        hasParking: widget.hotel?.hasParking ?? true,
        hasPool: widget.hotel?.hasPool ?? false,
        hasRestaurant: widget.hotel?.hasRestaurant ?? true,
        hasAC: widget.hotel?.hasAC ?? true,
      );

      if (widget.hotel == null) {
        await _hotelController.addHotel(hotel);
      } else {
        await _hotelController.updateHotel(hotel);
      }
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.hotel == null ? 'Ajouter un hôtel' : 'Modifier l\'hôtel', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Nom', hint: 'Nom', prefixIcon: Icons.hotel, controller: _nameController, validator: Validators.validateRequired),
            CustomTextField(label: 'Ville', hint: 'Ville', prefixIcon: Icons.location_city, controller: _cityController, validator: Validators.validateRequired),
            CustomTextField(label: 'Prix/nuit', hint: 'Ex: 500', prefixIcon: Icons.attach_money, controller: _priceController, validator: Validators.validatePrice, keyboardType: TextInputType.number),
            CustomTextField(label: 'URL Image', hint: 'https://...', prefixIcon: Icons.image, controller: _imageUrlController, validator: Validators.validateRequired),
            CustomTextField(label: 'Description', hint: 'Description...', prefixIcon: Icons.description, controller: _descController),
            const SizedBox(height: 16),
            CustomButton(text: 'Enregistrer', onPressed: _save, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
