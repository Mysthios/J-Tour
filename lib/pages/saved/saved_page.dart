import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:j_tour/pages/place/place_detail.dart';
import 'package:j_tour/providers/saved_provider.dart';
import 'package:j_tour/models/place_model.dart';

// Provider untuk sort option
final savedSortProvider = StateProvider<String>((ref) => 'newest');

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(savedSearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshSavedPlaces() async {
    final userId = ref.read(userIdProvider);
    if (userId.isNotEmpty) {
      await ref.read(savedPlaceProvider.notifier).refresh(userId);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(savedSearchQueryProvider.notifier).state = '';
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Urutkan berdasarkan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('newest', 'Terbaru'),
            _buildSortOption('oldest', 'Terlama'),
            _buildSortOption('name', 'Nama A-Z'),
            _buildSortOption('rating', 'Rating Tertinggi'),
            _buildSortOption('price_low', 'Harga Terendah'),
            _buildSortOption('price_high', 'Harga Tertinggi'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String value, String label) {
    final currentSort = ref.watch(savedSortProvider);
    return RadioListTile<String>(
      value: value,
      groupValue: currentSort,
      onChanged: (newValue) {
        if (newValue != null) {
          ref.read(savedSortProvider.notifier).state = newValue;
          Navigator.pop(context);
        }
      },
      title: Text(label),
      dense: true,
    );
  }

  List<Place> _getSortedPlaces(List<Place> places) {
    final sortType = ref.watch(savedSortProvider);
    final sortedPlaces = List<Place>.from(places);

    switch (sortType) {
      case 'oldest':
        sortedPlaces.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'name':
        sortedPlaces.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'rating':
        sortedPlaces.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'price_low':
        sortedPlaces.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        sortedPlaces.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
      default:
        sortedPlaces.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return sortedPlaces;
  }

  String _getSortLabel() {
    final sortType = ref.watch(savedSortProvider);
    switch (sortType) {
      case 'oldest':
        return 'Terlama';
      case 'name':
        return 'Nama';
      case 'rating':
        return 'Rating';
      case 'price_low':
        return 'Harga ↑';
      case 'price_high':
        return 'Harga ↓';
      case 'newest':
      default:
        return 'Terbaru';
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedState = ref.watch(savedPlaceProvider);
    final filteredPlaces = ref.watch(filteredSavedPlacesProvider);
    final searchQuery = ref.watch(savedSearchQueryProvider);
    final userId = ref.watch(userIdProvider);

    // Apply sorting to filtered places
    final sortedFilteredPlaces = _getSortedPlaces(filteredPlaces);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        // Title di tengah seperti explore
        title: const Text(
          "Tersimpan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _refreshSavedPlaces,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row untuk Search dan Sort - persis seperti explore
            Row(
              children: [
                // Search bar
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Cari tempat wisata...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: const Icon(Icons.clear, color: Colors.grey, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Sort button - sama seperti explore
                GestureDetector(
                  onTap: _showSortDialog,
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort, color: Colors.grey, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          _getSortLabel(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informasi jumlah destinasi - persis seperti explore
            if (savedState.hasValue) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    searchQuery.isEmpty 
                        ? "${savedState.value!.count} Destinasi Tersimpan"
                        : "Hasil pencarian: ${sortedFilteredPlaces.length} destinasi",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Error message
            if (savedState.hasValue && savedState.value!.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        savedState.value!.error!,
                        style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(savedPlaceProvider.notifier).clearError(),
                      child: const Text('Tutup', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: savedState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorState(error.toString()),
                data: (state) {
                  if (state.places.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  if (sortedFilteredPlaces.isEmpty && searchQuery.isNotEmpty) {
                    return _buildNoSearchResults(searchQuery);
                  }
                  
                  return RefreshIndicator(
                    onRefresh: _refreshSavedPlaces,
                    child: ListView.builder(
                      itemCount: sortedFilteredPlaces.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (context, index) {
                        final place = sortedFilteredPlaces[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SavedDestinationCard(
                            place: place,
                            userId: userId,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Belum ada tempat yang disimpan",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulai simpan tempat favorit Anda",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Tidak ada hasil untuk \"$query\"",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Coba kata kunci yang berbeda",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearSearch,
            child: const Text('Hapus Pencarian'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Terjadi kesalahan",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshSavedPlaces,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

const Color kPrimaryBlue = Color(0xFF0072BC);

// Card untuk saved page yang mirip dengan ExploreDestinationCard
class SavedDestinationCard extends ConsumerWidget {
  final Place place;
  final String userId;

  const SavedDestinationCard({
    super.key,
    required this.place,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    // REACTIVE: Listen ke perubahan state dari provider (sama seperti ExploreDestinationCard)
    final savedState = ref.watch(savedPlaceProvider);
    
    // Cari place dengan ID yang sama dari provider state yang terbaru
    final currentPlace = savedState.hasValue 
        ? savedState.value!.places.where((p) => p.id == place.id).firstOrNull ?? place
        : place;

    return GestureDetector(
      onTap: () async {
        print('=== SAVED CARD TAP DEBUG ===');
        print('Card tapped: ${currentPlace.name}');
        print('Place ID: ${currentPlace.id}');
        print('Current rating: ${currentPlace.rating}');
        print('=== END SAVED CARD TAP DEBUG ===');

        try {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailPage(place: currentPlace),
              ),
            );
          }
        } catch (e) {
          print('Error navigating to place detail: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Container untuk gambar - sama seperti ExploreDestinationCard
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 140,
                maxHeight: 200,
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: _buildImage(currentPlace),
                  ),
                  // Bookmark button - selalu aktif untuk saved page
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(savedPlaceProvider.notifier).toggleSaved(userId, currentPlace);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          size: 18,
                          color: kPrimaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Informasi tempat - sama seperti ExploreDestinationCard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentPlace.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            formatter.format(currentPlace.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kPrimaryBlue,
                            ),
                          ),
                          const Text(
                            '/Orang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          currentPlace.location,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating - sama seperti ExploreDestinationCard dengan animasi
                  _buildRatingSection(currentPlace),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rating section dengan animasi - sama seperti ExploreDestinationCard
  Widget _buildRatingSection(Place currentPlace) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey(currentPlace.rating),
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: Colors.amber[600],
          ),
          const SizedBox(width: 4),
          Text(
            '${(currentPlace.rating ?? 0.0).toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (currentPlace.rating != null && currentPlace.rating! > 0)
            Text(
              ' (${_getRatingText(currentPlace.rating!)})',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  // Image builder - sama seperti ExploreDestinationCard
  Widget _buildImage(Place currentPlace) {
    print('=== SAVED IMAGE DEBUG ===');
    print('Image path: ${currentPlace.image}');
    print('Is Local Image: ${currentPlace.isLocalImage}');
    print('=== END SAVED IMAGE DEBUG ===');

    // Jika gambar adalah URL (dari API)
    if (!currentPlace.isLocalImage && _isValidUrl(currentPlace.image)) {
      return Image.network(
        currentPlace.image,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 140,
            width: double.infinity,
            color: Colors.grey[300],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('Network image error: $error');
          return Container(
            height: 140,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text('Gagal memuat gambar', 
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      );
    }
    // Jika gambar adalah file lokal
    else if (currentPlace.isLocalImage && currentPlace.image.isNotEmpty) {
      return Image.file(
        File(currentPlace.image),
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          print('File image error: $error');
          return Container(
            height: 140,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text('File tidak ditemukan', 
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      );
    }
    // Jika gambar adalah asset
    else if (!currentPlace.isLocalImage && !_isValidUrl(currentPlace.image) && currentPlace.image.isNotEmpty) {
      return Image.asset(
        currentPlace.image,
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (context, error, stackTrace) {
          print('Asset image error: $error');
          return Container(
            height: 140,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                SizedBox(height: 8),
                Text('Asset tidak ditemukan', 
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      );
    }
    // Default fallback
    else {
      return Container(
        height: 140,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text('Tidak ada gambar', 
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }
  }

  // Helper methods - sama seperti ExploreDestinationCard
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  String _getRatingText(double rating) {
    if (rating >= 5.0) return 'Sangat Bagus';
    if (rating >= 4.5) return 'Sangat Baik';
    if (rating >= 4.0) return 'Baik';
    if (rating >= 3.5) return 'Cukup';
    if (rating >= 3.0) return 'Biasa';
    return 'Kurang';
  }
}