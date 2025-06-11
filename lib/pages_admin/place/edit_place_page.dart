import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/place_provider.dart';

class EditPlacePage extends ConsumerStatefulWidget {
  final Place place;
  final bool isNew; // New parameter to indicate if this is a new place

  const EditPlacePage({
    super.key,
    required this.place,
    this.isNew = false, // Default to false
  });

  @override
  ConsumerState<EditPlacePage> createState() => _EditPlacePageState();
}

class _EditPlacePageState extends ConsumerState<EditPlacePage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _weekdaysHoursController;
  late TextEditingController _weekendHoursController;
  late TextEditingController _priceController;
  late TextEditingController _weekendPriceController;
  late double _rating;
  File? _selectedImage;
  List<String> _facilities = [];
  late bool _isNewPlace;
  final _formKey = GlobalKey<FormState>();
  List<String> _additionalImages = [];

  @override
  void initState() {
    super.initState();

    // Use the passed isNew flag
    _isNewPlace = widget.isNew;

    _nameController = TextEditingController(text: widget.place.name);
    _locationController = TextEditingController(text: widget.place.location);
    _descriptionController =
        TextEditingController(text: widget.place.description ?? '');
    _weekdaysHoursController = TextEditingController(
        text: widget.place.weekdaysHours ?? '06:00 - 17:00');
    _weekendHoursController = TextEditingController(
        text: widget.place.weekendHours ?? '06:00 - 18:00');

    // Format the price values
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    _priceController = TextEditingController(
      text: currencyFormatter.format(widget.place.price),
    );

    _weekendPriceController = TextEditingController(
      text: widget.place.weekendPrice != null
          ? currencyFormatter.format(widget.place.weekendPrice!)
          : currencyFormatter
              .format(widget.place.price + 15000), // Default weekend price
    );

    _rating = widget.place.rating;
    _facilities =
        widget.place.facilities?.toList() ?? ['Area Parkir', 'Toilet'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _weekdaysHoursController.dispose();
    _weekendHoursController.dispose();
    _priceController.dispose();
    _weekendPriceController.dispose();
    super.dispose();
  }

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void _handleMainImageChanged(File image) {
    setState(() {
      _selectedImage = image;
    });
  }

  void _handleAdditionalImagesChanged(List<String> images) {
    setState(() {
      _additionalImages = images;
    });
  }

  void _addFacility() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Fasilitas'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Nama fasilitas",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _facilities.add(value);
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Submit is handled by onSubmitted in TextField
              // This is a backup in case user presses the button
              final textField = Navigator.of(context).widget as AlertDialog;
              final textFieldContent = textField.content as TextField;
              final text = textFieldContent.controller?.text ?? '';
              if (text.isNotEmpty) {
                setState(() {
                  _facilities.add(text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _removeFacility(int index) {
    setState(() {
      _facilities.removeAt(index);
    });
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Parse currency formatted strings back to integers
    String priceText = _priceController.text.replaceAll(RegExp(r'[^\d]'), '');

    int price = int.tryParse(priceText) ?? 0;
    int weekendPrice = int.tryParse(
            _weekendPriceController.text.replaceAll(RegExp(r'[^\d]'), '')) ??
        0;

    final updatedPlace = widget.place.copyWith(
      name: _nameController.text,
      location: _locationController.text,
      description: _descriptionController.text,
      weekdaysHours: _weekdaysHoursController.text,
      weekendHours: _weekendHoursController.text,
      price: price,
      weekendPrice: weekendPrice,
      rating: _rating,
      facilities: _facilities,
      image: _selectedImage?.path ?? widget.place.image,
      isLocalImage: _selectedImage != null ? true : widget.place.isLocalImage,
      additionalImages: null,
    );

    if (_isNewPlace) {
      // Add new place
      ref.read(placesNotifierProvider.notifier).addPlace(updatedPlace);
    } else {
      // Update existing place
      ref.read(placesNotifierProvider.notifier).updatePlace(updatedPlace);
    }

    // Return true to indicate success
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewPlace ? 'Tambah Wisata Baru' : 'Edit Wisata',
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!,
                                  fit: BoxFit.cover),
                            )
                          : widget.place.isLocalImage
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(widget.place.image),
                                      fit: BoxFit.cover),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(widget.place.image,
                                      fit: BoxFit.cover),
                                ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () async {
                          final image = await _pickImage();
                          if (image != null) {
                            setState(() {
                              _selectedImage = image;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Basic information
              const Text(
                'Informasi Dasar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Wisata',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Opening hours
              const Text(
                'Jam Operasional',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weekdaysHoursController,
                decoration: const InputDecoration(
                  labelText: 'Jam Operasi Weekday',
                  hintText: '06:00 - 17:00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weekendHoursController,
                decoration: const InputDecoration(
                  labelText: 'Jam Operasi Weekend',
                  hintText: '06:00 - 18:00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 24),

              // Pricing
              const Text(
                'Harga Tiket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Weekday',
                  prefixText: 'Rp. ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Format as currency
                  if (value.isNotEmpty) {
                    String numericValue =
                        value.replaceAll(RegExp(r'[^\d]'), '');
                    if (numericValue.isNotEmpty) {
                      int? intValue = int.tryParse(numericValue);
                      if (intValue != null) {
                        final formatted = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: '',
                          decimalDigits: 0,
                        ).format(intValue);
                        _priceController.value =
                            _priceController.value.copyWith(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weekendPriceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Weekend',
                  prefixText: 'Rp. ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga weekend tidak boleh kosong';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Format as currency
                  if (value.isNotEmpty) {
                    String numericValue =
                        value.replaceAll(RegExp(r'[^\d]'), '');
                    if (numericValue.isNotEmpty) {
                      int? intValue = int.tryParse(numericValue);
                      if (intValue != null) {
                        final formatted = NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: '',
                          decimalDigits: 0,
                        ).format(intValue);
                        _weekendPriceController.value =
                            _weekendPriceController.value.copyWith(
                          text: formatted,
                          selection:
                              TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  }
                },
              ),
              const SizedBox(height: 24),

              // Rating
              const Text(
                'Rating',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      activeColor: Colors.amber,
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Facilities
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addFacility,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_facilities.length, (index) {
                  return Chip(
                    label: Text(_facilities[index]),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeFacility(index),
                    backgroundColor: Colors.grey[200],
                  );
                }),
              ),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isNewPlace ? 'Tambah Wisata' : 'Simpan Perubahan',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
