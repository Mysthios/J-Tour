import 'package:flutter/material.dart';

class UlasanScreen extends StatelessWidget {
  const UlasanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Penilaian dan Ulasan", style: TextStyle(color: Colors.black)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildRatingSummary(),
          SizedBox(height: 24),
          Text("Ulasan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 12),
          _buildReviewCard(
            name: "Sabrina Khoirun",
            date: "2 Mei 2025",
            rating: 3,
            review: "Tempatnya bagus, bersih dan banyak tempat jualan, cuman hati hati banyak monyet.",
            imageAsset: 'assets/images/monyet.jpg',
          ),
          SizedBox(height: 16),
          _buildReviewCard(
            name: "Rizky Firmansyah",
            date: "2 Mei 2025",
            rating: 5,
            review: "Pemandangan bagus, recommended buat liburan keluarga!",
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text("Semua Penilaian (438 Ulasan)", style: TextStyle(fontWeight: FontWeight.bold)),
            Spacer(),
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 4),
            Text("4.5", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 12),
        _buildRatingBar(5, 100),
        _buildRatingBar(4, 300),
        _buildRatingBar(3, 15),
        _buildRatingBar(2, 15),
        _buildRatingBar(1, 8),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    final double max = 300.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.star, size: 20, color: Colors.orange),
          SizedBox(width: 4),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Container(
                  height: 10,
                  width: (count / max) * 200,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text("$count"),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String date,
    required int rating,
    required String review,
    String? imageAsset,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 18,
                    color: index < rating ? Colors.amber : Colors.grey[300],
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(review),
          if (imageAsset != null) ...[
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imageAsset),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text("Balas", style: TextStyle(color: Colors.grey[800])),
            ),
          )
        ],
      ),
    );
  }
}
