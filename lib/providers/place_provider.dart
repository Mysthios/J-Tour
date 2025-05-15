import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/services/place_service.dart';
import '../models/place_model.dart';

// Provider for accessing the PlaceService instance
final placeServiceProvider = Provider<PlaceService>((ref) {
  return PlaceService();
});

// State notifier for handling Place operations
class PlacesNotifier extends StateNotifier<List<Place>> {
  final PlaceService _placeService;

  PlacesNotifier(this._placeService) : super([]) {
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    state = await _placeService.getPlaces();
  }

  Future<void> addPlace(Place place) async {
    state = await _placeService.addPlace(place);
  }

  Future<void> updatePlace(Place place) async {
    state = await _placeService.updatePlace(place);
  }

  Future<void> deletePlace(String id) async {
    state = await _placeService.deletePlace(id);
  }

  Future<String> saveImageLocally(File imageFile) async {
    return await _placeService.saveImageLocally(imageFile);
  }

  // Get a place by ID
  Place? getPlaceById(String id) {
    try {
      return state.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  // Force refresh a specific place to ensure we have latest data
  Future<Place?> refreshPlaceById(String id) async {
    await loadPlaces();
    return getPlaceById(id);
  }
}

// StateNotifierProvider for the places list
final placesNotifierProvider =
    StateNotifierProvider<PlacesNotifier, List<Place>>((ref) {
  final placeService = ref.watch(placeServiceProvider);
  return PlacesNotifier(placeService);
});

// Provider for selected place (for editing)
final selectedPlaceProvider = StateProvider<Place?>((ref) => null);
