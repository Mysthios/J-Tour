import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/saved_provider.dart';

class UserPlaceImageCarousel extends ConsumerStatefulWidget {
  final Place place;
  final VoidCallback onBack;
  final String userId;

  const UserPlaceImageCarousel({
    super.key,
    required this.place,
    required this.onBack,
    required this.userId,
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
    _setupImages();
  }

  @override
  void didUpdateWidget(UserPlaceImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place.image != widget.place.image ||
        oldWidget.place.additionalImages != widget.place.additionalImages) {
      _setupImages();
    }
  }

  void _setupImages() {
    _images = [];
    
    if (widget.place.image?.isNotEmpty == true) {
      _images.add(widget.place.image!);
    }
    
    if (widget.place.additionalImages?.isNotEmpty == true) {
      _images.addAll(widget.place.additionalImages!);
    }
    
    if (_images.isEmpty) {
      _images.add('assets/images/placeholder.jpg');
    }
  }

  void _sharePlace() {
    final place = widget.place;
    Share.share(
      "Rekomendasi wisata: ${place.name} di ${place.location} ⭐️ ${place.rating}/5"
    );
  }

  void _toggleSavePlace() {
    if (widget.userId.isEmpty) {
      _showMessage('Silakan login terlebih dahulu', Colors.orange);
      return;
    }

    ref.read(savedPlaceProvider.notifier).toggleSaved(widget.userId, widget.place);
    
    // Show immediate feedback
    final isSaved = ref.read(savedPlaceProvider.notifier).isSaved(widget.place);
    final message = isSaved 
        ? '${widget.place.name} ditambahkan ke favorit' 
        : '${widget.place.name} dihapus dari favorit';
    final color = isSaved ? Colors.green : Colors.grey;
    
    _showMessage(message, color);
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    final isLocal = widget.place.isLocalImage == true;
    
    if (isLocal) {
      return Image.asset(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
      );
    } else {
      return Image.network(
        imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
      );
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Simple watch - only get what we need
    final isSaved = ref.watch(savedPlaceProvider.select((state) => 
        state.hasValue && state.value!.places.any((p) => p.id == widget.place.id)));

    return Stack(
      children: [
        // Main carousel
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
            items: _images.map((img) => SizedBox(
              width: double.infinity,
              child: _buildImage(img),
            )).toList(),
          ),
        ),

        // Top overlay with buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                _buildOverlayButton(
                  icon: Icons.arrow_back,
                  onPressed: widget.onBack,
                ),
                
                // Action buttons
                Row(
                  children: [
                    // Save button
                    _buildOverlayButton(
                      icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      onPressed: _toggleSavePlace,
                    ),
                    const SizedBox(width: 8),
                    
                    // Share button
                    _buildOverlayButton(
                      icon: Icons.share,
                      onPressed: _sharePlace,
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
                final isActive = _currentImageIndex == entry.key;
                return Container(
                  width: isActive ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}