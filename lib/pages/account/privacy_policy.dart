import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kebijakan Privasi',
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
            // Header
            _buildSection(
              title: 'Kebijakan Privasi J-Tour',
              content: 'Terakhir diperbarui: Juni 2025\n\nKami di J-Tour berkomitmen untuk melindungi privasi Anda. Kebijakan privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda.',
            ),
            
            const SizedBox(height: 24),
            
            // Informasi yang Kami Kumpulkan
            _buildSection(
              title: '1. Informasi yang Kami Kumpulkan',
              content: 'Kami dapat mengumpulkan informasi berikut:\n\n• Informasi Akun: Nama, alamat email, dan informasi profil yang Anda berikan saat registrasi\n• Informasi Lokasi: Data GPS untuk menampilkan destinasi wisata terdekat dan navigasi rute perjalanan\n• Ulasan dan Rating: Review yang Anda berikan untuk destinasi wisata\n• Destinasi Favorit: Daftar tempat wisata yang Anda simpan sebagai favorit\n• Data Penggunaan: Informasi tentang destinasi yang Anda cari dan kunjungi\n• Informasi Perangkat: Jenis perangkat, sistem operasi, dan identifier unik untuk optimasi aplikasi',
            ),
            
            const SizedBox(height: 16),
            
            // Cara Kami Menggunakan Informasi
            _buildSection(
              title: '2. Cara Kami Menggunakan Informasi',
              content: 'Informasi yang kami kumpulkan digunakan untuk:\n\n• Menyediakan informasi destinasi wisata di Kabupaten Jember\n• Menampilkan lokasi wisata dan rute perjalanan berbasis GPS\n• Memberikan rekomendasi destinasi berdasarkan preferensi Anda\n• Memungkinkan Anda memberikan dan melihat ulasan wisata\n• Menyimpan daftar destinasi favorit Anda\n• Menampilkan informasi cuaca di lokasi wisata\n• Meningkatkan kualitas layanan aplikasi\n• Berkomunikasi dengan Anda terkait layanan aplikasi',
            ),
            
            const SizedBox(height: 16),
            
            // Berbagi Informasi
            _buildSection(
              title: '3. Berbagi Informasi',
              content: 'Kami tidak akan menjual atau menyewakan informasi pribadi Anda kepada pihak ketiga. Kami hanya akan berbagi informasi dalam situasi berikut:\n\n• Dengan persetujuan eksplisit Anda\n• Untuk memenuhi kewajiban hukum\n• Dengan penyedia layanan terpercaya yang membantu operasi kami\n• Dalam situasi darurat untuk melindungi keselamatan',
            ),
            
            const SizedBox(height: 16),
            
            // Keamanan Data
            _buildSection(
              title: '4. Keamanan Data',
              content: 'Kami menggunakan berbagai langkah keamanan untuk melindungi informasi pribadi Anda:\n\n• Enkripsi data dalam transit dan penyimpanan\n• Kontrol akses yang ketat\n• Pemantauan keamanan reguler\n• Pelatihan keamanan untuk karyawan\n• Audit keamanan berkala',
            ),
            
            const SizedBox(height: 16),
            
            // Hak Anda
            _buildSection(
              title: '5. Hak Anda',
              content: 'Anda memiliki hak untuk:\n\n• Mengakses informasi pribadi yang kami miliki\n• Memperbarui atau mengoreksi informasi Anda\n• Menghapus akun dan data pribadi Anda\n• Membatasi penggunaan informasi Anda\n• Menarik persetujuan yang telah diberikan\n• Meminta portabilitas data',
            ),
            
            const SizedBox(height: 16),
            
            // Cookies dan Teknologi Serupa
            _buildSection(
              title: '6. Cookies dan Teknologi Serupa',
              content: 'Kami menggunakan cookies dan teknologi serupa untuk:\n\n• Mengingat preferensi Anda\n• Menganalisis penggunaan aplikasi\n• Meningkatkan pengalaman pengguna\n• Menyediakan konten yang dipersonalisasi\n\nAnda dapat mengatur preferensi cookies melalui pengaturan perangkat Anda.',
            ),
            
            const SizedBox(height: 16),
            
            // Perubahan Kebijakan
            _buildSection(
              title: '7. Perubahan Kebijakan',
              content: 'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Perubahan akan diberitahukan melalui:\n\n• Notifikasi dalam aplikasi\n• Email ke alamat terdaftar\n• Pengumuman di website kami\n\nPerubahan akan berlaku setelah periode pemberitahuan yang wajar.',
            ),
            
            const SizedBox(height: 16),
            
            // Kontak
            _buildSection(
              title: '8. Hubungi Kami',
              content: 'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini atau ingin menggunakan hak-hak Anda, silakan hubungi kami:\n\nEmail: privacy@j-tour-jember.com\nProgram Studi Teknologi Informasi\nFakultas Ilmu Komputer\nUniversitas Jember\nJl. Kalimantan 37, Jember, Jawa Timur 68121\n\nWaktu Respons: Maksimal 7 hari kerja',
            ),
            
            const SizedBox(height: 32),
            
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Dengan menggunakan aplikasi J-Tour, Anda menyetujui kebijakan privasi ini. Pastikan Anda membaca dan memahami kebijakan ini sebelum menggunakan layanan kami.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
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
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}