// widgets/user_place_image_carousel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/saved_provider.dart';

class UserPlaceImageCarousel extends ConsumerStatefulWidget {
  final Place place;
  final VoidCallback onBack;

  const UserPlaceImageCarousel({
    super.key,
    required this.place,
    required this.onBack,
  });

  @override
  ConsumerState<UserPlaceImageCarousel> createState() => _UserPlaceImageCarouselState();
}

class _UserPlaceImageCarouselState extends ConsumerState<UserPlaceImageCarousel> {
  int _currentImageIndex = 0;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _updateImages();
  }

  @override
  void didUpdateWidget(UserPlaceImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.image != widget.place.image ||
        oldWidget.place.additionalImages != widget.place.additionalImages) {
      _updateImages();
    }
  }

  void _updateImages() {
    _images = [];
    
    // Add main image
    if (widget.place.image?.isNotEmpty == true) {
      _images.add(widget.place.image!);
    }
    
    // Add additional images
    if (widget.place.additionalImages?.isNotEmpty == true) {
      _images.addAll(widget.place.additionalImages!);
    }
    
    // Fallback if no images
    if (_images.isEmpty) {
      _images.add('assets/images/placeholder.jpg');
    }
  }

  void _sharePlace() {
    final place = widget.place;
    Share.share(
        "Rekomendasi wisata: ${place.name} di ${place.location} ⭐️ ${place.rating}/5");
  }

  void _toggleSavePlace() {
    ref.read(savedPlaceProvider.notifier).toggleSaved(widget.place);
  }

  Widget _buildImage(String imagePath) {
    if (widget.place.isLocalImage == true) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      return Image.network(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedNotifier = ref.read(savedPlaceProvider.notifier);
    final isSaved = savedNotifier.isSaved(widget.place);

    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 280,
              viewportFraction: 1.0,
              autoPlay: _images.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, _) {
                setState(() => _currentImageIndex = index);
              },
            ),
            items: _images.map((img) {
              return SizedBox(
                width: double.infinity,
                child: _buildImage(img),
              );
            }).toList(),
          ),
        ),

        // Top overlay buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: widget.onBack,
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
                          isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: Colors.white,
                          size: 20,
                        ),
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
                        icon: const Icon(Icons.share, color: Colors.white, size: 20),
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
    );
  }
}