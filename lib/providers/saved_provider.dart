import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/services/saved_service.dart';

// Simplified state
class SavedState {
  final List<Place> places;
  final bool isLoading;
  final String? error;
  final int count;

  SavedState({
    required this.places,
    this.isLoading = false,
    this.error,
    this.count = 0,
  });

  SavedState copyWith({
    List<Place>? places,
    bool? isLoading,
    String? error,
    int? count,
  }) {
    return SavedState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      count: count ?? this.count,
    );
  }
}

// Simplified notifier
class SavedPlaceNotifier extends AsyncNotifier<SavedState> {
  @override
  Future<SavedState> build() async {
    final userId = ref.read(userIdProvider);
    if (userId.isEmpty) {
      return SavedState(places: []);
    }

    try {
      final places = await SavedService.getSavedPlaces(userId);
      return SavedState(places: places, count: places.length);
    } catch (e) {
      return SavedState(places: [], error: e.toString());
    }
  }

  // Simple toggle with immediate UI update
  Future<void> toggleSaved(String userId, Place place) async {
    if (!state.hasValue || userId.isEmpty || place.id == null) return;

    final currentState = state.value!;
    final isCurrentlySaved = currentState.places.any((p) => p.id == place.id);
    
    // Immediate UI update
    List<Place> newPlaces;
    int newCount;
    
    if (isCurrentlySaved) {
      newPlaces = currentState.places.where((p) => p.id != place.id).toList();
      newCount = currentState.count - 1;
    } else {
      newPlaces = [...currentState.places, place];
      newCount = currentState.count + 1;
    }
    
    // Update state immediately
    state = AsyncValue.data(currentState.copyWith(
      places: newPlaces,
      count: newCount,
    ));
    
    // Background sync - fire and forget
    _syncToServer(userId, place.id!, !isCurrentlySaved);
  }

  // Background sync without blocking UI
  void _syncToServer(String userId, String placeId, bool shouldSave) async {
    try {
      if (shouldSave) {
        await SavedService.addToSaved(userId, placeId);
      } else {
        await SavedService.removeFromSaved(userId, placeId);
      }
    } catch (e) {
      // Silent fail - could add error reporting here
      print('Failed to sync saved state: $e');
    }
  }

  // Simple refresh
  Future<void> refresh(String userId) async {
    if (userId.isEmpty) return;
    
    try {
      final places = await SavedService.getSavedPlaces(userId);
      state = AsyncValue.data(SavedState(places: places, count: places.length));
    } catch (e) {
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.copyWith(error: e.toString()));
      }
    }
  }

  bool isSaved(Place place) {
    return state.hasValue && 
           state.value!.places.any((p) => p.id == place.id);
  }

  void clearError() {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(error: null));
    }
  }
}

// Providers
final savedPlaceProvider = AsyncNotifierProvider<SavedPlaceNotifier, SavedState>(
  () => SavedPlaceNotifier(),
);

final userIdProvider = StateProvider<String>((ref) => 'user123');

final savedSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredSavedPlacesProvider = Provider<List<Place>>((ref) {
  final savedState = ref.watch(savedPlaceProvider);
  final searchQuery = ref.watch(savedSearchQueryProvider);
  
  return savedState.when(
    data: (state) {
      if (searchQuery.isEmpty) return state.places;
      
      final query = searchQuery.toLowerCase();
      return state.places.where((place) {
        return place.name.toLowerCase().contains(query) ||
               place.location.toLowerCase().contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Simple family providers
final placeIsSavedProvider = Provider.family<bool, String>((ref, placeId) {
  final savedState = ref.watch(savedPlaceProvider);
  return savedState.when(
    data: (state) => state.places.any((place) => place.id == placeId),
    loading: () => false,
    error: (_, __) => false,
  );
});