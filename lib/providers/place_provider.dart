// lib/providers/place_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/services/place_service.dart';

// State for places list
class PlacesState {
  final List<Place> places;
  final bool isLoading;
  final String? error;

  const PlacesState({
    this.places = const [],
    this.isLoading = false,
    this.error,
  });

  PlacesState copyWith({
    List<Place>? places,
    bool? isLoading,
    String? error,
  }) {
    return PlacesState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Places Notifier
class PlacesNotifier extends StateNotifier<PlacesState> {
  PlacesNotifier() : super(const PlacesState()) {
    loadPlaces(); // Auto load places when provider is created
  }

  // Get place by ID from local state first, then from API if not found
  Future<Place?> getPlaceById(String id) async {
    try {
      // First, try to find in local state
      final localPlace = state.places.where((place) => place.id == id).firstOrNull;
      if (localPlace != null) {
        return localPlace;
      }
      
      // If not found locally, fetch from API
      final place = await ApiService.getPlaceById(id);
      
      // Update local state with the fetched place
      final updatedPlaces = [...state.places];
      final existingIndex = updatedPlaces.indexWhere((p) => p.id == id);
      if (existingIndex != -1) {
        updatedPlaces[existingIndex] = place;
      } else {
        updatedPlaces.add(place);
      }
      
      state = state.copyWith(places: updatedPlaces);
      return place;
    } catch (e) {
      print('Error getting place by ID: $e');
      return null;
    }
  }

  // Get place by ID synchronously from local state only
  Place? getPlaceByIdSync(String id) {
    try {
      return state.places.where((place) => place.id == id).firstOrNull;
    } catch (e) {
      print('Error getting place by ID sync: $e');
      return null;
    }
  }

  // Load all places
  Future<void> loadPlaces() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final places = await ApiService.getAllPlaces();
      state = state.copyWith(
        places: places,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load places by category
  Future<void> loadPlacesByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final places = await ApiService.getPlacesByCategory(category);
      state = state.copyWith(
        places: places,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add new place
  Future<bool> addPlace(Place place) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newPlace = await ApiService.createPlace(
        name: place.name,
        location: place.location,
        description: place.description ??'',
        weekdaysHours: place.weekdaysHours ??'',
        weekendHours: place.weekendHours ??'',
        price: place.price,
        weekendPrice: place.weekendPrice ??0,
        weekdayPrice: place.weekdayPrice ??0,
        category: place.category ?? '',
        facilities: place.facilities ?? [],
        latitude: place.latitude ?? 0.0,
        longitude: place.longitude ?? 0.0,
        mainImage: place.isLocalImage && place.image.isNotEmpty 
            ? File(place.image) 
            : null,
        additionalImages: (place.additionalImages ?? [])
            .map((path) => File(path))
            .toList(),
      );

      // Update local state
      final updatedPlaces = [...state.places, newPlace];
      state = state.copyWith(
        places: updatedPlaces,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Update place
  Future<bool> updatePlace(String id, Place place) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedPlace = await ApiService.updatePlace(
        id: id,
        name: place.name,
        location: place.location,
        description: place.description ??'',
        weekdaysHours: place.weekdaysHours ??'',
        weekendHours: place.weekendHours ??'',
        price: place.price,
        weekendPrice: place.weekendPrice ??0,
        weekdayPrice: place.weekdayPrice ??0,
        category: place.category ?? '',
        facilities: place.facilities ?? [],
        latitude: place.latitude ?? 0.0,
        longitude: place.longitude ?? 0.0,
        newImages: (place.additionalImages ?? [])
            .where((path) => path.startsWith('/'))  // Local file paths
            .map((path) => File(path))
            .toList(),
        existingImages: (place.additionalImages ?? [])
            .where((path) => path.startsWith('http'))  // URL paths
            .toList(),
      );

      // Update local state
      final updatedPlaces = state.places.map((p) => 
        p.id == id ? updatedPlace : p
      ).toList();
      
      state = state.copyWith(
        places: updatedPlaces,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Delete place
  Future<bool> deletePlace(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await ApiService.deletePlace(id);

      // Update local state
      final updatedPlaces = state.places.where((p) => p.id != id).toList();
      state = state.copyWith(
        places: updatedPlaces,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh places
  Future<void> refresh() async {
    await loadPlaces();
  }
}

// Provider
final placesNotifierProvider = StateNotifierProvider<PlacesNotifier, PlacesState>((ref) {
  return PlacesNotifier();
});

// Computed providers
final placesProvider = Provider<List<Place>>((ref) {
  return ref.watch(placesNotifierProvider).places;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(placesNotifierProvider).isLoading;
});

final errorProvider = Provider<String?>((ref) {
  return ref.watch(placesNotifierProvider).error;
});

// Provider for places by category
final placesByCategoryProvider = Provider.family<List<Place>, String?>((ref, category) {
  final places = ref.watch(placesProvider);
  if (category == null || category.isEmpty) {
    return places;
  }
  return places.where((place) => place.category == category).toList();
});