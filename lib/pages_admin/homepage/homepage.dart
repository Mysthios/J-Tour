import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages_admin/place/add_place/add_place_page.dart';
import 'package:j_tour/pages_admin/place/edit_place/edit_place_page.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:j_tour/pages_admin/homepage/widgets/wisata_anda_card.dart';
import 'package:j_tour/pages_admin/homepage/widgets/weather_header.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _HomePageState();
}

const Color kPrimaryBlue = Color(0xFF0072BC);

class _HomePageState extends ConsumerState<AdminHomePage> {
  // Search and filter variables
  String searchQuery = "";
  String? selectedCategory;
  String sortBy = "name"; // name, rating, price
  bool isAscending = true;
  
  final List<String> categories = [
    "Populer",
    "Pantai",
    "Air Terjun",
    "Pegunungan"
  ];

  final List<String> sortOptions = [
    "Nama (A-Z)",
    "Nama (Z-A)",
    "Rating Tertinggi",
    "Rating Terendah",
    "Harga Termurah",
    "Harga Termahal"
  ];

  List<Place> get filteredAndSortedPlaces {
    // FIX 1: Use the correct provider name
    final placesState = ref.watch(placesProvider);
    final List<Place> places = placesState.places;
    List<Place> filtered = List.from(places);

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((place) =>
              place.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              place.location.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by category
    if (selectedCategory != null) {
      switch (selectedCategory) {
        case "Pantai":
          filtered = filtered
              .where((place) => place.category?.toLowerCase() == "pantai")
              .toList();
          break;
        case "Air Terjun":
          filtered = filtered
              .where((place) => place.category?.toLowerCase() == "air terjun")
              .toList();
          break;
        case "Pegunungan":
          filtered = filtered
              .where((place) => place.category?.toLowerCase() == "pegunungan")
              .toList();
          break;
        case "Populer":
          filtered = filtered.where((place) => (place.rating ?? 0) >= 4.5).toList();
          break;
      }
    }

    // Sort places
    filtered.sort((a, b) {
      int comparison = 0;
      switch (sortBy) {
        case "name":
          comparison = a.name.compareTo(b.name);
          break;
        case "rating":
          comparison = (a.rating ?? 0).compareTo(b.rating ?? 0);
          break;
        case "price":
          // FIX 2: Handle null values properly
          comparison = (a.price ?? 0).compareTo(b.price ?? 0);
          break;
      }
      return isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final places = filteredAndSortedPlaces;
    // FIX 3: Watch loading and error states properly
    final placesState = ref.watch(placesProvider);
    final isLoading = placesState.isLoading;
    final error = placesState.error;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.04;
    final logoHeight = screenHeight * 0.06;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: screenHeight * 0.10,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding * 0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/images/LabelAdmin.jpg',
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: horizontalPadding * 0.4),
                  child: SizedBox(
                    height: logoHeight * 0.9,
                    child: const WeatherHeader(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Fixed Search Bar and Categories Section
          Container(
            color: const Color(0xFFF6F6F6),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Search Bar dan Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Cari wisata...",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showFilterDialog,
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: kPrimaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.tune, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: screenHeight * 0.015),
                
                // Kategori Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      return GestureDetector(
                        onTap: () => setState(() {
                          selectedCategory = isSelected ? null : category;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? kPrimaryBlue : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kPrimaryBlue),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: kPrimaryBlue.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : kPrimaryBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.02),
                
                // Header dengan jumlah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Wisata Anda",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${places.length} wisata ditemukan",
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: screenHeight * 0.015),
                
                // Active Filters Chips
                if (selectedCategory != null || searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (selectedCategory != null)
                          Chip(
                            label: Text(selectedCategory!),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(() => selectedCategory = null),
                            backgroundColor: kPrimaryBlue.withOpacity(0.1),
                            labelStyle: const TextStyle(color: kPrimaryBlue),
                          ),
                        if (searchQuery.isNotEmpty)
                          Chip(
                            label: Text('"$searchQuery"'),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => setState(() => searchQuery = ""),
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            labelStyle: const TextStyle(color: Colors.orange),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.01),
                  
                  // FIX 4: Add loading and error handling
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (error != null)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.1),
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan: $error',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(placesProvider.notifier).refreshPlaces();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (places.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.1),
                          Icon(
                            searchQuery.isNotEmpty || selectedCategory != null
                                ? Icons.search_off
                                : Icons.location_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isNotEmpty || selectedCategory != null
                                ? 'Tidak ada wisata ditemukan'
                                : 'Belum ada tempat wisata',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (searchQuery.isNotEmpty || selectedCategory != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    searchQuery = "";
                                    selectedCategory = null;
                                  });
                                },
                                child: const Text('Reset Filter'),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: places.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: WisataAndaCard(place: places[index]),
                        );
                      },
                    ),
                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlaceDialog(context),
        backgroundColor: kPrimaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fixed Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = null;
                          searchQuery = "";
                          sortBy = "name";
                          isAscending = true;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              
              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories.map((category) {
                          final isSelected = selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = isSelected ? null : category;
                              });
                              setState(() {
                                selectedCategory = isSelected ? null : category;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? kPrimaryBlue : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kPrimaryBlue),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : kPrimaryBlue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Urutkan berdasarkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...sortOptions.map((option) {
                        String currentSort = "";
                        bool currentAscending = true;
                        
                        switch (option) {
                          case "Nama (A-Z)":
                            currentSort = "name";
                            currentAscending = true;
                            break;
                          case "Nama (Z-A)":
                            currentSort = "name";
                            currentAscending = false;
                            break;
                          case "Rating Tertinggi":
                            currentSort = "rating";
                            currentAscending = false;
                            break;
                          case "Rating Terendah":
                            currentSort = "rating";
                            currentAscending = true;
                            break;
                          case "Harga Termurah":
                            currentSort = "price";
                            currentAscending = true;
                            break;
                          case "Harga Termahal":
                            currentSort = "price";
                            currentAscending = false;
                            break;
                        }
                        
                        final isSelected = sortBy == currentSort && isAscending == currentAscending;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: RadioListTile<String>(
                            value: option,
                            groupValue: isSelected ? option : "",
                            onChanged: (value) {
                              setState(() {
                                sortBy = currentSort;
                                isAscending = currentAscending;
                              });
                              Navigator.pop(context);
                            },
                            title: Text(
                              option,
                              style: const TextStyle(fontSize: 14),
                            ),
                            activeColor: kPrimaryBlue,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Place place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus ${place.name}?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              // FIX 5: Handle async delete operation properly
              final success = await ref.read(placesProvider.notifier).deletePlace(place.id);
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${place.name} telah dihapus')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal menghapus tempat wisata'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<File?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<void> _showAddPlaceDialog(BuildContext context) async {
    // FIX 6: Remove unnecessary Place creation and navigate properly
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePlacePage(), // Add const
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tempat wisata berhasil ditambahkan')),
      );
    }
  }

  // // FIX 7: Uncomment and fix edit method if needed
  // Future<void> _showEditPlaceDialog(BuildContext context, Place place) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EditPlacePage(place: place),
  //     ),
  //   );

  //   if (result == true) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Tempat wisata berhasil diperbarui')),
  //     );
  //   }
  // }
}