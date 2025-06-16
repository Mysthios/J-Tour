import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:j_tour/pages_admin/place/edit_place/widgets/2.1_image_pciker_widgets.dart';
import 'package:j_tour/pages_admin/place/edit_place/widgets/2.2_basic_info_widget.dart';
import 'package:j_tour/pages_admin/place/edit_place/widgets/2.3_district_dropdown_widget.dart';
import 'package:j_tour/pages_admin/place/edit_place/widgets/2.4_location_picker_widget.dart';
import 'package:j_tour/pages_admin/place/edit_place/widgets/2.5_operating_hours_widget.dart';
import 'package:j_tour/pages_admin/place/edit_place/widgets/2.6_pricing_widget.dart';
import 'package:j_tour/pages_admin/place/edit_place/widgets/2.7_facilities_widget.dart';



class EditPlacePage extends ConsumerStatefulWidget {
  final Place place;

  const EditPlacePage({Key? key, required this.place}) : super(key: key);

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
  }

void _initializeControllers() {
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  _nameController = TextEditingController(text: widget.place.name);
  _locationController = TextEditingController(text: widget.place.location);
  _descriptionController =
      TextEditingController(text: widget.place.description);
  _weekdaysHoursController =
      TextEditingController(text: widget.place.weekdaysHours);
  _weekendHoursController =
      TextEditingController(text: widget.place.weekendHours);
  _priceController = TextEditingController(
    text: currencyFormatter.format(widget.place.price ?? 0),
  );
  _weekendPriceController = TextEditingController(
    text: currencyFormatter.format(widget.place.weekendPrice ?? 0),
  );

  _selectedCategory = widget.place.category;
  if (widget.place.latitude != null && widget.place.longitude != null) {
    _selectedLocation = LatLng(widget.place.latitude!, widget.place.longitude!);
  } else {
    _selectedLocation = null;
  }
  _facilities = List.from(widget.place.facilities ?? []);
  _additionalImages = List.from(widget.place.additionalImages ?? []);
  
  // Validasi field yang diperlukan
  List<String> missingFields = [];
  
  if (widget.place.name?.isEmpty ?? true) missingFields.add('Nama');
  if (widget.place.location?.isEmpty ?? true) missingFields.add('Lokasi');
  if (widget.place.description?.isEmpty ?? true) missingFields.add('Deskripsi');
  if (widget.place.weekdaysHours?.isEmpty ?? true) missingFields.add('Jam Operasional Weekdays');
  if (widget.place.weekendHours?.isEmpty ?? true) missingFields.add('Jam Operasional Weekend');
  if (widget.place.price == null || widget.place.price == 0) missingFields.add('Harga Weekdays');
  if (widget.place.weekendPrice == null || widget.place.weekendPrice == 0) missingFields.add('Harga Weekend');
  if (widget.place.category?.isEmpty ?? true) missingFields.add('Kategori');
  if (widget.place.facilities?.isEmpty ?? true) missingFields.add('Fasilitas');
  if (widget.place.latitude == null) missingFields.add('Latitude');
  if (widget.place.longitude == null) missingFields.add('Longitude');
  
  if (missingFields.isNotEmpty) {
    Future.microtask(() {
      _showErrorSnackBar('Field berikut belum diisi: ${missingFields.join(', ')}');
    });
  } else {
    Future.microtask(() {
      _showSuccessSnackBar('Semua field sudah terisi dengan lengkap.');
    });
  }
  
  // Jika gambar utama adalah lokal, set sebagai File
  if (widget.place.isLocalImage && (widget.place.image?.isNotEmpty ?? false)) {
    _selectedImage = File(widget.place.image!);
  }
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
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Harap isi semua kolom yang diperlukan dengan benar.');
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      _showErrorSnackBar('Kategori wisata harus dipilih.');
      return;
    }

    if (_selectedLocation == null) {
      _showErrorSnackBar('Lokasi harus ditentukan.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Pisahkan gambar tambahan: URL (lama) dan File (baru)
      List<String> existingImageUrls = [];
      List<String> newImagePaths = [];

      for (String path in _additionalImages) {
        if (path.startsWith('http') || path.startsWith('https')) {
          existingImageUrls.add(path);
        } else {
          newImagePaths.add(path);
        }
      }

      final place = Place(
        id: widget.place.id,
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
        image: _selectedImage?.path ?? widget.place.image,
        isLocalImage: _selectedImage != null,
        additionalImages: _additionalImages,
        rating: widget.place.rating,
      );

      print('=== EDIT PLACE PAGE DEBUG ===');
      print('Place data: ${place.toJson()}');
      print('Main image: ${_selectedImage?.path ?? widget.place.image}');
      print('Existing images (URLs): $existingImageUrls');
      print('New images (paths): $newImagePaths');

      final success = await ref
          .read(placesProvider.notifier)
          .updatePlace(widget.place.id, place);

      if (success) {
        _showSuccessSnackBar('Wisata berhasil diperbarui!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final error = ref.read(placesProvider).error;
        _showErrorSnackBar(
            error ?? 'Gagal memperbarui wisata. Silakan coba lagi.');
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
      errorMessage =
          'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    } else if (error.toString().contains('TimeoutException') ||
        error.toString().contains('timeout')) {
      errorMessage = 'Koneksi timeout. Silakan coba lagi.';
    } else if (error.toString().contains('FormatException')) {
      errorMessage = 'Format data tidak valid. Periksa input Anda.';
    } else if (error.toString().contains('File') ||
        error.toString().contains('gambar')) {
      errorMessage =
          'Terjadi masalah dengan file gambar. Pilih gambar yang valid.';
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

  int _parsePriceFromController(String text) {
    String cleanText = text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(cleanText) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final placesState = ref.watch(placesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Wisata'),
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
                  DistrictDropdownWidget(
                    locationController: _locationController,
                  ),
                  const SizedBox(height: 24),
                  LocationPickerWidget(
                    selectedLocation: _selectedLocation,
                    onLocationChanged: (location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  OperatingHoursWidget(
                    weekdaysHoursController: _weekdaysHoursController,
                    weekendHoursController: _weekendHoursController,
                  ),
                  const SizedBox(height: 24),
                  PricingWidget(
                    priceController: _priceController,
                    weekendPriceController: _weekendPriceController,
                    onPriceChanged: (String) {},
                    onWeekendPriceChanged: (String) {},
                  ),
                  const SizedBox(height: 24),
                  FacilitiesWidget(
                    facilities: _facilities,
                    onFacilitiesChanged: (facilities) {
                      setState(() {
                        _facilities = facilities;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || placesState.isLoading)
                          ? null
                          : _saveChanges,
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
                              'Perbarui Wisata',
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
                          'Memperbarui wisata...',
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
