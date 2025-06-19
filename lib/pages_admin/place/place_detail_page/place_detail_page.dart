// pages/place/place_detail_page.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:j_tour/pages/map/map_page.dart';
import 'package:j_tour/pages/place/reviews_page.dart';
import 'package:j_tour/pages_admin/place/edit_place/edit_place_page.dart';
import 'widgets/place_image_carousel.dart';
import 'widgets/place_info_card.dart';
import 'widgets/place_description_section.dart';
import 'widgets/place_facilities_section.dart';
import 'widgets/place_action_buttons.dart';

class PlaceDetail extends ConsumerStatefulWidget {
  final Place place;

  const PlaceDetail({
    super.key,
    required this.place,
  });

  @override
  ConsumerState<PlaceDetail> createState() => _PlaceDetailState();
}

class _PlaceDetailState extends ConsumerState<PlaceDetail> {
  late Place _currentPlace;
  // TAMBAHAN: Key unik untuk memaksa rebuild widget gambar
  Key _imageCarouselKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentPlace = widget.place;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentPlace();
  }

  void _updateCurrentPlace() async {
    final updatedPlace = await ref.read(placesProvider.notifier).getPlaceById(widget.place.id);
    if (updatedPlace != null && mounted) {
      setState(() {
        _currentPlace = updatedPlace;
        // PERBAIKAN: Generate key baru untuk memaksa rebuild gambar
        _imageCarouselKey = UniqueKey();
      });
    }
  }

  void _navigateToEditPlace() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPlacePage(place: _currentPlace),
      ),
    );

    if (result == true) {
      // PERBAIKAN: Tambahkan delay untuk memastikan data tersimpan
      await Future.delayed(const Duration(milliseconds: 500));
      await _forceRefreshCurrentPlace();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data tempat wisata berhasil diperbarui'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _forceRefreshCurrentPlace() async {
    print('=== FORCE REFRESH CURRENT PLACE ===');
    
    // PERBAIKAN: Clear cache gambar jika perlu
    if (_currentPlace.image?.isNotEmpty ?? false) {
      try {
        PaintingBinding.instance.imageCache.clear();
        print('Image cache cleared');
      } catch (e) {
        print('Error clearing image cache: $e');
      }
    }
    
    final refreshedPlace = await ref.read(placesProvider.notifier).getPlaceById(_currentPlace.id);
    
    if (refreshedPlace != null && mounted) {
      print('Place refreshed:');
      print('- Old image: ${_currentPlace.image}');
      print('- New image: ${refreshedPlace.image}');
      print('- Old isLocalImage: ${_currentPlace.isLocalImage}');
      print('- New isLocalImage: ${refreshedPlace.isLocalImage}');
      
      setState(() {
        _currentPlace = refreshedPlace;
        // PERBAIKAN: Generate key baru untuk memaksa rebuild komponen gambar
        _imageCarouselKey = UniqueKey();
      });
      
      // PERBAIKAN: Trigger rebuild provider juga
      ref.invalidate(placesProvider);
    }
  }

  void _deletePlace() async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    _showLoadingDialog();
    final success = await ref.read(placesProvider.notifier).deletePlace(_currentPlace.id);
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tempat wisata berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close detail page
      } else {
        final error = ref.read(placesErrorProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal menghapus tempat wisata'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus tempat wisata ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _navigateToReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsPage(place: _currentPlace),
      ),
    );
  }

  void _navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(place: _currentPlace),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // PERBAIKAN: Gunakan key unik untuk memaksa rebuild
          PlaceImageCarousel(
            key: _imageCarouselKey,
            place: _currentPlace,
            onBack: () => Navigator.pop(context),
            onEdit: _navigateToEditPlace,
            onDelete: _deletePlace,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlaceInfoCard(
                    place: _currentPlace,
                    onReviewsTap: _navigateToReviews,
                  ),
                  PlaceDescriptionSection(place: _currentPlace),
                  PlaceFacilitiesSection(place: _currentPlace),
                  const SizedBox(height: 24),
                  PlaceActionButtons(
                    onDirections: _navigateToMap,
                    onEdit: _navigateToEditPlace,
                    onDelete: _deletePlace,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}