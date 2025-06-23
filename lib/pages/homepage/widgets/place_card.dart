import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/place/place_detail.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:intl/intl.dart';

class PlaceCard extends ConsumerWidget {
  final Place place;

  const PlaceCard({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth * 0.32;

    // Helper to format currency
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );

    // REACTIVE: Listen ke perubahan state dari provider
    final placesState = ref.watch(placesProvider);
    
    // Cari place dengan ID yang sama dari provider state yang terbaru
    final currentPlace = placesState.places.where((p) => p.id == place.id).firstOrNull ?? place;

    // Debug print untuk melihat perubahan rating
    if (currentPlace.rating != place.rating) {
      print('=== RATING UPDATE DETECTED ===');
      print('Place: ${currentPlace.name}');
      print('Original rating: ${place.rating}');
      print('Updated rating: ${currentPlace.rating}');
      print('=== END RATING UPDATE ===');
    }

    return GestureDetector(
      onTap: () async {
        print('=== PLACE CARD TAP DEBUG ===');
        print('Card tapped: ${currentPlace.name}');
        print('Place ID: ${currentPlace.id}');
        print('Current rating: ${currentPlace.rating}');
        print('=== END PLACE CARD TAP DEBUG ===');

        try {
          // Gunakan data terbaru dari provider state
          final latestPlace = ref.read(placesProvider.notifier).getPlaceWithLatestRating(currentPlace.id);

          if (context.mounted) {
            if (latestPlace != null) {
              print('DEBUG: Using latest place data: ${latestPlace.name} (Rating: ${latestPlace.rating})');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailPage(place: latestPlace),
                ),
              );
            } else {
              print('DEBUG: Latest place not found, using current place data');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailPage(place: currentPlace),
                ),
              );
            }
          }
        } catch (e) {
          print('Error fetching latest place data: $e');
          if (context.mounted) {
            // Fallback to current place data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailPage(place: currentPlace),
              ),
            );
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(
                width: screenWidth * 0.35,
                height: cardHeight,
                child: _buildImage(currentPlace),
              ),
            ),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Place Name
                        Text(
                          currentPlace.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                currentPlace.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Rating - REACTIVE: akan update otomatis saat rating berubah
                        _buildRatingSection(currentPlace),
                      ],
                    ),
                    
                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentPlace.price != null && currentPlace.price! > 0)
                          Text(
                            currencyFormatter.format(currentPlace.price!),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0072BC),
                            ),
                          )
                        else
                          Text(
                            'Gratis',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[600],
                            ),
                          ),
                        
                        // Category Tag (if available)
                        if (currentPlace.category != null && currentPlace.category!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0072BC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              currentPlace.category!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0072BC),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Separate method untuk rating section dengan animasi
  Widget _buildRatingSection(Place currentPlace) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey(currentPlace.rating), // Key untuk trigger animasi
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
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (currentPlace.rating != null && currentPlace.rating! > 0)
            Text(
              ' (${_getRatingText(currentPlace.rating!)})',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(Place currentPlace) {
    // Debug print untuk melihat nilai image dan isLocalImage
    print('=== PLACE CARD IMAGE DEBUG ===');
    print('Image path: ${currentPlace.image}');
    print('Is Local Image: ${currentPlace.isLocalImage}');
    print('=== END PLACE CARD IMAGE DEBUG ===');

    // Jika gambar adalah URL (dari API)
    if (!currentPlace.isLocalImage && _isValidUrl(currentPlace.image)) {
      return Image.network(
        currentPlace.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingImage();
        },
        errorBuilder: (context, error, stackTrace) {
          print('Network image error: $error');
          return _buildErrorImage();
        },
      );
    }
    // Jika gambar adalah file lokal
    else if (currentPlace.isLocalImage && currentPlace.image.isNotEmpty) {
      return Image.file(
        File(currentPlace.image),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('File image error: $error');
          return _buildErrorImage();
        },
      );
    }
    // Jika gambar adalah asset
    else if (!currentPlace.isLocalImage && !_isValidUrl(currentPlace.image) && currentPlace.image.isNotEmpty) {
      return Image.asset(
        currentPlace.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Asset image error: $error');
          return _buildErrorImage();
        },
      );
    }
    // Default fallback
    else {
      return _buildErrorImage();
    }
  }

  Widget _buildLoadingImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0072BC)),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5.0) return 'Sangat Bagus';
    if (rating >= 4.5) return 'Sangat Baik';
    if (rating >= 4.0) return 'Baik';
    if (rating >= 3.5) return 'Cukup';
    if (rating >= 3.0) return 'Biasa';
    return 'Kurang';
  }

  // Helper method untuk validasi URL
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}