import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import '../models/place_model.dart';

class PlaceService {
  static const String _placesKey = 'places_data';

  // Load initial data from assets when first run
  Future<List<Place>> _loadInitialData() async {
    try {
      final data = await rootBundle.loadString('assets/places.json');
      final List list = json.decode(data);
      return list.map((e) => Place.fromJson(e)).toList();
    } catch (e) {
      print('Error loading initial data: $e');
      return [];
    }
  }

  // Get all places from shared preferences
  Future<List<Place>> getPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson = prefs.getString(_placesKey);

    if (placesJson == null) {
      // First run, load from assets and save to shared preferences
      final initialPlaces = await _loadInitialData();
      await savePlaces(initialPlaces);
      return initialPlaces;
    }

    try {
      final List<dynamic> decodedList = json.decode(placesJson);
      return decodedList.map((item) => Place.fromJson(item)).toList();
    } catch (e) {
      print('Error decoding places: $e');
      return [];
    }
  }

  // Save all places to shared preferences
  Future<void> savePlaces(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final placesJson =
        json.encode(places.map((place) => place.toJson()).toList());
    await prefs.setString(_placesKey, placesJson);
  }

  // Add a new place
  Future<List<Place>> addPlace(Place place) async {
    final places = await getPlaces();
    places.add(place);
    await savePlaces(places);
    return places;
  }

  // Update an existing place
  Future<List<Place>> updatePlace(Place updatedPlace) async {
    final places = await getPlaces();
    final index = places.indexWhere((place) => place.id == updatedPlace.id);

    if (index != -1) {
      places[index] = updatedPlace;
      await savePlaces(places);
    }

    return places;
  }

  // Delete a place
  Future<List<Place>> deletePlace(String id) async {
    final places = await getPlaces();
    final index = places.indexWhere((place) => place.id == id);

    if (index != -1) {
      final deletedPlace = places.removeAt(index);

      // Delete the local image file if it was saved locally
      if (deletedPlace.isLocalImage) {
        try {
          final file = File(deletedPlace.image);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting image file: $e');
        }
      }

      await savePlaces(places);
    }

    return places;
  }

  // Save an image to local storage and return the file path
  Future<String> saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();

    // Create more unique filename with UUID-like structure
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000; // Additional randomness
    final fileExtension = path.extension(imageFile.path);

    // Format: jtour_image_timestamp_random.extension
    final fileName = 'jtour_image_${timestamp}_$random$fileExtension';

    // Create places directory if it doesn't exist
    final placesDir = Directory('${directory.path}/places_images');
    if (!await placesDir.exists()) {
      await placesDir.create(recursive: true);
    }

    final savedImage = await imageFile.copy('${placesDir.path}/$fileName');
    return savedImage.path;
  }
}
