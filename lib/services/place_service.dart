import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:j_tour/models/place_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api'; // Ganti dengan URL server Anda
  
  // Headers default
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET all places
  static Future<List<Place>> getAllPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET place by ID
  static Future<Place> getPlaceById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Place.fromJson(data);
      } else {
        throw Exception('Failed to load place: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET places by category
  static Future<List<Place>> getPlacesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places/category/$category'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST create new place
  static Future<Place> createPlace({
    required String name,
    required String location,
    required String description,
    required String weekdaysHours,
    required String weekendHours,
    required int price,
    required int weekendPrice,
    required int weekdayPrice,
    required String category,
    required List<String> facilities,
    required double latitude,
    required double longitude,
    File? mainImage,
    List<File>? additionalImages,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/places'),
      );

      // Add text fields
      request.fields.addAll({
        'name': name,
        'location': location,
        'description': description,
        'weekdaysHours': weekdaysHours,
        'weekendHours': weekendHours,
        'price': price.toString(),
        'weekendPrice': weekendPrice.toString(),
        'weekdayPrice': weekdayPrice.toString(),
        'category': category,
        'facilities': json.encode(facilities),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });

      // Add main image if exists
      if (mainImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            mainImage.path,
          ),
        );
      }

      // Add additional images if exist
      if (additionalImages != null) {
        for (File image in additionalImages) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              image.path,
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body)['data'];
        return Place.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to create place: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT update place
  static Future<Place> updatePlace({
    required String id,
    required String name,
    required String location,
    required String description,
    required String weekdaysHours,
    required String weekendHours,
    required int price,
    required int weekendPrice,
    required int weekdayPrice,
    required String category,
    required List<String> facilities,
    required double latitude,
    required double longitude,
    List<File>? newImages,
    List<String>? existingImages,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/places/$id'),
      );

      // Add text fields
      request.fields.addAll({
        'name': name,
        'location': location,
        'description': description,
        'weekdaysHours': weekdaysHours,
        'weekendHours': weekendHours,
        'price': price.toString(),
        'weekendPrice': weekendPrice.toString(),
        'weekdayPrice': weekdayPrice.toString(),
        'category': category,
        'facilities': json.encode(facilities),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });

      // Add existing images if provided
      if (existingImages != null) {
        request.fields['existingImages'] = json.encode(existingImages);
      }

      // Add new images if exist
      if (newImages != null) {
        for (File image in newImages) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'newImages',
              image.path,
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        return Place.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to update place: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE place
  static Future<void> deletePlace(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/places/$id'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception('Failed to delete place: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}