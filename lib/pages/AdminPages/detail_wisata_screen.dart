import 'package:flutter/material.dart';

class DetailWisataScreen extends StatelessWidget {
  const DetailWisataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/pantai_papuma.jpg',
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pantai Papuma",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey),
                            Text("Kec. Wuluhan", style: TextStyle(color: Colors.grey[700])),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18),
                        SizedBox(width: 4),
                        Text("Weekdays: 06:00 - 17:00"),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Rp.15.000 - 20.000/orang", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 18),
                        SizedBox(width: 4),
                        Text("Weekend: 06:00 - 18:00"),
                      ],
                    ),
                    Text("Rp.30.000/orang", style: TextStyle(color: Colors.blue)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        SizedBox(width: 4),
                        Text("4.5", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(" (438 Ulasan)", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Divider(height: 24),
                    Text(
                      "Deskripsi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Pantai Papuma adalah sebuah pantai yang menjadi tempat wisata di Kabupaten Jember, Provinsi Jawa Timur, Indonesia. "
                      "Nama Papuma sendiri sebenarnya adalah sebuah singkatan dari 'Pasir Putih Malikan'.",
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                    SizedBox(height: 16),
                    Text("Fasilitas", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _fasilitasItem("Area Parkir"),
                        _fasilitasItem("Toilet dan Kamar Mandi"),
                        _fasilitasItem("Mushola"),
                        _fasilitasItem("Warung Makan"),
                        _fasilitasItem("Area Camping"),
                        _fasilitasItem("Penginapan"),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text("Edit Wisata"),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text("Hapus Wisata"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _fasilitasItem(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.radio_button_checked, size: 12, color: Colors.blue),
        SizedBox(width: 4),
        Text(title),
      ],
    );
  }
}

