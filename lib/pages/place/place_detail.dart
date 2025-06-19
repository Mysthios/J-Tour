// pages/place/place_detail_page.dart - REFACTORED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/providers/place_provider.dart';
import 'package:j_tour/pages/place/reviews_page.dart';
import 'package:j_tour/pages/place/write_review_page.dart';
import 'package:j_tour/pages/map/map_page.dart';
import 'widgets/user_place_image_carousel.dart';
import 'widgets/user_place_info_card.dart';
import 'widgets/user_place_description_section.dart';
import 'widgets/user_place_facilities_section.dart';
import 'widgets/user_place_action_buttons.dart';

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentPlace();
  }

  void _updateCurrentPlace() async {
    final updatedPlace = await ref.read(placesProvider.notifier).getPlaceById(widget.place.id);
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
    );
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          UserPlaceImageCarousel(
            key: _imageCarouselKey,
            place: _currentPlace,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserPlaceInfoCard(
                    place: _currentPlace,
                    onReviewsTap: _navigateToReviews,
                    onWriteReviewTap: _navigateToWriteReview,
                  ),
                  UserPlaceDescriptionSection(place: _currentPlace),
                  UserPlaceFacilitiesSection(place: _currentPlace),
                  const SizedBox(height: 24),
                  UserPlaceActionButtons(
                    onDirections: _navigateToMap,
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