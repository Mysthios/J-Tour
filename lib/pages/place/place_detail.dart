import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:j_tour/pages/place/reviews_page.dart';
import 'package:j_tour/pages/place/write_review_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/saved_provider.dart';
import 'package:j_tour/pages/map/map_page.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  final Place place;
  const PlaceDetailPage({super.key, required this.place});

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  int _currentImageIndex = 0;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = [widget.place.image, ...?widget.place.additionalImages];
  }

  void _sharePlace() {
    final place = widget.place;
    Share.share(
        "Rekomendasi wisata: ${place.name} di ${place.location} ⭐️ ${place.rating}/5");
  }

  void _openWhatsApp() async {
    final phone = "6281234567890";
    final url = Uri.parse(
        "https://wa.me/$phone?text=Halo, saya ingin bertanya tentang ${widget.place.name}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak dapat membuka WhatsApp")),
      );
    }
  }

  void _navigateToReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsPage(place: widget.place),
      ),
    );
  }

  void _navigateToWriteReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewPage(place: widget.place),
      ),
    );
  }

  void _navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(place: widget.place),
      ),
    );
  }

  void _toggleSavePlace() {
    ref.read(savedPlaceProvider.notifier).toggleSaved(widget.place);
  }

  @override
  Widget build(BuildContext context) {
    final savedPlaces = ref.watch(savedPlaceProvider);
    final savedNotifier = ref.read(savedPlaceProvider.notifier);
    final isSaved = savedNotifier.isSaved(widget.place);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Image Carousel with overlay buttons and indicators
          Stack(
            children: [
              SizedBox(
                height: 280,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 280,
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 4),
                    onPageChanged: (index, _) {
                      setState(() => _currentImageIndex = index);
                    },
                  ),
                  items: _images.map((img) {
                    return SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        img,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Top overlay buttons
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color: Colors.white,
                                  size: 20),
                              onPressed: _toggleSavePlace,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share,
                                  color: Colors.white, size: 20),
                              onPressed: _sharePlace,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Carousel indicators
              if (_images.length > 1)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: _images.asMap().entries.map((entry) {
                      return Container(
                        width: _currentImageIndex == entry.key ? 20 : 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: _currentImageIndex == entry.key
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Location
                        Text(
                          widget.place.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              widget.place.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Rating and Review
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _navigateToReviews,
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.orange, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.place.rating}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    " (438 Ulasan)",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _navigateToWriteReview,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Beri Ulasan",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Schedule and Price Cards
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Weekdays:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 12, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Text(
                                          "06:00 - 17:00",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Rp.15.000 - 20.000",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      "/Orang",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Weekend:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time,
                                            size: 12, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        const Text(
                                          "06:00 - 18:00",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Rp.30.000",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      "/Orang",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // // Contact Button
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton.icon(
                        //     onPressed: _openWhatsApp,
                        //     icon: const Icon(Icons.phone,
                        //         color: Colors.white, size: 16),
                        //     label: const Text(
                        //       "Hubungi",
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 14,
                        //       ),
                        //     ),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.blue,
                        //       padding: const EdgeInsets.symmetric(vertical: 12),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //       elevation: 0,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  // Description Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Deskripsi",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.place.description ??
                              "Pantai Papuma adalah sebuah pantai yang menjadi tempat wisata di Kabupaten Jember, Provinsi Jawa Timur, Indonesia. Nama Papuma sendiri sebenarnya adalah singkatan dari \"Pasir Putih Malikan\".",
                          style: const TextStyle(
                            height: 1.4,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Facilities Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Fasilitas",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Facilities Grid
                        if (widget.place.facilities != null &&
                            widget.place.facilities!.isNotEmpty)
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: widget.place.facilities!.map((facility) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    facility,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          )
                        else
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              "Area Parkir",
                              "Toilet dan Kamar Mandi",
                              "Mushola",
                              "Warung Makan",
                              "Area Camping",
                              "Penginapan"
                            ].map((facility) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 14, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  Text(
                                    facility,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Direction Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToMap,
                      icon: const Icon(Icons.navigation,
                          color: Colors.white, size: 18),
                      label: const Text(
                        "Petunjuk Arah",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
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
