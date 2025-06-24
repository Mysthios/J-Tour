import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/place/place_detail.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:intl/intl.dart';

const Color kPrimaryBlue = Color(0xFF0072BC);

class ExploreDestinationCard extends ConsumerWidget {
  final Place place;

  const ExploreDestinationCard({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    // REACTIVE: Listen ke perubahan state dari provider
    final placesState = ref.watch(placesProvider);
    
    // Cari place dengan ID yang sama dari provider state yang terbaru
    final currentPlace = placesState.places.where((p) => p.id == place.id).firstOrNull ?? place;

    // Debug print untuk melihat perubahan rating
    if (currentPlace.rating != place.rating) {
      print('=== EXPLORE RATING UPDATE DETECTED ===');
      print('Place: ${currentPlace.name}');
      print('Original rating: ${place.rating}');
      print('Updated rating: ${currentPlace.rating}');
      print('=== END EXPLORE RATING UPDATE ===');
    }

    return GestureDetector(
      onTap: () async {
        print('=== EXPLORE CARD TAP DEBUG ===');
        print('Card tapped: ${currentPlace.name}');
        print('Place ID: ${currentPlace.id}');
        print('Current rating: ${currentPlace.rating}');
        print('=== END EXPLORE CARD TAP DEBUG ===');

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
            // Container untuk gambar
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 140,
                maxHeight: 200, // Batas maksimal tinggi
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildImage(currentPlace),
              ),
            ),
            // Informasi tempat
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
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          currentPlace.location,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating - REACTIVE: akan update otomatis saat rating berubah
                  _buildRatingSection(currentPlace),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Separate method untuk rating section dengan animasi (sama seperti PlaceCard)
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

  // Method untuk membangun widget gambar yang tepat
  Widget _buildImage(Place currentPlace) {
    // Debug print untuk melihat nilai image dan isLocalImage
    print('=== EXPLORE IMAGE DEBUG ===');
    print('Image path: ${currentPlace.image}');
    print('Is Local Image: ${currentPlace.isLocalImage}');
    print('=== END EXPLORE IMAGE DEBUG ===');

    // Jika gambar adalah URL (dari API)
    if (!currentPlace.isLocalImage && _isValidUrl(currentPlace.image)) {
      return Image.network(
        currentPlace.image,
        width: double.infinity,
        fit: BoxFit.fitWidth, // Fit width agar gambar tidak terpotong horizontal
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
        fit: BoxFit.fitWidth, // Fit width agar gambar tidak terpotong horizontal
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
        fit: BoxFit.fitWidth, // Fit width agar gambar tidak terpotong horizontal
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

  // Helper method untuk validasi URL
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