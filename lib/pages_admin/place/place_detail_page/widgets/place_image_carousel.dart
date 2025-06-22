// widgets/place_image_carousel.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:j_tour/models/place_model.dart';
import 'network_image_widget.dart';

class PlaceImageCarousel extends StatefulWidget {
  final Place place;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PlaceImageCarousel({
    super.key,
    required this.place,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PlaceImageCarousel> createState() => _PlaceImageCarouselState();
}

class _PlaceImageCarouselState extends State<PlaceImageCarousel> {
  int _currentImageIndex = 0;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _initializeImages();
  }

  @override
  void didUpdateWidget(PlaceImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place != widget.place) {
      _initializeImages();
    }
  }

  void _initializeImages() {
    _images = [widget.place.image];
    if (widget.place.additionalImages != null &&
        widget.place.additionalImages!.isNotEmpty) {
      _images.addAll(widget.place.additionalImages!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 280,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, _) {
                setState(() => _currentImageIndex = index);
              },
            ),
            items: _images.map((imagePath) {
              return SizedBox(
                width: double.infinity,
                child: NetworkImageWidget(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                ),
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
                _buildOverlayButton(
                  icon: Icons.arrow_back,
                  onPressed: widget.onBack,
                  backgroundColor: Colors.black.withOpacity(0.4),
                ),
                Row(
                  children: [
                    _buildOverlayButton(
                      icon: Icons.edit,
                      onPressed: widget.onEdit,
                      backgroundColor: Colors.green.withOpacity(0.4),
                    ),
                    const SizedBox(width: 8),
                    _buildOverlayButton(
                      icon: Icons.delete,
                      onPressed: widget.onDelete,
                      backgroundColor: Colors.red.withOpacity(0.4),
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

  Widget _buildOverlayButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}