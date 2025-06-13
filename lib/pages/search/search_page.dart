import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/place/place_detail.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  final String? initialCategory; // Add parameter for initial category

  const SearchPage({super.key, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

const Color kPrimaryBlue = Color(0xFF0072BC);

class _SearchPageState extends State<SearchPage> {
  int _currentIndex = 1;
  final List<String> categories = [
    "Populer",
    "Rekomendasi",
    "Pantai",
    "Air Terjun",
    "Pegunungan"
  ];
  
  // Search and filter variables
  String? selectedCategory; // Initially no category is selected
  String searchQuery = "";
  String sortBy = "name"; // name, rating, price
  bool isAscending = true;
  
  List<Place> allPlaces = [];
  bool isLoading = true;

  final List<String> sortOptions = [
    "Nama (A-Z)",
    "Nama (Z-A)",
    "Rating Tertinggi",
    "Rating Terendah",
    "Harga Termurah",
    "Harga Termahal"
  ];

  @override
  void initState() {
    super.initState();
    // Set initial category if provided, but don't auto-select on first load
    // selectedCategory = widget.initialCategory;
    loadPlacesData();
  }

  Future<void> loadPlacesData() async {
    try {
      // Load JSON data from assets
      final String response = await rootBundle.loadString('assets/places.json');
      final List<dynamic> data = json.decode(response);

      setState(() {
        allPlaces = data.map((placeJson) => Place.fromJson(placeJson)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading places data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _currentIndex = index);
  }

  List<Place> get filteredPlaces {
    List<Place> filtered = List.from(allPlaces);

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
          // Show popular places (rating >= 4.5)
          filtered = filtered.where((place) => place.rating != null && place.rating! >= 4.5).toList();
          break;
        case "Rekomendasi":
          // Show recommended places (rating >= 4.0)
          filtered = filtered.where((place) => place.rating != null && place.rating! >= 4.0).toList();
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
          comparison = a.price.compareTo(b.price);
          break;
      }
      return isAscending ? comparison : -comparison;
    });

    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        title: const Text(
          "Eksplor Wisata",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar & filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                              hintText: "Cari",
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
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 📂 Kategori scrollable
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
                      // Toggle selection - if already selected, deselect it
                      selectedCategory = isSelected ? null : category;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimaryBlue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kPrimaryBlue),
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
            const SizedBox(height: 16),

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

            // Header dengan jumlah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Destinasi Wisata",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${filteredPlaces.length} destinasi ditemukan",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🧾 List destinasi
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryBlue),
                      ),
                    )
                  : filteredPlaces.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                                    ? 'Tidak ada destinasi ditemukan'
                                    : 'Belum ada destinasi wisata',
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
                      : _buildPlacesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList() {
    // For all categories, use the same layout - vertical list
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filteredPlaces.length,
      itemBuilder: (context, index) {
        final place = filteredPlaces[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: DestinationCard(
            place: place,
          ),
        );
      },
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Place place;

  const DestinationCard({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(place: place),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Container untuk gambar
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 140,
                maxHeight: 200, // Batas maksimal tinggi
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  place.image,
                  width: double.infinity,
                  fit: BoxFit
                      .fitWidth, // Fit width agar gambar tidak terpotong horizontal
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Informasi tempat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama dan Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            formatter.format(place.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: kPrimaryBlue,
                            ),
                          ),
                          const Text(
                            '/Orang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.location,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${place.rating}",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}