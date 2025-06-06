import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditWisataPage extends StatefulWidget {
  final String wisataId;
  const EditWisataPage({super.key, required this.wisataId});

  @override
  State<EditWisataPage> createState() => _EditWisataPageState();
}

class _EditWisataPageState extends State<EditWisataPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _deskripsiController;
  late TextEditingController _jamWeekdayController;
  late TextEditingController _jamWeekendController;
  late TextEditingController _hargaWeekdayController;
  late TextEditingController _hargaWeekendController;
  late TextEditingController _fasilitasController;
  late TextEditingController _lokasiController;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _deskripsiController = TextEditingController();
    _jamWeekdayController = TextEditingController();
    _jamWeekendController = TextEditingController();
    _hargaWeekdayController = TextEditingController();
    _hargaWeekendController = TextEditingController();
    _fasilitasController = TextEditingController();
    _lokasiController = TextEditingController();

    _loadData();
  }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance
        .collection('wisata')
        .doc(widget.wisataId)
        .get();

    final data = doc.data();
    if (data != null) {
      _namaController.text = data['nama'];
      _deskripsiController.text = data['deskripsi'];
      _jamWeekdayController.text = data['jamOperasionalWeekdays'];
      _jamWeekendController.text = data['jamOperasionalWeekend'];
      _hargaWeekdayController.text = data['hargaWeekday'];
      _hargaWeekendController.text = data['hargaWeekend'];
      _lokasiController.text = data['lokasi'];
      _fasilitasController.text = (data['fasilitas'] as List).join(', ');
    }

    setState(() => _loading = false);
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('wisata')
          .doc(widget.wisataId)
          .update({
        'nama': _namaController.text,
        'deskripsi': _deskripsiController.text,
        'jamOperasionalWeekdays': _jamWeekdayController.text,
        'jamOperasionalWeekend': _jamWeekendController.text,
        'hargaWeekday': _hargaWeekdayController.text,
        'hargaWeekend': _hargaWeekendController.text,
        'lokasi': _lokasiController.text,
        'fasilitas': _fasilitasController.text.split(',').map((e) => e.trim()).toList(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Wisata')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama')),
                    TextFormField(controller: _jamWeekdayController, decoration: const InputDecoration(labelText: 'Jam Operasional Weekdays')),
                    TextFormField(controller: _jamWeekendController, decoration: const InputDecoration(labelText: 'Jam Operasional Weekend')),
                    TextFormField(controller: _hargaWeekdayController, decoration: const InputDecoration(labelText: 'Harga Weekdays')),
                    TextFormField(controller: _hargaWeekendController, decoration: const InputDecoration(labelText: 'Harga Weekend')),
                    TextFormField(controller: _deskripsiController, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi')),
                    TextFormField(controller: _fasilitasController, decoration: const InputDecoration(labelText: 'Fasilitas (pisahkan dengan koma)')),
                    TextFormField(controller: _lokasiController, decoration: const InputDecoration(labelText: 'Link Lokasi')),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _saveChanges, child: const Text("Simpan"))
                  ],
                ),
              ),
            ),
    );
  }
}
