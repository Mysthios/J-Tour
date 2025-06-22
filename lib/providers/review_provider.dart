

// providers/review_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

// State class untuk review
class ReviewState {
  final List<Review> reviews;
  final Review? userReview;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final Map<String, dynamic>? placeWithReviews;

  const ReviewState({
    this.reviews = const [],
    this.userReview,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.placeWithReviews,
  });

  ReviewState copyWith({
    List<Review>? reviews,
    Review? userReview,
    bool clearUserReview = false,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    Map<String, dynamic>? placeWithReviews,
    bool clearPlaceWithReviews = false,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      userReview: clearUserReview ? null : (userReview ?? this.userReview),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      placeWithReviews: clearPlaceWithReviews ? null : (placeWithReviews ?? this.placeWithReviews),
    );
  }

  // Computed getters
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }

  int get totalReviews => reviews.length;

  Map<int, int> get ratingDistribution {
    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }
}

// ReviewNotifier class
class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewService _reviewService = ReviewService();

  ReviewNotifier() : super(const ReviewState());

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Get reviews for a place
  Future<void> getReviewsByPlace(String placeId, {int? limit}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final reviews = await _reviewService.getReviewsByPlace(placeId, limit: limit);
      state = state.copyWith(reviews: reviews, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        reviews: [],
        isLoading: false,
      );
    }
  }

  // Get user's review for specific place
  Future<void> getUserReviewForPlace(String placeId, String userId) async {
    try {
      final userReview = await _reviewService.getUserReviewForPlace(placeId, userId);
      state = state.copyWith(userReview: userReview);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        clearUserReview: true,
      );
    }
  }

  // Create new review
  Future<bool> createReview({
    required String placeId,
    required String userId,
    required String userName,
    required int rating,
    String? comment,
    List<File>? images,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final newReview = await _reviewService.createReview(
        placeId: placeId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        images: images,
      );

      // Add the new review to the beginning of the list
      final updatedReviews = [newReview, ...state.reviews];
      state = state.copyWith(
        reviews: updatedReviews,
        userReview: newReview,
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSubmitting: false,
      );
      return false;
    }
  }

  // Update review
  Future<bool> updateReview({
    required String reviewId,
    required String userId,
    int? rating,
    String? comment,
    List<ReviewImage>? existingImages,
    List<File>? newImages,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final updatedReview = await _reviewService.updateReview(
        reviewId: reviewId,
        userId: userId,
        rating: rating,
        comment: comment,
        existingImages: existingImages,
        newImages: newImages,
      );

      // Update the review in the list
      final updatedReviews = state.reviews.map((review) {
        return review.id == reviewId ? updatedReview : review;
      }).toList();

      // Update user review if it's the same
      final updatedUserReview = state.userReview?.id == reviewId ? updatedReview : state.userReview;

      state = state.copyWith(
        reviews: updatedReviews,
        userReview: updatedUserReview,
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSubmitting: false,
      );
      return false;
    }
  }

  // Delete review
  Future<bool> deleteReview(String reviewId, String userId) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final success = await _reviewService.deleteReview(reviewId, userId);
      
      if (success) {
        // Remove the review from the list
        final updatedReviews = state.reviews.where((review) => review.id != reviewId).toList();
        
        // Clear user review if it's the same
        final clearUserReview = state.userReview?.id == reviewId;
        
        state = state.copyWith(
          reviews: updatedReviews,
          clearUserReview: clearUserReview,
          isSubmitting: false,
        );
      } else {
        state = state.copyWith(isSubmitting: false);
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSubmitting: false,
      );
      return false;
    }
  }

  // Get place with reviews  
  Future<void> fetchPlaceWithReviews(String placeId, {int? reviewLimit}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final placeWithReviews = await getPlaceWithReviews(placeId, reviewLimit: reviewLimit);
      
      List<Review> reviews = [];
      // Extract reviews from the response if available
      if (placeWithReviews['reviews'] != null) {
        final reviewsJson = placeWithReviews['reviews'] as List;
        reviews = reviewsJson.map((json) => Review.fromJson(json)).toList();
      }

      state = state.copyWith(
        placeWithReviews: placeWithReviews,
        reviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        clearPlaceWithReviews: true,
        reviews: [],
        isLoading: false,
      );
    }
  }

  // Refresh reviews
  Future<void> refreshReviews(String placeId, {int? limit}) async {
    await getReviewsByPlace(placeId, limit: limit);
  }

  // Load more reviews (for pagination)
  Future<void> loadMoreReviews(String placeId, {int? offset, int? limit}) async {
    if (state.isLoading) return;

    try {
      final moreReviews = await _reviewService.getReviewsByPlace(
        placeId, 
        limit: limit,
      );
      
      // Add new reviews to existing list (avoiding duplicates)
      final existingIds = state.reviews.map((r) => r.id).toSet();
      final newReviews = moreReviews.where((review) => !existingIds.contains(review.id)).toList();
      
      final updatedReviews = [...state.reviews, ...newReviews];
      state = state.copyWith(reviews: updatedReviews);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear all data
  void clearData() {
    state = const ReviewState();
  }

  // Reset state
  void reset() {
    clearData();
  }

  // Get reviews by rating filter
  List<Review> getReviewsByRating(int rating) {
    return state.reviews.where((review) => review.rating == rating).toList();
  }

  // Get reviews with images only
  List<Review> getReviewsWithImages() {
    return state.reviews.where((review) => 
      review.images != null && review.images!.isNotEmpty
    ).toList();
  }

  // Sort reviews
  void sortReviews(ReviewSortType sortType) {
    final sortedReviews = [...state.reviews];
    
    switch (sortType) {
      case ReviewSortType.newest:
        sortedReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSortType.oldest:
        sortedReviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ReviewSortType.highestRating:
        sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSortType.lowestRating:
        sortedReviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    
    state = state.copyWith(reviews: sortedReviews);
  }
}

// Provider declarations
final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier();
});

// Convenience providers for specific data
final reviewsProvider = Provider<List<Review>>((ref) {
  return ref.watch(reviewProvider).reviews;
});

final userReviewProvider = Provider<Review?>((ref) {
  return ref.watch(reviewProvider).userReview;
});

final reviewLoadingProvider = Provider<bool>((ref) {
  return ref.watch(reviewProvider).isLoading;
});

final reviewSubmittingProvider = Provider<bool>((ref) {
  return ref.watch(reviewProvider).isSubmitting;
});

final reviewErrorProvider = Provider<String?>((ref) {
  return ref.watch(reviewProvider).error;
});

final averageRatingProvider = Provider<double>((ref) {
  return ref.watch(reviewProvider).averageRating;
});

final totalReviewsProvider = Provider<int>((ref) {
  return ref.watch(reviewProvider).totalReviews;
});

final ratingDistributionProvider = Provider<Map<int, int>>((ref) {
  return ref.watch(reviewProvider).ratingDistribution;
});

// Enum for sorting options
enum ReviewSortType {
  newest,
  oldest,
  highestRating,
  lowestRating,
}