// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:j_tour/pages_admin/place/edit_place/edit_place_page.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:j_tour/models/place_model.dart';
// import 'package:j_tour/providers/place_provider.dart';

// import 'package:j_tour/pages/map/map_page.dart';
// import 'package:j_tour/pages/place/reviews_page.dart';

// class PlaceDetailPage extends ConsumerStatefulWidget {
//   final Place place;

//   const PlaceDetailPage({
//     super.key,
//     required this.place,
//   });

//   @override
//   ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
// }

// class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
//   int _currentImageIndex = 0;
//   late List<String> _images;
//   late Place _currentPlace;

//   @override
//   void initState() {
//     super.initState();
//     _currentPlace = widget.place;
//     _refreshImages();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Refresh data when the dependencies change (like coming back from an edit)
//     _updateCurrentPlace();
//   }

//   void _updateCurrentPlace() {
//     // Get the latest version of this place directly using the new provider method
//     final updatedPlace =
//         ref.read(placesNotifierProvider.notifier).getPlaceById(widget.place.id);

//     if (updatedPlace != null) {
//       // Always update to ensure we have the latest data
//       setState(() {
//         _currentPlace = updatedPlace;
//         _refreshImages();
//       });
//     }
//   }

//   void _refreshImages() {
//     // Initialize with the main image and any additional images (if available)
//     _images = [_currentPlace.image];
//     if (_currentPlace.additionalImages != null &&
//         _currentPlace.additionalImages!.isNotEmpty) {
//       _images.addAll(_currentPlace.additionalImages!);
//     }
//   }

//   void _navigateToEditPage() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditPlacePage(place: _currentPlace),
//       ),
//     );

//     if (result == true) {
//       // If the place was edited, force a refresh from provider
//       await _forceRefreshCurrentPlace();

//       // Show a success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Data tempat wisata berhasil diperbarui'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   Future<void> _forceRefreshCurrentPlace() async {
//     // Force a complete refresh of the data to ensure we have the latest version
//     final refreshedPlace = await ref
//         .read(placesNotifierProvider.notifier)
//         .refreshPlaceById(_currentPlace.id);

//     if (refreshedPlace != null && mounted) {
//       setState(() {
//         _currentPlace = refreshedPlace;
//         _refreshImages();
//       });
//     }
//   }

//   void _confirmDelete() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Konfirmasi Hapus'),
//         content: const Text('Anda yakin ingin menghapus tempat wisata ini?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           TextButton(
//             onPressed: () {
//               ref
//                   .read(placesNotifierProvider.notifier)
//                   .deletePlace(_currentPlace.id);
//               Navigator.pop(context); // Close dialog
//               Navigator.pop(context); // Close detail page
//             },
//             child: const Text('Hapus', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }



//   void _openWhatsApp() async {
//     // Use phone number from place model or default
//     final phone = _currentPlace.phoneNumber ?? "6281234567890";
//     final url = Uri.parse(
//         "https://wa.me/$phone?text=Halo, saya ingin bertanya tentang ${_currentPlace.name}");

//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Tidak dapat membuka WhatsApp")),
//       );
//     }
//   }

//   void _navigateToReviews() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReviewsPage(place: _currentPlace),
//       ),
//     );
//   }

//   void _navigateToMap() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MapPage(place: _currentPlace),
//       ),
//     );
//   }

//   Widget _buildImageContainer(String imagePath) {
//     try {
//       final bool isLocalImage = imagePath.startsWith('/') ||
//           imagePath.contains('\\') ||
//           imagePath.startsWith('file://');

//       if (isLocalImage) {
//         final file = File(imagePath);
//         if (file.existsSync()) {
//           return Image.file(
//             file,
//             width: double.infinity,
//             fit: BoxFit.cover,
//           );
//         }
//       } else {
//         return Image.asset(
//           imagePath,
//           width: double.infinity,
//           fit: BoxFit.cover,
//         );
//       }

//       return Container(
//         color: Colors.grey[300],
//         child: const Center(
//           child: Icon(
//             Icons.image_not_supported,
//             size: 80,
//             color: Colors.white70,
//           ),
//         ),
//       );
//     } catch (e) {
//       return Container(
//         color: Colors.grey[300],
//         child: const Center(
//           child: Icon(
//             Icons.broken_image,
//             size: 80,
//             color: Colors.white70,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Image Carousel with overlay buttons and indicators
//           Stack(
//             children: [
//               SizedBox(
//                 height: 280,
//                 child: CarouselSlider(
//                   options: CarouselOptions(
//                     height: 280,
//                     viewportFraction: 1.0,
//                     autoPlay: true,
//                     autoPlayInterval: Duration(seconds: 4),
//                     onPageChanged: (index, _) {
//                       setState(() => _currentImageIndex = index);
//                     },
//                   ),
//                   items: _images.map((imagePath) {
//                     return SizedBox(
//                       width: double.infinity,
//                       child: _buildImageContainer(imagePath),
//                     );
//                   }).toList(),
//                 ),
//               ),

//               // Top overlay buttons
//               SafeArea(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.4),
//                           shape: BoxShape.circle,
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.arrow_back,
//                               color: Colors.white, size: 20),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.4),
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.green.withOpacity(0.4),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               icon: const Icon(Icons.edit,
//                                   color: Colors.white, size: 20),
//                               onPressed: _navigateToEditPage,
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.red.withOpacity(0.4),
//                               shape: BoxShape.circle,
//                             ),
//                             child: IconButton(
//                               icon: const Icon(Icons.delete,
//                                   color: Colors.white, size: 20),
//                               onPressed: _confirmDelete,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Carousel indicators
//               if (_images.length > 1)
//                 Positioned(
//                   bottom: 16,
//                   left: 16,
//                   child: Row(
//                     children: _images.asMap().entries.map((entry) {
//                       return Container(
//                         width: _currentImageIndex == entry.key ? 20 : 6,
//                         height: 6,
//                         margin: const EdgeInsets.only(right: 4),
//                         decoration: BoxDecoration(
//                           color: _currentImageIndex == entry.key
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.4),
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//             ],
//           ),

//           // Content Area
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Main Info Card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Title and Location
//                         Text(
//                           _currentPlace.name,
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 6),

//                         Row(
//                           children: [
//                             Icon(Icons.location_on,
//                                 size: 16, color: Colors.grey[600]),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 _currentPlace.location,
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),

//                         // Rating and Review (Admin can only view, not write)
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: _navigateToReviews,
//                               child: Row(
//                                 children: [
//                                   Icon(Icons.star,
//                                       color: Colors.orange, size: 16),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     "${_currentPlace.rating != null ? _currentPlace.rating!.toStringAsFixed(1) : '0.0'}",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                   Text(
//                                     " (438 Ulasan)",
//                                     style: TextStyle(
//                                       color: Colors.grey[600],
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const Spacer(),
//                             // Admin badge instead of write review button
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(4),
//                                 border: Border.all(
//                                     color: Colors.orange.withOpacity(0.3)),
//                               ),
//                               child: const Text(
//                                 "Admin View",
//                                 style: TextStyle(
//                                   color: Colors.orange,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // Schedule and Price Cards (using actual data from model)
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[50],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Weekdays:",
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.grey[700],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.access_time,
//                                             size: 12, color: Colors.grey[600]),
//                                         const SizedBox(width: 4),
//                                         Expanded(
//                                           child: Text(
//                                             _currentPlace.weekdaysHours ??
//                                                 "06:00 - 17:00",
//                                             style:
//                                                 const TextStyle(fontSize: 11),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       "Rp.${_currentPlace.price}",
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.blue,
//                                       ),
//                                     ),
//                                     Text(
//                                       "/Orang",
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Container(
//                                 padding: const EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[50],
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Weekend:",
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.grey[700],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.access_time,
//                                             size: 12, color: Colors.grey[600]),
//                                         const SizedBox(width: 4),
//                                         Expanded(
//                                           child: Text(
//                                             _currentPlace.weekendHours ??
//                                                 "06:00 - 18:00",
//                                             style:
//                                                 const TextStyle(fontSize: 11),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       "Rp.${_currentPlace.weekendPrice ?? (_currentPlace.price + 15000)}",
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.blue,
//                                       ),
//                                     ),
//                                     Text(
//                                       "/Orang",
//                                       style: TextStyle(
//                                         fontSize: 10,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // // Contact Button
//                         // SizedBox(
//                         //   width: double.infinity,
//                         //   child: ElevatedButton.icon(
//                         //     onPressed: _openWhatsApp,
//                         //     icon: const Icon(Icons.phone,
//                         //         color: Colors.white, size: 16),
//                         //     label: Text(
//                         //       _currentPlace.phoneNumber != null
//                         //           ? "Hubungi (${_currentPlace.phoneNumber})"
//                         //           : "Hubungi",
//                         //       style: const TextStyle(
//                         //         color: Colors.white,
//                         //         fontWeight: FontWeight.w600,
//                         //         fontSize: 14,
//                         //       ),
//                         //     ),
//                         //     style: ElevatedButton.styleFrom(
//                         //       backgroundColor: Colors.blue,
//                         //       padding: const EdgeInsets.symmetric(vertical: 12),
//                         //       shape: RoundedRectangleBorder(
//                         //         borderRadius: BorderRadius.circular(8),
//                         //       ),
//                         //       elevation: 0,
//                         //     ),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ),

//                   // Description Section
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Deskripsi",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _currentPlace.description ??
//                               "Pantai Papuma adalah sebuah pantai yang menjadi tempat wisata di Kabupaten Jember, Provinsi Jawa Timur, Indonesia. Nama Papuma sendiri sebenarnya adalah singkatan dari \"Pasir Putih Malikan\".",
//                           style: const TextStyle(
//                             height: 1.4,
//                             fontSize: 13,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Facilities Section
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Fasilitas",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         // Facilities from model data
//                         if (_currentPlace.facilities != null &&
//                             _currentPlace.facilities!.isNotEmpty)
//                           Wrap(
//                             spacing: 16,
//                             runSpacing: 8,
//                             children: _currentPlace.facilities!.map((facility) {
//                               return Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.check_circle,
//                                     size: 14,
//                                     color: Colors.blue,
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     facility,
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
//                           )
//                         else
//                           Wrap(
//                             spacing: 16,
//                             runSpacing: 8,
//                             children: [
//                               "Area Parkir",
//                               "Toilet dan Kamar Mandi",
//                               "Mushola",
//                               "Warung Makan",
//                               "Area Camping",
//                               "Penginapan"
//                             ].map((facility) {
//                               return Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.check_circle,
//                                       size: 14, color: Colors.blue),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     facility,
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Direction Button
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: ElevatedButton.icon(
//                       onPressed: _navigateToMap,
//                       icon: const Icon(Icons.navigation,
//                           color: Colors.white, size: 18),
//                       label: const Text(
//                         "Petunjuk Arah",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black87,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         elevation: 0,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Admin Action Buttons
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _navigateToEditPage,
//                             icon: const Icon(Icons.edit,
//                                 color: Colors.white, size: 18),
//                             label: const Text(
//                               "Edit Wisata",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 0,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _confirmDelete,
//                             icon: const Icon(Icons.delete,
//                                 color: Colors.white, size: 18),
//                             label: const Text(
//                               "Hapus Wisata",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               elevation: 0,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
