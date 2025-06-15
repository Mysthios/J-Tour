// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:j_tour/models/place_model.dart';
// import 'package:j_tour/providers/place_provider.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class EditPlacePage extends ConsumerStatefulWidget {
//   final Place place;
//   final bool isNew;

//   const EditPlacePage({
//     super.key,
//     required this.place,
//     this.isNew = false,
//   });

//   @override
//   ConsumerState<EditPlacePage> createState() => _EditPlacePageState();
// }

// class _EditPlacePageState extends ConsumerState<EditPlacePage> {
//   late TextEditingController _nameController;
//   late TextEditingController _locationController;
//   late TextEditingController _descriptionController;
//   late TextEditingController _weekdaysHoursController;
//   late TextEditingController _weekendHoursController;
//   late TextEditingController _priceController;
//   late TextEditingController _weekendPriceController;
//   late TextEditingController _searchController;
//   File? _selectedImage;
//   List<String> _facilities = [];
//   List<String> _additionalImages = [];
//   late bool _isNewPlace;
//   final _formKey = GlobalKey<FormState>();
  
//   // Map related variables
//   LatLng? _selectedLocation;
//   final MapController _mapController = MapController();
//   bool _isSelectingLocation = false;
//   List<SearchResult> _searchResults = [];
//   bool _isSearching = false;

//   // Jember districts data
//   final List<String> _jemberDistricts = [
//     'Ajung',
//     'Ambulu',
//     'Arjasa',
//     'Balung',
//     'Bangsalsari',
//     'Gumukmas',
//     'Jelbuk',
//     'Jenggawah',
//     'Jombang',
//     'Kalisat',
//     'Kaliwates',
//     'Kencong',
//     'Ledokombo',
//     'Mayang',
//     'Mumbulsari',
//     'Pakusari',
//     'Patrang',
//     'Puger',
//     'Rambipuji',
//     'Semboro',
//     'Silo',
//     'Sukorambi',
//     'Sukowono',
//     'Sumberbaru',
//     'Sumberjambe',
//     'Sumbersari',
//     'Tanggul',
//     'Tempurejo',
//     'Umbulsari',
//     'Wuluhan',
//   ];

//   List<String> _filteredDistricts = [];
//   bool _showDropdown = false;

//   String? _selectedCategory;
  
//   @override
//   void initState() {
//     super.initState();
//     _isNewPlace = widget.isNew;
//     _initializeControllers();
//     _initializeLocation();
//     _filteredDistricts = _jemberDistricts;
//   }

//   void _initializeControllers() {
//     _nameController = TextEditingController(text: widget.place.name);
//     _locationController = TextEditingController(text: widget.place.location);
//     _selectedCategory = widget.place.category; // Assuming `category` is a property of Place
//     _descriptionController = TextEditingController(text: widget.place.description ?? '');
//     _weekdaysHoursController = TextEditingController(text: widget.place.weekdaysHours ?? '06:00 - 17:00');
//     _weekendHoursController = TextEditingController(text: widget.place.weekendHours ?? '06:00 - 18:00');
//     _searchController = TextEditingController();

//     // Format currency
//     final currencyFormatter = NumberFormat.currency(
//       locale: 'id_ID',
//       symbol: '',
//       decimalDigits: 0,
//     );

//     _priceController = TextEditingController(
//       text: currencyFormatter.format(widget.place.price),
//     );

//     _weekendPriceController = TextEditingController(
//       text: widget.place.weekendPrice != null
//           ? currencyFormatter.format(widget.place.weekendPrice!)
//           : currencyFormatter.format(widget.place.price + 15000),
//     );

//     _facilities = widget.place.facilities?.toList() ?? ['Area Parkir', 'Toilet'];
//     _additionalImages = widget.place.additionalImages?.toList() ?? [];
//   }

//   void _initializeLocation() {
//     if (widget.place.latitude != null && widget.place.longitude != null) {
//       _selectedLocation = LatLng(widget.place.latitude!, widget.place.longitude!);
//     } else {
//       // Default location (Jember, East Java)
//       _selectedLocation = LatLng(-8.1737, 113.6995);
//     }
//   }

//   void _filterDistricts(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredDistricts = _jemberDistricts;
//       } else {
//         _filteredDistricts = _jemberDistricts
//             .where((district) => district.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//       _showDropdown = query.isNotEmpty && _filteredDistricts.isNotEmpty;
//     });
//   }

//   void _selectDistrict(String district) {
//     setState(() {
//       _locationController.text = district;
//       _showDropdown = false;
//     });
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _locationController.dispose();
//     _descriptionController.dispose();
//     _weekdaysHoursController.dispose();
//     _weekendHoursController.dispose();
//     _priceController.dispose();
//     _weekendPriceController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _searchLocation(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults = [];
//         _isSearching = false;
//       });
//       return;
//     }

//     setState(() {
//       _isSearching = true;
//     });

//     try {
//       // Using Nominatim API for geocoding
//       final encodedQuery = Uri.encodeComponent(query);
//       final url = 'https://nominatim.openstreetmap.org/search?format=json&q=$encodedQuery&limit=5&addressdetails=1';
      
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'User-Agent': 'JTour Flutter App',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         final results = data.map((item) => SearchResult.fromJson(item)).toList();
        
//         setState(() {
//           _searchResults = results;
//           _isSearching = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isSearching = false;
//         _searchResults = [];
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error searching location: $e')),
//       );
//     }
//   }

//   void _selectSearchResult(SearchResult result) {
//     setState(() {
//       _selectedLocation = LatLng(result.lat, result.lon);
//       _searchResults = [];
//       _searchController.clear();
//     });
    
//     // Animate map to selected location
//     _mapController.move(_selectedLocation!, 15);
//   }

//   // Fungsi untuk menampilkan dialog pilihan kamera atau gallery untuk gambar utama
//   void _showMainImagePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Pilih Foto Utama',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _imagePickerOption(
//                     icon: Icons.camera_alt,
//                     label: 'Kamera',
//                     onTap: () => _pickMainImage(ImageSource.camera),
//                   ),
//                   _imagePickerOption(
//                     icon: Icons.photo_library,
//                     label: 'Gallery',
//                     onTap: () => _pickMainImage(ImageSource.gallery),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Fungsi untuk menampilkan dialog pilihan kamera atau gallery untuk gambar tambahan
//   void _showAdditionalImagePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Pilih Foto Tambahan',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _imagePickerOption(
//                     icon: Icons.camera_alt,
//                     label: 'Kamera',
//                     onTap: () => _pickAdditionalImage(ImageSource.camera),
//                   ),
//                   _imagePickerOption(
//                     icon: Icons.photo_library,
//                     label: 'Gallery',
//                     onTap: () => _pickAdditionalImage(ImageSource.gallery),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Widget untuk option picker
//   Widget _imagePickerOption({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: Colors.grey[300]!),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, size: 30, color: Colors.blue),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Fungsi untuk mengambil gambar utama
//   Future<void> _pickMainImage(ImageSource source) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? pickedFile = await picker.pickImage(
//         source: source,
//         maxWidth: 1200,
//         maxHeight: 800,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });

//         // Tutup bottom sheet
//         Navigator.of(context).pop();

//         // Tampilkan snackbar sukses
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Foto utama berhasil diubah'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       // Handle error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Fungsi untuk mengambil gambar tambahan
//   Future<void> _pickAdditionalImage(ImageSource source) async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? pickedFile = await picker.pickImage(
//         source: source,
//         maxWidth: 1200,
//         maxHeight: 800,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _additionalImages.add(pickedFile.path);
//         });

//         // Tutup bottom sheet
//         Navigator.of(context).pop();

//         // Tampilkan snackbar sukses
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Foto tambahan berhasil ditambahkan'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       // Handle error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _removeAdditionalImage(int index) {
//     setState(() {
//       _additionalImages.removeAt(index);
//     });
//   }

//   void _addFacility() {
//     final TextEditingController facilityController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Tambah Fasilitas'),
//         content: TextField(
//           controller: facilityController,
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: "Nama fasilitas",
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (facilityController.text.isNotEmpty) {
//                 setState(() {
//                   _facilities.add(facilityController.text);
//                 });
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text('Tambah'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _removeFacility(int index) {
//     setState(() {
//       _facilities.removeAt(index);
//     });
//   }

//   void _showLocationPicker() {
//     setState(() {
//       _isSelectingLocation = true;
//     });

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.8,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       const Text(
//                         'Pilih Lokasi',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () {
//                           setState(() {
//                             _isSelectingLocation = false;
//                             _searchResults = [];
//                             _searchController.clear();
//                           });
//                           Navigator.pop(context);
//                         },
//                         child: const Text('Selesai'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   // Search bar
//                   TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Cari lokasi...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _isSearching
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: Padding(
//                                 padding: EdgeInsets.all(12.0),
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               ),
//                             )
//                           : _searchController.text.isNotEmpty
//                               ? IconButton(
//                                   icon: const Icon(Icons.clear),
//                                   onPressed: () {
//                                     _searchController.clear();
//                                     setState(() {
//                                       _searchResults = [];
//                                     });
//                                   },
//                                 )
//                               : null,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     ),
//                     onChanged: (value) {
//                       // Debounce search
//                       Future.delayed(const Duration(milliseconds: 500), () {
//                         if (value == _searchController.text) {
//                           _searchLocation(value);
//                         }
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // Search results
//             if (_searchResults.isNotEmpty)
//               Container(
//                 height: 150,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: ListView.builder(
//                   itemCount: _searchResults.length,
//                   itemBuilder: (context, index) {
//                     final result = _searchResults[index];
//                     return ListTile(
//                       leading: const Icon(Icons.place, color: Colors.blue),
//                       title: Text(result.displayName),
//                       subtitle: Text('${result.lat.toStringAsFixed(4)}, ${result.lon.toStringAsFixed(4)}'),
//                       onTap: () => _selectSearchResult(result),
//                       dense: true,
//                     );
//                   },
//                 ),
//               ),
//             // Map
//             Expanded(
//               child: FlutterMap(
//                 mapController: _mapController,
//                 options: MapOptions(
//                   initialCenter: _selectedLocation ?? LatLng(-8.1737, 113.6995),
//                   initialZoom: 15,
//                   onTap: (tapPosition, point) {
//                     setState(() {
//                       _selectedLocation = point;
//                     });
//                   },
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                     userAgentPackageName: 'com.example.jtour',
//                   ),
//                   if (_selectedLocation != null)
//                     MarkerLayer(
//                       markers: [
//                         Marker(
//                           point: _selectedLocation!,
//                           width: 40,
//                           height: 40,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 3),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.place,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//             // Location info
//             if (_selectedLocation != null)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[50],
//                   border: Border(top: BorderSide(color: Colors.grey[300]!)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Koordinat Terpilih:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                     Text(
//                       'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
//                       style: TextStyle(color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _saveChanges() {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     // Parse currency formatted strings back to integers
//     String priceText = _priceController.text.replaceAll(RegExp(r'[^\d]'), '');
//     int price = int.tryParse(priceText) ?? 0;
//     int weekendPrice = int.tryParse(
//         _weekendPriceController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

//     final updatedPlace = widget.place.copyWith(
//       name: _nameController.text,
//       location: _locationController.text,
//       category: _selectedCategory,
//       description: _descriptionController.text,
//       weekdaysHours: _weekdaysHoursController.text,
//       weekendHours: _weekendHoursController.text,
//       price: price,
//       weekendPrice: weekendPrice,
//       facilities: _facilities,
//       image: _selectedImage?.path ?? widget.place.image,
//       isLocalImage: _selectedImage != null ? true : widget.place.isLocalImage,
//       additionalImages: _additionalImages,
//       latitude: _selectedLocation?.latitude,
//       longitude: _selectedLocation?.longitude,
//     );

//     if (_isNewPlace) {
//       ref.read(placesNotifierProvider.notifier).addPlace(updatedPlace);
//     } else {
//       ref.read(placesNotifierProvider.notifier).updatePlace(updatedPlace);
//     }

//     Navigator.pop(context, true);
//   }

//   String _formatCurrency(String value) {
//     if (value.isEmpty) return '';
//     String numericValue = value.replaceAll(RegExp(r'[^\d]'), '');
//     if (numericValue.isEmpty) return '';
    
//     int? intValue = int.tryParse(numericValue);
//     if (intValue == null) return value;
    
//     return NumberFormat.currency(
//       locale: 'id_ID',
//       symbol: '',
//       decimalDigits: 0,
//     ).format(intValue);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           _isNewPlace ? 'Tambah Wisata Baru' : 'Edit Wisata',
//           style: const TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check, color: Colors.blue),
//             onPressed: _saveChanges,
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Main Image section
//               Center(
//                 child: Stack(
//                   children: [
//                     Container(
//                       width: 200,
//                       height: 150,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey[200],
//                       ),
//                       child: _selectedImage != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.file(_selectedImage!, fit: BoxFit.cover),
//                             )
//                           : widget.place.isLocalImage
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Image.file(File(widget.place.image), fit: BoxFit.cover),
//                                 )
//                               : ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Image.asset(widget.place.image, fit: BoxFit.cover),
//                                 ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: InkWell(
//                         onTap: _showMainImagePickerOptions,
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.blue,
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Colors.white, width: 2),
//                           ),
//                           child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Additional Images section
//               const Text(
//                 'Foto Tambahan',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _additionalImages.length + 1,
//                   itemBuilder: (context, index) {
//                     if (index == _additionalImages.length) {
//                       return GestureDetector(
//                         onTap: _showAdditionalImagePickerOptions,
//                         child: Container(
//                           width: 100,
//                           height: 100,
//                           margin: const EdgeInsets.only(right: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
//                           ),
//                           child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 30),
//                         ),
//                       );
//                     }
                    
//                     return Stack(
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 100,
//                           margin: const EdgeInsets.only(right: 8),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: _additionalImages[index].startsWith('/')
//                                 ? Image.file(File(_additionalImages[index]), fit: BoxFit.cover)
//                                 : Image.asset(_additionalImages[index], fit: BoxFit.cover),
//                           ),
//                         ),
//                         Positioned(
//                           top: 4,
//                           right: 12,
//                           child: GestureDetector(
//                             onTap: () => _removeAdditionalImage(index),
//                             child: Container(
//                               padding: const EdgeInsets.all(2),
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(Icons.close, color: Colors.white, size: 16),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Basic information
//               const Text(
//                 'Informasi Dasar',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Nama Wisata',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Nama tidak boleh kosong';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 12),
              
//               // Modified Location field with dropdown
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     controller: _locationController,
//                     decoration: const InputDecoration(
//                       labelText: 'Kecamatan di Jember',
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.arrow_drop_down),
//                       hintText: 'Pilih atau ketik kecamatan...',
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Kecamatan tidak boleh kosong';
//                       }
//                       return null;
//                     },
//                     onChanged: (value) {
//                       _filterDistricts(value);
//                     },
//                     onTap: () {
//                       setState(() {
//                         _showDropdown = true;
//                         _filteredDistricts = _jemberDistricts;
//                       });
//                     },
//                   ),
//                   if (_showDropdown && _filteredDistricts.isNotEmpty)
//                     Container(
//                       margin: const EdgeInsets.only(top: 4),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[400]!),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       constraints: const BoxConstraints(maxHeight: 200),
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: _filteredDistricts.length,
//                         itemBuilder: (context, index) {
//                           final district = _filteredDistricts[index];
//                           return ListTile(
//                             dense: true,
//                             leading: const Icon(Icons.location_on, 
//                                              color: Colors.blue, size: 18),
//                             title: Text(district),
//                             onTap: () => _selectDistrict(district),
//                             hoverColor: Colors.grey[100],
//                           );
//                         },
//                       ),
//                     ),
//                 ],
//               ),
              
//               const Text(
//                 'Kategori Wisata',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _selectedCategory,
//                 decoration: const InputDecoration(
//                   border: OutlineInputBorder(),
//                 ),
//                 hint: const Text('Pilih Kategori'),
//                 items: [
//                   DropdownMenuItem(
//                     value: 'Pantai',
//                     child: Text('Pantai'),
//                   ),
//                   DropdownMenuItem(
//                     value: 'Air Terjun',
//                     child: Text('Air Terjun'),
//                   ),
//                   DropdownMenuItem(
//                     value: 'Pegunungan',
//                     child: Text('Pegunungan'),
//                   ),
//                 ],
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCategory = value;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null) {
//                     return 'Kategori wisata tidak boleh kosong';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _descriptionController,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   labelText: 'Deskripsi',
//                   alignLabelWithHint: true,
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Location Picker
//               const Text(
//                 'Koordinat Lokasi',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey[400]!),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (_selectedLocation != null) ...[
//                       Text(
//                         'Koordinat Saat Ini:',
//                         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
//                       ),
//                       const SizedBox(height: 4),
//                       Text('Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}'),
//                       Text('Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}'),
//                       const SizedBox(height: 12),
//                     ],
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: _showLocationPicker,
//                         icon: const Icon(Icons.map, size: 18),
//                         label: const Text('Pilih Lokasi di Peta'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Opening hours
//               const Text(
//                 'Jam Operasional',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _weekdaysHoursController,
//                 decoration: const InputDecoration(
//                   labelText: 'Jam Operasi Weekday',
//                   hintText: '06:00 - 17:00',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.access_time),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _weekendHoursController,
//                 decoration: const InputDecoration(
//                   labelText: 'Jam Operasi Weekend',
//                   hintText: '06:00 - 18:00',
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.access_time),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Pricing
//               const Text(
//                 'Harga Tiket',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Harga Weekday',
//                   prefixText: 'Rp. ',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Harga tidak boleh kosong';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   final formatted = _formatCurrency(value);
//                   if (formatted != value) {
//                     _priceController.value = _priceController.value.copyWith(
//                       text: formatted,
//                       selection: TextSelection.collapsed(offset: formatted.length),
//                     );
//                   }
//                 },
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _weekendPriceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Harga Weekend',
//                   prefixText: 'Rp. ',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Harga weekend tidak boleh kosong';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   final formatted = _formatCurrency(value);
//                   if (formatted != value) {
//                     _weekendPriceController.value = _weekendPriceController.value.copyWith(
//                       text: formatted,
//                       selection: TextSelection.collapsed(offset: formatted.length),
//                     );
//                   }
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Facilities
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Fasilitas',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   TextButton.icon(
//                     onPressed: _addFacility,
//                     icon: const Icon(Icons.add, size: 16),
//                     label: const Text('Tambah'),
//                     style: TextButton.styleFrom(foregroundColor: Colors.blue),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: List.generate(_facilities.length, (index) {
//                   return Chip(
//                     label: Text(_facilities[index]),
//                     deleteIcon: const Icon(Icons.close, size: 16),
//                     onDeleted: () => _removeFacility(index),
//                     backgroundColor: Colors.grey[200],
//                   );
//                 }),
//               ),
//               const SizedBox(height: 24),

//               // Save Button
//               SizedBox(
//                 height: 48,
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saveChanges,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     _isNewPlace ? 'Tambah Wisata' : 'Simpan Perubahan',
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Search result model class
// class SearchResult {
//   final double lat;
//   final double lon;
//   final String displayName;

//   SearchResult({
//     required this.lat,
//     required this.lon,
//     required this.displayName,
//   });

//   factory SearchResult.fromJson(Map<String, dynamic> json) {
//     return SearchResult(
//       lat: double.parse(json['lat']),
//       lon: double.parse(json['lon']),
//       displayName: json['display_name'] ?? '',
//     );
//   }
// }