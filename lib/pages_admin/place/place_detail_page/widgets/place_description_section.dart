// widgets/place_description_section.dart
import 'package:flutter/material.dart';
import 'package:j_tour/models/place_model.dart';

class PlaceDescriptionSection extends StatelessWidget {
  final Place place;

  const PlaceDescriptionSection({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            place.description ?? _getDefaultDescription(),
            style: const TextStyle(
              height: 1.4,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getDefaultDescription() {
    return "Tempat wisata yang menawarkan pengalaman yang tak terlupakan dengan pemandangan yang indah dan berbagai fasilitas yang lengkap untuk kenyamanan pengunjung.";
  }
}