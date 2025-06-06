import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 110,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("J-Tour Admin", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.black),
                SizedBox(width: 4),
                Text("Wuluhan", style: TextStyle(color: Colors.black)),
              ],
            )
          ],
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {},
              ),
              Row(
                children: [
                  Icon(Icons.cloud, color: Colors.grey),
                  Text("32°C", style: TextStyle(color: Colors.black)),
                ],
              ),
              Text("UV Index: Extreme", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            Text("Wisata Anda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildTourCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-wisata'); // Navigasi ke halaman tambah wisata
        },
        tooltip: 'Tambah Wisata',
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, size: 30), 
        ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildTourCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage('assets/images/pantai_papuma.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pantai Papuma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Kec. Wuluhan, Jember", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Text("Rp.15.000 - Rp.20.000/Orang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                Text("4.5", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                shape: StadiumBorder(),
              ),
              child: Text("Kelola", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
