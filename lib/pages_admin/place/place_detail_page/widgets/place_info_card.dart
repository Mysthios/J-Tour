// widgets/place_info_card.dart
import 'package:flutter/material.dart';
import 'package:j_tour/models/place_model.dart';

class PlaceInfoCard extends StatelessWidget {
  final Place place;
  final VoidCallback onReviewsTap;

  const PlaceInfoCard({
    super.key,
    required this.place,
    required this.onReviewsTap,
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
          const SizedBox(height: 12),

          // Rating and Review
          Row(
            children: [
              GestureDetector(
                onTap: onReviewsTap,
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${place.rating?.toStringAsFixed(1) ?? '0.0'}",
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Text(
                  "Admin View",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
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
                child: _buildScheduleCard(
                  title: "Weekdays:",
                  hours: place.weekdaysHours ?? "06:00 - 17:00",
                  price: place.weekdayPrice ?? place.price ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScheduleCard(
                  title: "Weekend:",
                  hours: place.weekendHours ?? "06:00 - 18:00",
                  price: place.weekendPrice ?? ((place.price ?? 0) + 15000),
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
            "Rp.$price",
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