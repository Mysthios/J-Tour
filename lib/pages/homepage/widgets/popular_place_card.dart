import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/place/place_detail.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:intl/intl.dart';

class AutoCarouselPopularPlaces extends ConsumerStatefulWidget {
  final List<Place> places;
  final Duration autoScrollDuration;
  final Duration animationDuration;

  const AutoCarouselPopularPlaces({
    super.key,
    required this.places,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  ConsumerState<AutoCarouselPopularPlaces> createState() => _AutoCarouselPopularPlacesState();
}

class _AutoCarouselPopularPlacesState extends ConsumerState<AutoCarouselPopularPlaces>
    with WidgetsBindingObserver {
  PageController? _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  bool _isUserInteracting = false;
  bool _isDisposed = false;
  
  List<Place>? _infinitePlaces;
  static const int _multiplier = 10000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    print('=== CAROUSEL INIT DEBUG ===');
    print('Places count: ${widget.places.length}');
    print('Auto scroll duration: ${widget.autoScrollDuration}');
    print('Initial _isUserInteracting: $_isUserInteracting');
    print('===========================');
    
    _initializeInfinitePlaces();
    
    if (widget.places.isNotEmpty && _infinitePlaces != null) {
      _initializePageController();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('App lifecycle state changed: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('App resumed - restarting auto scroll');
        _resetUserInteractionAndRestart();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        print('App paused/inactive/hidden - stopping auto scroll');
        _stopAutoScroll();
        break;
      case AppLifecycleState.detached:
        print('App detached - stopping auto scroll');
        _stopAutoScroll();
        break;
    }
  }

  void _initializeInfinitePlaces() {
    if (widget.places.isEmpty) {
      _infinitePlaces = [];
      return;
    }
    
    _infinitePlaces = List.generate(
      widget.places.length * _multiplier, 
      (index) => widget.places[index % widget.places.length]
    );
    
    print('Infinite places initialized with ${_infinitePlaces!.length} items');
  }

  void _initializePageController() {
    if (_infinitePlaces == null || _infinitePlaces!.isEmpty) {
      return;
    }
    
    final initialPage = (_infinitePlaces!.length / 2).floor();
    
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: initialPage,
    );
    
    _currentIndex = initialPage;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isDisposed && widget.places.isNotEmpty && _pageController != null) {
          print('POST FRAME CALLBACK: Starting auto scroll');
          print('PageController hasClients: ${_pageController!.hasClients}');
          _startAutoScroll();
        }
      });
    });
  }

  @override
  void didUpdateWidget(AutoCarouselPopularPlaces oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.places != widget.places) {
      print('Places updated, reinitializing...');
      _stopAutoScroll();
      
      _initializeInfinitePlaces();
      
      _pageController?.dispose();
      _pageController = null;
      
      if (widget.places.isNotEmpty && _infinitePlaces != null) {
        _initializePageController();
      }
    }
  }

  @override
  void dispose() {
    print('=== DISPOSING CAROUSEL ===');
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _timer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _resetUserInteractionAndRestart() {
    if (_isDisposed || !mounted) return;
    
    setState(() {
      _isUserInteracting = false;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        _startAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _timer?.cancel();
    
    print('=== AUTO SCROLL START ===');
    print('Places count: ${widget.places.length}');
    print('User interacting: $_isUserInteracting');
    print('PageController hasClients: ${_pageController?.hasClients ?? false}');
    print('Widget mounted: $mounted');
    print('Is disposed: $_isDisposed');
    print('========================');
    
    if (_isDisposed || !mounted || widget.places.isEmpty || _pageController == null) {
      print('Cannot start auto scroll - widget not ready');
      return;
    }
    
    _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
      print('=== TIMER TICK ===');
      print('User interacting: $_isUserInteracting');
      print('Places count: ${widget.places.length}');
      print('Mounted: $mounted');
      print('Disposed: $_isDisposed');
      print('HasClients: ${_pageController?.hasClients ?? false}');
      print('================');
      
      if (!_isUserInteracting && 
          widget.places.isNotEmpty && 
          mounted && 
          !_isDisposed &&
          _pageController != null &&
          _pageController!.hasClients) {
        print('✅ CONDITIONS MET - Moving to next page');
        _nextPage();
      } else {
        print('❌ CONDITIONS NOT MET - Skipping');
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
    print('Auto scroll stopped');
  }

  void _nextPage() {
    print('=== NEXT PAGE EXECUTION ===');
    print('Current index: $_currentIndex');
    print('Total infinite places: ${_infinitePlaces?.length ?? 0}');
    print('PageController hasClients: ${_pageController?.hasClients ?? false}');
    
    if (_pageController == null || !_pageController!.hasClients || _infinitePlaces == null) {
      print('❌ PageController or infinitePlaces not ready');
      return;
    }
    
    final nextIndex = _currentIndex + 1;
    
    if (nextIndex >= _infinitePlaces!.length - 100) {
      final middleIndex = (_infinitePlaces!.length / 2).floor();
      _pageController!.jumpToPage(middleIndex);
      _currentIndex = middleIndex;
      print('↻ Reset to middle position: $middleIndex');
      return;
    }
    
    print('Next index will be: $nextIndex');
    
    try {
      _pageController!.animateToPage(
        nextIndex,
        duration: widget.animationDuration,
        curve: Curves.easeInOutCubic,
      ).then((_) {
        print('✅ Page animation completed to index: $nextIndex');
        if (mounted) {
          setState(() {
            _currentIndex = nextIndex;
          });
        }
      }).catchError((error) {
        print('❌ Page animation error: $error');
      });
    } catch (e) {
      print('❌ Exception during animateToPage: $e');
    }
    
    print('=========================');
  }

  void _onUserInteractionStart() {
    print('User interaction START');
    setState(() {
      _isUserInteracting = true;
    });
    _stopAutoScroll();
  }

  void _onUserInteractionEnd() {
    print('User interaction END - will resume auto scroll in 2 seconds');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isDisposed) {
        print('Resuming auto scroll after user interaction');
        setState(() {
          _isUserInteracting = false;
        });
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty || _infinitePlaces == null || _pageController == null) {
      return const SizedBox.shrink();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.26;

    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          if (mounted && _infinitePlaces != null) {
            setState(() {
              _currentIndex = index;
            });
            print('Page changed to: $index (Place: ${_infinitePlaces![index % widget.places.length].name})');
          }
        },
        itemCount: _infinitePlaces!.length,
        itemBuilder: (context, index) {
          if (_infinitePlaces == null || index >= _infinitePlaces!.length) {
            return const SizedBox.shrink();
          }
          
          final place = _infinitePlaces![index];
          
          return GestureDetector(
            onPanStart: (_) => _onUserInteractionStart(),
            onPanEnd: (_) => _onUserInteractionEnd(),
            onTapDown: (_) => _onUserInteractionStart(),
            child: AnimatedBuilder(
              animation: _pageController!,
              builder: (context, child) {
                double value = 0.0;
                if (_pageController!.position.haveDimensions) {
                  value = index.toDouble() - (_pageController!.page ?? 0);
                  value = (value * 0.038).clamp(-1, 1);
                }
                
                return Transform.translate(
                  offset: Offset(0, value * 10),
                  child: Transform.scale(
                    scale: 1.0 - (value.abs() * 0.05),
                    child: PopularPlaceCard(
                      place: place,
                      onTap: () => _onCardTap(place),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _onCardTap(Place place) async {
    _onUserInteractionStart();
    
    print('=== POPULAR CARD TAP DEBUG ===');
    print('Card tapped: ${place.name}');
    print('Place ID: ${place.id}');
    print('=== END POPULAR CARD TAP DEBUG ===');

    try {
      final latestPlace = await ref.read(placesProvider.notifier).getPlaceById(place.id);

      if (context.mounted) {
        final Place placeToNavigate = latestPlace ?? place;
        
        print('DEBUG: Navigating with place: ${placeToNavigate.name}');
        
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(place: placeToNavigate),
          ),
        );
        
        print('=== RETURNED FROM NAVIGATION ===');
        print('Navigation result: $result');
        
        _resetUserInteractionAndRestart();
      }
    } catch (e) {
      print('Error fetching latest place data: $e');
      if (context.mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailPage(place: place),
          ),
        );
        
        print('=== RETURNED FROM NAVIGATION (ERROR CASE) ===');
        print('Navigation result: $result');
        
        _resetUserInteractionAndRestart();
      }
    }
  }
}

// SOLUSI 1: Menggunakan Consumer untuk setiap card
class PopularPlaceCard extends ConsumerWidget {
  final Place place;
  final VoidCallback? onTap;

  const PopularPlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // KUNCI: Watch provider untuk mendapatkan data terbaru
    final placesState = ref.watch(placesProvider);

    // Cari place yang sama dengan ID yang sama dari state terbaru
    Place currentPlace = place;
    if (placesState is AsyncData<List<Place>>) {
      final places = (placesState as AsyncData<List<Place>>).value;
      final updatedPlace = places.firstWhere(
        (p) => p.id == place.id,
        orElse: () => place,
      );
      currentPlace = updatedPlace;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = screenWidth * 0.8;
    final cardHeight = screenHeight * 0.26;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp.',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: _buildImage(currentPlace),
              ),
              
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Rating yang akan update secara real-time
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentPlace.rating?.toStringAsFixed(1) ?? '0.0'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (currentPlace.category != null && currentPlace.category!.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0072BC).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentPlace.category!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentPlace.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              currentPlace.location,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                shadows: const [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentPlace.price != null && currentPlace.price! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                currencyFormatter.format(currentPlace.price!),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'GRATIS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'POPULER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildImage(Place currentPlace) {
    print('=== POPULAR CARD IMAGE DEBUG ===');
    print('Image path: ${currentPlace.image}');
    print('Is Local Image: ${currentPlace.isLocalImage}');
    print('=== END POPULAR CARD IMAGE DEBUG ===');

    if (!currentPlace.isLocalImage && _isValidUrl(currentPlace.image)) {
      return Image.network(
        currentPlace.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingImage();
        },
        errorBuilder: (context, error, stackTrace) {
          print('Network image error: $error');
          return _buildErrorImage();
        },
      );
    }
    else if (currentPlace.isLocalImage && currentPlace.image.isNotEmpty) {
      return Image.file(
        File(currentPlace.image),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('File image error: $error');
          return _buildErrorImage();
        },
      );
    }
    else if (!currentPlace.isLocalImage && !_isValidUrl(currentPlace.image) && currentPlace.image.isNotEmpty) {
      return Image.asset(
        currentPlace.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Asset image error: $error');
          return _buildErrorImage();
        },
      );
    }
    else {
      return _buildErrorImage();
    }
  }

  Widget _buildLoadingImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0072BC)),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape,
            color: Colors.grey[500],
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Gambar tidak tersedia',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}