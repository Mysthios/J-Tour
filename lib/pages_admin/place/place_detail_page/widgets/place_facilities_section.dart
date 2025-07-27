// widgets/place_facilities_section.dart
import 'package:flutter/material.dart';
import 'package:j_tour/models/place_model.dart';

class PlaceFacilitiesSection extends StatelessWidget {
  final Place place;

  const PlaceFacilitiesSection({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final facilities = place.facilities?.isNotEmpty == true 
        ? place.facilities! 
        : _getDefaultFacilities();

    return Container(
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
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: facilities.map((facility) {
              return _buildFacilityItem(facility);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(String facility) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
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
  }

  List<String> _getDefaultFacilities() {
    return [
      "Area Parkir",
      "Toilet dan Kamar Mandi",
      "Mushola",
      "Warung Makan",
      "Area Camping",
      "Penginapan"
    ];
  }
}