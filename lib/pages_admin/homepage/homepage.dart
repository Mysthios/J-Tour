import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:j_tour/pages_admin/homepage/widgets/wisata_anda_card.dart';
import 'package:j_tour/pages_admin/homepage/widgets/weather_header.dart';
import 'package:j_tour/pages_admin/place/edit_place_page.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const WeatherHeader(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Wisata Anda",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.blue,
                  ),
                  onPressed: () => _showAddPlaceDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200, // Increased height for better visibility
              child: places.isEmpty
                  ? const Center(
                      child: Text('Tidak ada tempat wisata'),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        return WisataAndaCard(place: places[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlaceDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPlaceOptions(BuildContext context, Place place) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Wisata'),
              onTap: () {
                Navigator.pop(context);
                _showEditPlaceDialog(context, place);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Wisata',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, place);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Place place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${place.name}?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              ref.read(placesNotifierProvider.notifier).deletePlace(place.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${place.name} telah dihapus')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<void> _showAddPlaceDialog(BuildContext context) async {
    // Create a new empty place with default values
    final newPlace = Place(
      name: 'Tempat Wisata Baru',
      location: 'Lokasi',
      price: 15000,
      rating: 4.5,
      image: 'assets/images/papuma.jpeg', // Default placeholder image
      isLocalImage: false,
      description: 'Deskripsi tempat wisata',
      weekdaysHours: '06:00 - 17:00',
      weekendHours: '06:00 - 18:00',
      weekendPrice: 25000,
      facilities: ['Area Parkir', 'Toilet'],
      reviewCount: 0,
      additionalImages: [], // Empty list for additional images
    );

    // Navigate to the edit page with the new place
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlacePage(place: newPlace),
      ),
    );

    // If we return with a result, the place was saved
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tempat wisata berhasil ditambahkan')),
      );
    }
  }

  Future<void> _showEditPlaceDialog(BuildContext context, Place place) async {
    // Navigate to the edit page with the existing place
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlacePage(place: place),
      ),
    );

    // If we return with a result, the place was updated
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tempat wisata berhasil diperbarui')),
      );
    }
  }
}
