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
      final localPlace =
          state.places.where((place) => place.id == id).firstOrNull;
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
      print('Error loading places: $e');
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
      print('Error loading places by category: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add new place - IMPROVED ERROR HANDLING
 // Fixed addPlace method in PlacesNotifier
Future<bool> addPlace(Place place) async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    print('=== PROVIDER ADD PLACE DEBUG ===');
    print('Starting to add place: ${place.name}');
    
    // Validate required fields
    if (place.name.trim().isEmpty) {
      throw Exception('Nama tempat wisata harus diisi');
    }
    if (place.location.trim().isEmpty) {
      throw Exception('Lokasi harus diisi');
    }
    if (place.category == null || place.category!.trim().isEmpty) {
      throw Exception('Kategori harus dipilih');
    }
    if (place.latitude == null || place.longitude == null) {
      throw Exception('Koordinat lokasi harus diisi');
    }
    
    // PERBAIKAN: Prepare main image dengan validasi yang lebih ketat
    File? mainImageFile;
    if (place.isLocalImage && place.image.isNotEmpty) {
      mainImageFile = File(place.image);
      print('Preparing main image: ${mainImageFile.path}');
      
      // Verify file exists dan readable
      bool exists = await mainImageFile.exists();
      if (!exists) {
        throw Exception('File gambar utama tidak ditemukan: ${mainImageFile.path}');
      }
      
      // Check file size (optional)
      int fileSize = await mainImageFile.length();
      print('Main image file size: $fileSize bytes');
      
      if (fileSize == 0) {
        throw Exception('File gambar utama kosong atau corrupt');
      }
    } else {
      print('No main image provided');
      // Uncomment baris di bawah jika gambar utama wajib
      // throw Exception('Gambar utama harus dipilih');
    }

    // PERBAIKAN: Prepare additional images dengan validasi
    List<File> additionalImageFiles = [];
    if (place.additionalImages != null && place.additionalImages!.isNotEmpty) {
      print('Processing ${place.additionalImages!.length} additional images');
      
      for (int i = 0; i < place.additionalImages!.length; i++) {
        String path = place.additionalImages![i];
        File file = File(path);
        
        bool exists = await file.exists();
        if (exists) {
          int fileSize = await file.length();
          if (fileSize > 0) {
            additionalImageFiles.add(file);
            print('Additional image $i prepared: ${file.path} (${fileSize} bytes)');
          } else {
            print('Additional image $i is empty: $path');
          }
        } else {
          print('Additional image $i not found: $path');
        }
      }
    }

    print('Final image count - Main: ${mainImageFile != null ? 1 : 0}, Additional: ${additionalImageFiles.length}');

    // PERBAIKAN: Call API dengan parameter yang benar
    final newPlace = await ApiService.createPlace(
      name: place.name.trim(),
      location: place.location.trim(),
      description: place.description?.trim() ?? '',
      weekdaysHours: place.weekdaysHours?.trim() ?? '',
      weekendHours: place.weekendHours?.trim() ?? '',
      price: place.price ?? 0,
      weekendPrice: place.weekendPrice ?? 0,
      weekdayPrice: place.weekdayPrice ?? 0,
      category: place.category!.trim(),
      facilities: place.facilities ?? [],
      latitude: place.latitude!,
      longitude: place.longitude!,
      mainImage: mainImageFile, // Pastikan parameter name sesuai
      additionalImages: additionalImageFiles.isNotEmpty ? additionalImageFiles : null,
    );

    print('Place created successfully: ${newPlace.id}');

    // Update local state with new place
    final updatedPlaces = [...state.places, newPlace];
    state = state.copyWith(
      places: updatedPlaces,
      isLoading: false,
    );

    return true;
  } catch (e) {
    print('Error in addPlace provider: $e');
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
    return false;
  }
}

  // Update existing place - IMPROVED ERROR HANDLING AND FIELD MANAGEMENT
// Update existing place - IMPROVED ERROR HANDLING AND FIELD MANAGEMENT
Future<bool> updatePlace(String id, Place updatedPlace, {bool updateMainImage = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('=== PROVIDER UPDATE PLACE DEBUG ===');
      print('Updating place ID: $id');
      print('Update main image flag: $updateMainImage');
      print('Additional images count: ${updatedPlace.additionalImages?.length ?? 0}');

      if (updatedPlace.name.trim().isEmpty) {
        throw Exception('Nama tempat wisata harus diisi');
      }
      if (updatedPlace.location.trim().isEmpty) {
        throw Exception('Lokasi harus diisi');
      }
      if (updatedPlace.category == null || updatedPlace.category!.trim().isEmpty) {
        throw Exception('Kategori harus dipilih');
      }
      if (updatedPlace.latitude == null || updatedPlace.longitude == null) {
        throw Exception('Koordinat lokasi harus diisi');
      }
      if (updatedPlace.weekdayPrice == null || updatedPlace.weekdayPrice! < 0) {
        throw Exception('Harga hari kerja tidak valid');
      }
      if (updatedPlace.weekendPrice == null || updatedPlace.weekendPrice! < 0) {
        throw Exception('Harga akhir pekan tidak valid');
      }

      File? mainImageFile;
      if (updateMainImage && updatedPlace.isLocalImage && updatedPlace.image != null && updatedPlace.image!.isNotEmpty) {
        File file = File(updatedPlace.image!);
        bool exists = await file.exists();
        if (exists) {
          mainImageFile = file;
          print('Main image updated: ${mainImageFile.path}');
        } else {
          print('Main image file not found: ${updatedPlace.image}');
        }
      }

      List<File> newImageFiles = [];
      List<String> existingImageUrls = [];
      if (updatedPlace.additionalImages != null && updatedPlace.additionalImages!.isNotEmpty) {
        for (String path in updatedPlace.additionalImages!) {
          if (path.startsWith('http')) {
            existingImageUrls.add(path);
            print('Existing additional image to keep: $path');
          } else {
            File file = File(path);
            bool exists = await file.exists();
            if (exists) {
              newImageFiles.add(file);
              print('New additional image: ${file.path}');
            }
          }
        }
      }

      print('Main image file: ${mainImageFile?.path ?? 'null'}');
      print('New additional images count: ${newImageFiles.length}');
      print('Existing additional images count: ${existingImageUrls.length}');

      final updated = await ApiService.updatePlace(
        id: id,
        name: updatedPlace.name.trim(),
        location: updatedPlace.location.trim(),
        description: updatedPlace.description?.trim() ?? '',
        weekdaysHours: updatedPlace.weekdaysHours?.trim() ?? '',
        weekendHours: updatedPlace.weekendHours?.trim() ?? '',
        price: updatedPlace.price ?? 0,
        weekendPrice: updatedPlace.weekendPrice ?? 0,
        weekdayPrice: updatedPlace.weekdayPrice ?? 0,
        category: updatedPlace.category!.trim(),
        facilities: updatedPlace.facilities ?? [],
        latitude: updatedPlace.latitude!,
        longitude: updatedPlace.longitude!,
        image: mainImageFile,
        newImages: newImageFiles.isNotEmpty ? newImageFiles : null,
        existingImages: existingImageUrls.isNotEmpty ? existingImageUrls : [],
      );

      print('Place updated successfully: ${updated.id}');

      final updatedPlaces = state.places.map((place) {
        return place.id == id ? updated : place;
      }).toList();

      state = state.copyWith(
        places: updatedPlaces,
        isLoading: false,
      );

      return true;
    } catch (e) {
      print('Error in updatePlace provider: $e');
      String errorMessage = e.toString();
      if (errorMessage.contains('Bad request')) {
        errorMessage = 'Data tidak valid. Periksa semua field yang diperlukan.';
      } else if (errorMessage.contains('Network connection')) {
        errorMessage = 'Koneksi internet bermasalah. Coba lagi nanti.';
      } else if (errorMessage.contains('Validation error')) {
        errorMessage = 'Data tidak sesuai format yang diharapkan.';
      } else if (errorMessage.contains('Place not found')) {
        errorMessage = 'Tempat wisata tidak ditemukan.';
      } else if (errorMessage.contains('Server error')) {
        errorMessage = 'Terjadi kesalahan server. Coba lagi nanti.';
      }
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  Future<bool> updateAdditionalImages(String id, List<String> additionalImages) async {
    try {
      final currentPlace = getPlaceByIdSync(id);
      if (currentPlace == null) {
        throw Exception('Place not found');
      }

      final updatedPlace = currentPlace.copyWith(
        additionalImages: additionalImages,
      );

      return await updatePlace(id, updatedPlace, updateMainImage: false);
    } catch (e) {
      print('Error updating additional images: $e');
      return false;
    }
  }

  // Delete place
  Future<bool> deletePlace(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('=== PROVIDER DELETE PLACE DEBUG ===');
      print('Deleting place ID: $id');

      // Delete place via API
      await ApiService.deletePlace(id);

      print('Place deleted successfully: $id');

      // Update local state by removing the deleted place
      final updatedPlaces = state.places.where((place) => place.id != id).toList();
      
      state = state.copyWith(
        places: updatedPlaces,
        isLoading: false,
      );

      return true;
    } catch (e) {
      print('Error in deletePlace provider: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Refresh places - useful for pull-to-refresh
  Future<void> refreshPlaces() async {
    await loadPlaces();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Search places locally
  List<Place> searchPlaces(String query) {
    if (query.trim().isEmpty) {
      return state.places;
    }

    final lowercaseQuery = query.toLowerCase();
    return state.places.where((place) {
      return place.name.toLowerCase().contains(lowercaseQuery) ||
             place.location.toLowerCase().contains(lowercaseQuery) ||
             (place.category?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (place.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Get places by category from local state
  List<Place> getPlacesByCategoryLocal(String category) {
    return state.places.where((place) => place.category == category).toList();
  }

  // Get unique categories from local places
  List<String> getAvailableCategories() {
    final categories = <String>{};
    for (final place in state.places) {
      if (place.category != null && place.category!.isNotEmpty) {
        categories.add(place.category!);
      }
    }
    return categories.toList()..sort();
  }

  // Get unique locations from local places
  List<String> getAvailableLocations() {
    final locations = <String>{};
    for (final place in state.places) {
      if (place.location.isNotEmpty) {
        locations.add(place.location);
      }
    }
    return locations.toList()..sort();
  }
}

// Provider instance
final placesProvider = StateNotifierProvider<PlacesNotifier, PlacesState>((ref) {
  return PlacesNotifier();
});

// Helper providers for easy access
final placesListProvider = Provider<List<Place>>((ref) {
  return ref.watch(placesProvider).places;
});

final placesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(placesProvider).isLoading;
});

final placesErrorProvider = Provider<String?>((ref) {
  return ref.watch(placesProvider).error;
});

// Provider for searching places
final placesSearchProvider = Provider.family<List<Place>, String>((ref, query) {
  final notifier = ref.read(placesProvider.notifier);
  return notifier.searchPlaces(query);
});

// Provider for getting places by category
final placesByCategoryProvider = Provider.family<List<Place>, String>((ref, category) {
  final notifier = ref.read(placesProvider.notifier);
  return notifier.getPlacesByCategoryLocal(category);
});

// Provider for getting available categories
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final notifier = ref.read(placesProvider.notifier);
  return notifier.getAvailableCategories();
});

// Provider for getting available locations
final availableLocationsProvider = Provider<List<String>>((ref) {
  final notifier = ref.read(placesProvider.notifier);
  return notifier.getAvailableLocations();
});