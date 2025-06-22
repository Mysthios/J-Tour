import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages_admin/place/place_detail_page/place_detail_page.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:intl/intl.dart';

class WisataAndaCard extends ConsumerWidget {
  final Place place;
  const WisataAndaCard({super.key, required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Helper to format currency
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );

    String priceText = currencyFormatter.format(place.price);

    return Container(
      width: 330,
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              print('=== CARD TAP DEBUG ===');
              print('Card tapped: ${place.name}');
              print('Place ID: ${place.id}');
              print('=== END CARD TAP DEBUG ===');

              try {
                final latestPlace = await ref.read(placesProvider.notifier).getPlaceById(place.id);

                if (context.mounted) {
                  if (latestPlace != null) {
                    print('DEBUG: Using latest place data: ${latestPlace.name}');
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => PlaceDetailPage(place: latestPlace),
                    //   ),
                    // );
                  } else {
                    print('DEBUG: Latest place not found, using original place data');
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => PlaceDetailPage(place: place),
                    //   ),
                    // );
                  }
                }
              } catch (e) {
                print('Error fetching latest place data: $e');
                if (context.mounted) {
                  // Fallback to original place data
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => PlaceDetailPage(place: place),
                  //   ),
                  // );
                }
              }
            },
            child: Stack(
              children: [
                // Background Image - FIXED VERSION
                Positioned.fill(
                  child: _buildImage(),
                ),
                // Gradient Overlay (Top to Bottom)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.8)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.3, 0.6, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Section: Name, Price, Location
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    place.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 2.0,
                                            color: Colors.black54,
                                            offset: Offset(1.0, 1.0))
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    priceText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 2.0,
                                            color: Colors.black54,
                                            offset: Offset(1.0, 1.0))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    place.location,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 2.0,
                                            color: Colors.black54,
                                            offset: Offset(1.0, 1.0))
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Bottom Section: Rating and Kelola Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 20, color: Colors.orangeAccent),
                                const SizedBox(width: 4),
                                Text(
                                  '${place.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black54,
                                          offset: Offset(1.0, 1.0))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                print('=== KELOLA BUTTON DEBUG ===');
                                print('Kelola button clicked: ${place.name}');
                                print('Place ID: ${place.id}');
                                print('=== END KELOLA BUTTON DEBUG ===');
                                
                                try {
                                  final latestPlace = await ref.read(placesProvider.notifier).getPlaceById(place.id);
                                  
                                  if (context.mounted) {
                                    if (latestPlace != null) {
                                      print('DEBUG: Using latest place data for Kelola: ${latestPlace.name}');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlaceDetail(
                                            place: latestPlace,
                                          ),
                                        ),
                                      );
                                    } else {
                                      print('DEBUG: Latest place not found for Kelola, using original place data');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlaceDetail(
                                            place: place,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  print('Error in Kelola button: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Terjadi kesalahan: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 3,
                              ),
                              child: const Text(
                                'Kelola',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Debug overlay
                if (place.name.toLowerCase().contains('debug'))
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: ${place.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIXED: Method untuk membangun widget gambar yang tepat
  Widget _buildImage() {
    // Debug print untuk melihat nilai image dan isLocalImage
    print('=== IMAGE DEBUG ===');
    print('Image path: ${place.image}');
    print('Is Local Image: ${place.isLocalImage}');
    print('=== END IMAGE DEBUG ===');

    // Jika gambar adalah URL (dari API)
    if (!place.isLocalImage && _isValidUrl(place.image)) {
      return Image.network(
        place.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
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
    else if (place.isLocalImage && place.image.isNotEmpty) {
      return Image.file(
        File(place.image),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('File image error: $error');
          return Container(
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
    else if (!place.isLocalImage && !_isValidUrl(place.image) && place.image.isNotEmpty) {
      return Image.asset(
        place.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Asset image error: $error');
          return Container(
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
}