// widgets/user_place_info_card.dart
import 'package:flutter/material.dart';
import 'package:j_tour/models/place_model.dart';

class UserPlaceInfoCard extends StatelessWidget {
  final Place place;
  final VoidCallback onWriteReviewTap;

  const UserPlaceInfoCard({
    super.key,
    required this.place,
    required this.onWriteReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Location
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  place.location,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Rating and Write Review Button
          Row(
            children: [
              // Display basic rating info (static)
              // Row(
              //   children: [
              //     const Icon(Icons.star, color: Colors.orange, size: 16),
              //     const SizedBox(width: 4),
              //     Text(
              //       "${place.rating?.toStringAsFixed(1) ?? '0.0'}",
              //       style: const TextStyle(
              //         fontWeight: FontWeight.w600,
              //         fontSize: 13,
              //       ),
              //     ),
              //     Text(
              //       " (Rating tempat)",
              //       style: TextStyle(
              //         color: Colors.grey[600],
              //         fontSize: 12,
              //       ),
              //     ),
              //   ],
              // ),
              // const Spacer(),
              // Write Review Button
              // ElevatedButton.icon(
              //   onPressed: onWriteReviewTap,
              //   icon: const Icon(Icons.edit, size: 16),
              //   label: const Text(
              //     "Beri Ulasan",
              //     style: TextStyle(
              //       fontWeight: FontWeight.w500,
              //       fontSize: 12,
              //     ),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue,
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //     minimumSize: Size.zero,
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(6),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),

          // Schedule and Price Cards
          Row(
            children: [
              Expanded(
                child: _buildScheduleCard(
                  title: "Weekdays:",
                  hours: place.weekdaysHours ?? "06:00 - 17:00",
                  price: place.weekdayPrice ?? place.price ?? 15000,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScheduleCard(
                  title: "Weekend:",
                  hours: place.weekendHours ?? "06:00 - 18:00",
                  price: place.weekendPrice ?? 30000,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required String hours,
    required int price,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  hours,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            price < 1000 ? "Rp.$price" : "Rp.${(price / 1000).toStringAsFixed(0)}.000",
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
    );
  }
}