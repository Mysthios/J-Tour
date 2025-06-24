// pages/place/place_detail_page.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:j_tour/providers/review_provider.dart';
import 'package:j_tour/providers/saved_provider.dart'; // Add this import
import 'package:j_tour/pages/place/reviews_page.dart';
import 'package:j_tour/pages/place/write_review_page.dart';
import 'package:j_tour/pages/map/map_page.dart';
import 'widgets/user_place_image_carousel.dart';
import 'widgets/user_place_info_card.dart';
import 'widgets/user_place_description_section.dart';
import 'widgets/user_place_facilities_section.dart';
import 'widgets/user_place_action_buttons.dart';
import 'package:j_tour/pages/place/review%20page/user_place_reviews_section.dart';

class PlaceDetailPage extends ConsumerStatefulWidget {
  final Place place;

  const PlaceDetailPage({
    super.key,
    required this.place,
  });

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
  late Place _currentPlace;
  Key _imageCarouselKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _currentPlace = widget.place;

    // Load reviews when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
      _initializeUserId();
    });
  }

  void _initializeUserId() {
    // Initialize userId - you should get this from your auth provider
    // For now, using a placeholder - replace with actual auth logic
    const String currentUserId = 'user123'; // Replace with actual user ID from auth
    ref.read(userIdProvider.notifier).state = currentUserId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentPlace();
  }

  void _loadReviews() {
    // Load reviews for this place (limit to 3 for preview)
    ref
        .read(reviewProvider.notifier)
        .getReviewsByPlace(_currentPlace.id, limit: 3);
  }

  void _updateCurrentPlace() async {
    final updatedPlace =
        await ref.read(placesProvider.notifier).getPlaceById(widget.place.id);
    if (updatedPlace != null && mounted) {
      setState(() {
        _currentPlace = updatedPlace;
        _imageCarouselKey = UniqueKey();
      });
    }
  }

  void _navigateToReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsPage(place: _currentPlace),
      ),
    );
  }

  void _navigateToWriteReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteReviewPage(place: _currentPlace),
      ),
    ).then((_) {
      // Refresh reviews after writing a review
      _loadReviews();
    });
  }

  void _navigateToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(place: _currentPlace),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          UserPlaceImageCarousel(
            key: _imageCarouselKey,
            place: _currentPlace,
            userId: userId, // Add the required userId parameter
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserPlaceInfoCard(
                    place: _currentPlace,
                    onWriteReviewTap: _navigateToWriteReview,
                  ),
                  UserPlaceDescriptionSection(place: _currentPlace),
                  
                  // Added spacing between description and facilities
                  const SizedBox(height: 20),
                  
                  UserPlaceFacilitiesSection(place: _currentPlace),
                  const SizedBox(height: 24),
                  UserPlaceActionButtons(
                    onDirections: _navigateToMap,
                  ),
                  const SizedBox(height: 24),

                  // Reviews Section
                  UserPlaceReviewsSection(
                    place: _currentPlace,
                    reviews: reviewState.reviews,
                    averageRating: reviewState.averageRating,
                    totalReviews: reviewState.totalReviews,
                    isLoading: reviewState.isLoading,
                    onSeeAllReviews: _navigateToReviews,
                    onWriteReview: _navigateToWriteReview,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}