import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/homepage/widgets/place_card.dart';
import 'package:j_tour/pages/homepage/widgets/popular_place_card.dart';
import 'package:j_tour/pages/homepage/widgets/weather_header.dart';
import 'package:j_tour/pages/search/search_page.dart';
import 'package:j_tour/providers/place_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  final Function(String)? onNavigateToSearch;
  
  const HomePage({super.key, this.onNavigateToSearch});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load from API only
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(placesProvider.notifier).loadPlaces();
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToSearchPage(String category) {
    if (widget.onNavigateToSearch != null) {
      widget.onNavigateToSearch!(category);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExplorePage(initialCategory: category),
        ),
      );
    }
  }

  List<Place> get popularPlaces {
    final placesState = ref.watch(placesProvider);
    final places = placesState.places;
    return places.where((place) => (place.rating ?? 0) >= 4.0).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  }

  List<Place> get recommendedPlaces {
    final placesState = ref.watch(placesProvider);
    final places = placesState.places;
    // Sort by rating and return all places as recommendations
    return List.from(places)
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  }

  List<Place> get mountainPlaces {
    final placesState = ref.watch(placesProvider);
    final places = placesState.places;
    return places.where((place) => 
      place.category?.toLowerCase().contains('gunung') == true ||
      place.category?.toLowerCase().contains('pegunungan') == true ||
      place.name?.toLowerCase().contains('gunung') == true
    ).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  }

  List<Place> get waterfallPlaces {
    final placesState = ref.watch(placesProvider);
    final places = placesState.places;
    return places.where((place) => 
      place.category?.toLowerCase().contains('air terjun') == true ||
      place.category?.toLowerCase().contains('curug') == true ||
      place.name?.toLowerCase().contains('air terjun') == true ||
      place.name?.toLowerCase().contains('curug') == true
    ).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  }

  List<Place> get beachPlaces {
    final placesState = ref.watch(placesProvider);
    final places = placesState.places;
    return places.where((place) => 
      place.category?.toLowerCase().contains('pantai') == true ||
      place.category?.toLowerCase().contains('beach') == true ||
      place.name?.toLowerCase().contains('pantai') == true
    ).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
  }

  Widget _buildCategorySection({
    required String title,
    required String category,
    required List<Place> places,
    required bool isLoading,
    required String? error,
    required double screenHeight,
    required double titleFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToSearchPage(category),
              child: const Text("Lihat Semua"),
            ),
          ],
        ),
        
        // Loading indicator
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
                const SizedBox(height: 32),
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat $title',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(placesProvider.notifier).refreshPlaces();
                  },
                  child: const Text('Coba Lagi'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
        else if (places.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Belum ada $title',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: places.length,
            itemBuilder: (context, index) {
              return PlaceCard(place: places[index]);
            },
          ),
        
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final placesState = ref.watch(placesProvider);
    final isLoading = placesState.isLoading;
    final error = placesState.error;
    final places = placesState.places;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.045;
    final logoHeight = screenHeight * 0.06;
    final weatherHeight = screenHeight * 0.055;

    final popularPlacesList = popularPlaces;
    final recommendedPlacesList = recommendedPlaces;
    final mountainPlacesList = mountainPlaces;
    final waterfallPlacesList = waterfallPlaces;
    final beachPlacesList = beachPlaces;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: screenHeight * 0.11,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(left: horizontalPadding * 0.5, right: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Transform.translate(
                offset: const Offset(-5, 0),
                child: Image.asset(
                  'assets/images/Label.jpg',
                  height: logoHeight,
                ),
              ),
              SizedBox(
                height: weatherHeight,
                child: const WeatherHeader(),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(placesProvider.notifier).refreshPlaces();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              
              // Error handling for API
              if (error != null)
                Container(
                  margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gagal memuat data: $error',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(placesProvider.notifier).refreshPlaces();
                        },
                        child: const Text('Coba Lagi', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              // Popular Places Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Wisata Populer",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToSearchPage("Populer"),
                    child: const Text("Lihat Semua"),
                  ),
                ],
              ),

              // Loading indicator for popular places
              if (isLoading)
                Container(
                  height: screenHeight * 0.26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                Container(
                  height: screenHeight * 0.26,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gagal memuat wisata populer',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(placesProvider.notifier).refreshPlaces();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (popularPlacesList.isEmpty)
                Container(
                  height: screenHeight * 0.26,
                  child: const Center(
                    child: Text(
                      'Belum ada wisata populer',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                // GUNAKAN AutoCarouselPopularPlaces INSTEAD OF ListView.builder
                AutoCarouselPopularPlaces(
                  places: popularPlacesList,
                  autoScrollDuration: const Duration(seconds: 4), // Opsional: ubah durasi
                  animationDuration: const Duration(milliseconds: 800), // Opsional: ubah durasi animasi
                ),

              SizedBox(height: screenHeight * 0.02),
              
              // Recommended Places Section
              _buildCategorySection(
                title: "Rekomendasi Untuk Anda",
                category: "Rekomendasi",
                places: recommendedPlacesList,
                isLoading: isLoading,
                error: error,
                screenHeight: screenHeight,
                titleFontSize: titleFontSize,
              ),
              
              // Mountain Places Section
              _buildCategorySection(
                title: "Pegunungan",
                category: "Pegunungan",
                places: mountainPlacesList,
                isLoading: isLoading,
                error: error,
                screenHeight: screenHeight,
                titleFontSize: titleFontSize,
              ),
              
              // Waterfall Places Section
              _buildCategorySection(
                title: "Air Terjun",
                category: "Air Terjun",
                places: waterfallPlacesList,
                isLoading: isLoading,
                error: error,
                screenHeight: screenHeight,
                titleFontSize: titleFontSize,
              ),
              
              // Beach Places Section
              _buildCategorySection(
                title: "Pantai",
                category: "Pantai",
                places: beachPlacesList,
                isLoading: isLoading,
                error: error,
                screenHeight: screenHeight,
                titleFontSize: titleFontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}