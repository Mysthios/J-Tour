// widgets/user_place_description_section.dart
import 'package:flutter/material.dart';
import 'package:j_tour/models/place_model.dart';

class UserPlaceDescriptionSection extends StatelessWidget {
  final Place place;

  const UserPlaceDescriptionSection({
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
            place.description?.isNotEmpty == true
                ? place.description!
                : "Pantai Papuma adalah sebuah pantai yang menjadi tempat wisata di Kabupaten Jember, Provinsi Jawa Timur, Indonesia. Nama Papuma sendiri sebenarnya adalah singkatan dari \"Pasir Putih Malikan\".",
            style: const TextStyle(
              height: 1.4,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}