import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';

class SavedPlaceNotifier extends StateNotifier<List<Place>> {
  SavedPlaceNotifier() : super([]);

  void toggleSaved(Place place) {
    // Gunakan ID atau name untuk comparison, bukan object
    bool isAlreadySaved = state.any((p) => p.name == place.name); // atau p.id == place.id jika ada field id
    
    if (isAlreadySaved) {
      state = state.where((p) => p.name != place.name).toList();
    } else {
      state = [...state, place];
    }
  }

  bool isSaved(Place place) {
    return state.any((p) => p.name == place.name);
  }
}

final savedPlaceProvider = StateNotifierProvider<SavedPlaceNotifier, List<Place>>(
  (ref) => SavedPlaceNotifier(),
);