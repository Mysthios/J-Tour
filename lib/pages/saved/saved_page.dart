import 'package:flutter/material.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

const Color kPrimaryBlue = Color(0xFF0072BC);

class _SavedPageState extends State<SavedPage> {
  int _currentIndex = 2; 


  void _onNavBarTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        title: const Text(
          "Tersimpan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar & filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Cari",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

            const SizedBox(height: 12),

           
            

            // 🧾 List destinasi
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: const [
                  DestinationCard(
                    imagePath: 'assets/images/papuma2.png',
                    name: 'Pantai Papuma',
                    location: 'Kecamatan Wuluhan',
                    rating: 4.5,
                    reviews: 438,
                    priceRange: 'Rp.15.000 - Rp.20.000',
                  ),
                  SizedBox(height: 24),
                  DestinationCard(
                    imagePath: 'assets/images/teluklove.png',
                    name: 'Teluk Love',
                    location: 'Kecamatan Pesanggaran',
                    rating: 4.7,
                    reviews: 332,
                    priceRange: 'Rp.10.000 - Rp.15.000',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class DestinationCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String location;
  final double rating;
  final int reviews;
  final String priceRange;

  const DestinationCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.priceRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark_border, size: 18),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      "$rating ",
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      "($reviews Ulasan)",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "$priceRange /Orang",
                  style: const TextStyle(
                    color: kPrimaryBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
