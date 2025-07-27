import 'dart:io';
import 'package:flutter/material.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/place/place_detail.dart';
import 'package:intl/intl.dart';

const Color kPrimaryBlue = Color(0xFF0072BC);

class ExploreDestinationCard extends StatelessWidget {
  final Place place;

  const ExploreDestinationCard({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(place: place),
          ),
        );
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
                child: _buildImage(),
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
                          place.name,
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
                            formatter.format(place.price),
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
                          place.location,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${place.rating ?? 0.0}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method untuk membangun widget gambar yang tepat (sama seperti di WisataAndaCard)
  Widget _buildImage() {
    // Debug print untuk melihat nilai image dan isLocalImage
    print('=== EXPLORE IMAGE DEBUG ===');
    print('Image path: ${place.image}');
    print('Is Local Image: ${place.isLocalImage}');
    print('=== END EXPLORE IMAGE DEBUG ===');

    // Jika gambar adalah URL (dari API)
    if (!place.isLocalImage && _isValidUrl(place.image)) {
      return Image.network(
        place.image,
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
    else if (place.isLocalImage && place.image.isNotEmpty) {
      return Image.file(
        File(place.image),
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
    else if (!place.isLocalImage && !_isValidUrl(place.image) && place.image.isNotEmpty) {
      return Image.asset(
        place.image,
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
}