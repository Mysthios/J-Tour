import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/services/place_service.dart';
import '../models/place_model.dart';

/// Provider untuk instance PlaceService
final placeServiceProvider = Provider<PlaceService>((ref) {
  return PlaceService();
});

/// StateNotifier untuk mengelola data Place
class PlacesNotifier extends StateNotifier<List<Place>> {
  final PlaceService _placeService;

  PlacesNotifier(this._placeService) : super([]) {
    _init();
  }

  /// Load semua place saat inisialisasi
  Future<void> _init() async {
    await loadPlaces();
  }

  /// Memuat semua place dari service
  Future<void> loadPlaces() async {
    try {
      final places = await _placeService.getPlaces();
      state = places;

      // Debug
      print('=== DEBUG: Loaded ${places.length} Places ===');
      for (var place in places) {
        print('Place: ${place.name} - ID: ${place.id}');
      }
      print('=== END DEBUG ===');
    } catch (e) {
      print('Error loading places: $e');
      state = [];
    }
  }

  /// Tambah place baru
  Future<void> addPlace(Place place) async {
    try {
      final updatedList = await _placeService.addPlace(place);
      state = updatedList;
      print('DEBUG: Added place - ${place.name}');
    } catch (e) {
      print('Error adding place: $e');
    }
  }

  /// Update place
  Future<void> updatePlace(Place place) async {
    try {
      final updatedList = await _placeService.updatePlace(place);
      state = updatedList;
      print('DEBUG: Updated place - ${place.name}');
    } catch (e) {
      print('Error updating place: $e');
    }
  }

  /// Hapus place
  Future<void> deletePlace(String id) async {
    try {
      final updatedList = await _placeService.deletePlace(id);
      state = updatedList;
      print('DEBUG: Deleted place with ID: $id');
    } catch (e) {
      print('Error deleting place: $e');
    }
  }

  /// Simpan gambar secara lokal
  Future<String> saveImageLocally(File imageFile) async {
    return await _placeService.saveImageLocally(imageFile);
  }

  /// Ambil place berdasarkan ID
  Place? getPlaceById(dynamic id) {
    try {
      final place = state.firstWhere((place) => place.id.toString() == id.toString());
      return place;
    } catch (e) {
      print('DEBUG: Place not found with ID: $id');
      return null;
    }
  }


  /// Force refresh satu place berdasarkan ID
  Future<Place?> refreshPlaceById(String id) async {
    await loadPlaces();
    return getPlaceById(id);
  }

  /// Refresh semua data place
  Future<void> forceRefresh() async {
    await loadPlaces();
  }

  /// Debug print semua place
  void debugPrintAllPlaces() {
    print('=== DEBUG: All Places in State ===');
    for (var place in state) {
      print('Name: ${place.name}, ID: ${place.id}, Location: ${place.location}');
    }
    print('=== END DEBUG ===');
  }
}

/// Provider untuk PlacesNotifier
final placesNotifierProvider =
    StateNotifierProvider<PlacesNotifier, List<Place>>((ref) {
  final placeService = ref.watch(placeServiceProvider);
  return PlacesNotifier(placeService);
});

/// Provider untuk selected place (biasanya untuk edit/update)
final selectedPlaceProvider = StateProvider<Place?>((ref) => null);
/// Provider untuk mendapatkan Place berdasarkan ID
final placeByIdProvider = Provider.family<Place?, dynamic>((ref, dynamic id) {
  final places = ref.watch(placesNotifierProvider);
  
  try {
    final place = places.firstWhere((place) => place.id.toString() == id.toString());
    return place;
  } catch (e) {
    print('DEBUG: Place with ID $id not found');
    return null;
  }
});

