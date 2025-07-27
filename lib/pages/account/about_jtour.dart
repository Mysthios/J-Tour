import 'package:flutter/material.dart';

class AboutJTourPage extends StatelessWidget {
  const AboutJTourPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tentang J-Tour',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Header Section
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/Icon.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Tentang Aplikasi
            _buildSection(
              title: 'Tentang Aplikasi',
              content: 'J-TOUR adalah aplikasi pencarian wisata Kabupaten Jember berbasis mobile yang dirancang untuk membantu wisatawan menemukan dan menjelajahi destinasi wisata di Jember. Aplikasi ini menyediakan informasi lengkap mengenai tempat-tempat wisata seperti Pantai Papuma, Air Terjun Tancak, dan berbagai destinasi budaya lainnya, dilengkapi dengan fitur pencarian berbasis minat, rute perjalanan, foto, dan ulasan pengguna.',
            ),
            
            
            const SizedBox(height: 24),
            
            // Tim Pengembang
            _buildSection(
              title: 'Tim Pengembang',
              content: 'Aplikasi J-TOUR dikembangkan oleh mahasiswa Program Studi Teknologi Informasi, Fakultas Ilmu Komputer, Universitas Jember:\n\n• Muhammad Fairuz Zaki \n• Linatul Habibah \n• M. Athar Humam G.',
            ),
            
            const SizedBox(height: 24),
            
            // Visi & Misi
            _buildSection(
              title: 'Visi',
              content: 'Menjadi solusi digital yang mendukung promosi pariwisata lokal Kabupaten Jember dan memberikan pengalaman wisata yang informatif serta efisien bagi wisatawan.',
            ),
            
            const SizedBox(height: 16),
            
            _buildSection(
              title: 'Misi',
              content: '• Menyediakan informasi destinasi wisata Jember secara terintegrasi dan real-time\n• Memudahkan wisatawan dalam merencanakan perjalanan sesuai minat dan preferensi\n• Mendukung promosi destinasi wisata lokal yang belum dikenal luas\n• Meningkatkan partisipasi masyarakat dalam sektor pariwisata\n• Menjadi jembatan antara potensi wisata Jember dengan kebutuhan wisatawan modern',
            ),
            
            const SizedBox(height: 24),
            
            // Fitur Utama
            _buildSection(
              title: 'Fitur Utama',
              content: '• Pencarian wisata berdasarkan nama, kategori, atau jarak lokasi\n• Filter kategori Wisatan• Peta lokasi dengan integrasi GPS\n• Detail lengkap tempat wisata (deskripsi, alamat, foto, jam buka, fasilitas)\n• Rute perjalanan dan navigasi ke destinasi\n• Ulasan dan rating dari pengguna\n• Simpan destinasi favorit\n• Informasi cuaca terkini di lokasi wisata\n• Komunikasi dengan admin wisata',
            ),
            
            const SizedBox(height: 24),
            
            // Kontak
            _buildSection(
              title: 'Hubungi Kami',
              content: 'Email: info@j-tour-jember.com\nUniversitas Jember\nProgram Studi Teknologi Informasi\nFakultas Ilmu Komputer\nJl. Kalimantan 37, Jember, Jawa Timur 68121',
            ),
            
            const SizedBox(height: 32),
            
            // Version Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Versi Aplikasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'J-Tour v1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}