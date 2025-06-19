// widgets/network_image_widget.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a network URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else {
      // Fallback for local assets or other image sources
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    }
  }
}