import 'package:flutter/material.dart';
import 'dart:developer'; // ✅ Tambahan untuk log()

class AddWisataScreen extends StatefulWidget {
  const AddWisataScreen({super.key});

  @override
  State<AddWisataScreen> createState() => _AddWisataScreenState();
}

class _AddWisataScreenState extends State<AddWisataScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _weekdayJamController = TextEditingController();
  final TextEditingController _weekendJamController = TextEditingController();
  final TextEditingController _weekdayHargaController = TextEditingController();
  final TextEditingController _weekendHargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _fasilitasController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _weekdayJamController.dispose();
    _weekendJamController.dispose();
    _weekdayHargaController.dispose();
    _weekendHargaController.dispose();
    _deskripsiController.dispose();
    _fasilitasController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  void _simpanWisata() {
    if (_formKey.currentState!.validate()) {
      // Simpan ke Firestore atau backend nanti
      log("Nama: ${_namaController.text}");
      log("Jam Weekdays: ${_weekdayJamController.text}");
      log("Jam Weekend: ${_weekendJamController.text}");
      log("Harga Weekdays: ${_weekdayHargaController.text}");
      log("Harga Weekend: ${_weekendHargaController.text}");
      log("Deskripsi: ${_deskripsiController.text}");
      log("Fasilitas: ${_fasilitasController.text}");
      log("Lokasi: ${_lokasiController.text}");
    }
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Wisata'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInput('Nama', _namaController),
            Row(
              children: [
                Expanded(child: _buildInput('Jam Operasional (Weekdays)', _weekdayJamController)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput('Weekend', _weekendJamController)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildInput('Harga Tiket (Weekdays)', _weekdayHargaController)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput('Weekend', _weekendHargaController)),
              ],
            ),
            _buildInput('Deskripsi', _deskripsiController, maxLines: 4),
            _buildInput('Fasilitas (pisahkan dengan koma)', _fasilitasController, maxLines: 3),
            _buildInput('Lokasi (URL Maps atau alamat)', _lokasiController),
            const Text("Foto Wisata", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // Tambah fitur upload foto nanti
              },
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 32),
                      SizedBox(height: 4),
                      Text('Tambah Foto'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _simpanWisata,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
