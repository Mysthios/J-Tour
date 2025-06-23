import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:j_tour/models/place_model.dart';

class SavedService {
  static const String baseUrl = 'http://192.168.0.5:3000/api';
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  // Get all saved places untuk user tertentu
  static Future<List<Place>> getSavedPlaces(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saved/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> places = responseData['data'];
          return places.map((place) => Place.fromJson(place)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 404) {
        // Return empty list if no saved places found
        return [];
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load saved places');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      throw Exception('Error getting saved places: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Tambah tempat ke saved (bookmark)
  static Future<bool> addToSaved(String userId, String placeId) async {
    if (userId.isEmpty || placeId.isEmpty) {
      throw Exception('User ID and Place ID are required');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/saved'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
          'placeId': placeId,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else if (response.statusCode == 409) {
        // Place already saved - treat as success
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add to saved');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please try again.');
      }
      throw Exception('Error adding to saved: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Hapus tempat dari saved (unbookmark)
  static Future<bool> removeFromSaved(String userId, String placeId) async {
    if (userId.isEmpty || placeId.isEmpty) {
      throw Exception('User ID and Place ID are required');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/saved/$userId/$placeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else if (response.statusCode == 404) {
        // Place not found in saved - treat as success (already removed)
        return true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to remove from saved');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please try again.');
      }
      throw Exception('Error removing from saved: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // Check apakah tempat sudah di-save atau belum
  static Future<bool> isPlaceSaved(String userId, String placeId) async {
    if (userId.isEmpty || placeId.isEmpty) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saved/$userId/$placeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data']['isSaved'] ?? false;
        }
      }
      return false;
    } catch (e) {
      // Silently fail for this method since it's used for UI state
      return false;
    }
  }

  // Get count of saved places for user
  static Future<int> getSavedCount(String userId) async {
    if (userId.isEmpty) {
      return 0;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saved/$userId/count'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data']['count'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      // Silently fail for count method
      return 0;
    }
  }

  // Batch operation - remove multiple places (optional enhancement)
  static Future<Map<String, bool>> removeMultipleFromSaved(String userId, List<String> placeIds) async {
    Map<String, bool> results = {};
    
    for (String placeId in placeIds) {
      try {
        results[placeId] = await removeFromSaved(userId, placeId);
      } catch (e) {
        results[placeId] = false;
      }
    }
    
    return results;
  }
}