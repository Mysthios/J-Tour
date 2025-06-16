import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'widgets/1.1_image_picker_widget.dart';
import 'widgets/1.3_district_dropdown_widget.dart';
import 'widgets/1.4_location_picker_widget.dart';
import 'widgets/1.7_facilities_widget.dart';
import 'widgets/1.2_basic_info_widget.dart';
import 'widgets/1.5_operating_hours_widget.dart';
import 'widgets/1.6_pricing_widget.dart';

class CreatePlacePage extends ConsumerStatefulWidget {
  const CreatePlacePage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePlacePage> createState() => _CreatePlacePageState();
}

class _CreatePlacePageState extends ConsumerState<CreatePlacePage> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _weekdaysHoursController;
  late TextEditingController _weekendHoursController;
  late TextEditingController _priceController;
  late TextEditingController _weekendPriceController;

  File? _selectedImage;
  List<String> _facilities = [];
  List<String> _additionalImages = [];
  final _formKey = GlobalKey<FormState>();

  LatLng? _selectedLocation;
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeLocation();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _descriptionController = TextEditingController();
    _weekdaysHoursController = TextEditingController(text: '06:00 - 17:00');
    _weekendHoursController = TextEditingController(text: '06:00 - 18:00');

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    _priceController = TextEditingController(
      text: currencyFormatter.format(0),
    );

    _weekendPriceController = TextEditingController(
      text: currencyFormatter.format(0),
    );

    _facilities = [];
    _additionalImages = [];
  }

  void _initializeLocation() {
    _selectedLocation = LatLng(-8.1737, 113.6995);
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

  Future<void> _saveChanges() async {
    if (_isSubmitting) return; // Cegah pengiriman ganda

    // Validasi form
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Harap isi semua kolom yang diperlukan dengan benar.');
      return;
    }

    // Validasi tambahan
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _showErrorSnackBar('Kategori wisata harus dipilih.');
      return;
    }

    if (_selectedLocation == null) {
      _showErrorSnackBar('Lokasi harus ditentukan.');
      return;
    }

    // Validasi gambar utama
    if (_selectedImage == null) {
      _showErrorSnackBar('Gambar utama harus dipilih.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Buat objek Place dari data form
      final place = Place(
        id: '', // Akan di-generate oleh server
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        weekdaysHours: _weekdaysHoursController.text.trim(),
        weekendHours: _weekendHoursController.text.trim(),
        price: _parsePriceFromController(_priceController.text),
        weekendPrice: _parsePriceFromController(_weekendPriceController.text),
        weekdayPrice: _parsePriceFromController(_priceController.text),
        category: _selectedCategory!,
        facilities: _facilities,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        image: _selectedImage?.path ?? '',
        isLocalImage: _selectedImage != null,
        additionalImages: _additionalImages,
        rating: null, // Let server handle default rating
      );

      // Debug: Log data yang akan dikirim
      print('=== CREATE PLACE PAGE DEBUG ===');
      print('Place data: ${place.toJson()}');
      print('Selected image: ${_selectedImage?.path}');
      print('Additional images: $_additionalImages');

      // Simpan menggunakan provider yang benar
      final success = await ref.read(placesProvider.notifier).addPlace(place);

      if (success) {
        _showSuccessSnackBar('Wisata berhasil ditambahkan!');
        
        // Tunggu sebentar agar snackbar terlihat
        await Future.delayed(const Duration(seconds: 1));
        
        // Kembali ke halaman sebelumnya dengan hasil success
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Ambil error dari provider state
        final error = ref.read(placesProvider).error;
        _showErrorSnackBar(error ?? 'Gagal menambahkan wisata. Silakan coba lagi.');
      }
    } catch (e) {
      print('Error in _saveChanges: $e');
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleError(dynamic error) {
    String errorMessage;
    
    if (error.toString().contains('Network') || 
        error.toString().contains('network') ||
        error.toString().contains('connection')) {
      errorMessage = 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    } else if (error.toString().contains('TimeoutException') ||
               error.toString().contains('timeout')) {
      errorMessage = 'Koneksi timeout. Silakan coba lagi.';
    } else if (error.toString().contains('FormatException')) {
      errorMessage = 'Format data tidak valid. Periksa input Anda.';
    } else if (error.toString().contains('File') || 
               error.toString().contains('gambar')) {
      errorMessage = 'Terjadi masalah dengan file gambar. Pilih gambar yang valid.';
    } else if (error.toString().contains('validation') ||
               error.toString().contains('required')) {
      errorMessage = 'Data tidak valid. Periksa semua field yang diperlukan.';
    } else {
      errorMessage = 'Terjadi kesalahan: ${error.toString()}';
    }

    _showErrorSnackBar(errorMessage);
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Helper method to parse price from formatted text
  int _parsePriceFromController(String text) {
    // Hapus semua karakter non-digit
    String cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleanText) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider state untuk loading dan error
    final placesState = ref.watch(placesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Wisata'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker Section
                  ImagePickerWidgets(
                    selectedImage: _selectedImage,
                    additionalImages: _additionalImages,
                    onMainImageChanged: (image) {
                      setState(() {
                        _selectedImage = image;
                      });
                    },
                    onAdditionalImagesChanged: (images) {
                      setState(() {
                        _additionalImages = images;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Basic Information Section
                  BasicInfoWidget(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // District Dropdown Section
                  DistrictDropdownWidget(
                    locationController: _locationController,
                  ),
                  const SizedBox(height: 24),

                  // Location Picker Section
                  LocationPickerWidget(
                    selectedLocation: _selectedLocation,
                    onLocationChanged: (location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Operating Hours Section
                  OperatingHoursWidget(
                    weekdaysHoursController: _weekdaysHoursController,
                    weekendHoursController: _weekendHoursController,
                  ),
                  const SizedBox(height: 24),

                  // Pricing Section
                  PricingWidget(
                    priceController: _priceController,
                    weekendPriceController: _weekendPriceController,
                    onPriceChanged: (String) {},
                    onWeekendPriceChanged: (String) {},
                  ),
                  const SizedBox(height: 24),

                  // Facilities Section
                  FacilitiesWidget(
                    facilities: _facilities,
                    onFacilitiesChanged: (facilities) {
                      setState(() {
                        _facilities = facilities;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || placesState.isLoading) ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: (_isSubmitting || placesState.isLoading)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Tambah Wisata',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Loading overlay
          if (_isSubmitting || placesState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Menyimpan wisata...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}