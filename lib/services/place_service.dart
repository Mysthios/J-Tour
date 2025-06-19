import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:j_tour/models/place_model.dart';
import 'package:mime/mime.dart'; // Add this dependency: dart pub add mime

class ApiService {
  static const String baseUrl = 'http://10.132.1.133:3000/api';
  
  // Headers default
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Helper method to get MIME type
  static String? _getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  // Helper method to validate image file
  static bool _isValidImageFile(File file) {
    final mimeType = _getMimeType(file.path);
    return mimeType != null && mimeType.startsWith('image/');
  }

  // GET all places
  static Future<List<Place>> getAllPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];
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
        final responseData = json.decode(response.body);
        final data = responseData['data'];
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
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST create new place - FIXED VERSION WITH MIME TYPE
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
      print('=== API CREATE PLACE DEBUG ===');
      print('URL: $baseUrl/places');
      print('Name: $name');
      print('Location: $location');
      print('Category: $category');
      print('Description: $description');
      print('Coordinates: $latitude, $longitude');
      print('Hours: $weekdaysHours | $weekendHours');
      print('Prices: $weekdayPrice | $weekendPrice');
      print('Facilities: $facilities');
      print('Main image: ${mainImage?.path}');
      print('Additional images: ${additionalImages?.length ?? 0}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/places'),
      );

      // Add text fields - pastikan semua field tidak null
      request.fields.addAll({
        'name': name.trim(),
        'location': location.trim(),
        'description': description.trim(),
        'weekdaysHours': weekdaysHours.trim(),
        'weekendHours': weekendHours.trim(),
        'price': price.toString(),
        'weekendPrice': weekendPrice.toString(),
        'weekdayPrice': weekdayPrice.toString(),
        'category': category.trim(),
        'facilities': json.encode(facilities),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });

      print('Request fields: ${request.fields}');

      // Validate and add main image if exists
      if (mainImage != null && await mainImage.exists()) {
        if (!_isValidImageFile(mainImage)) {
          throw Exception('File utama bukan file gambar yang valid: ${mainImage.path}');
        }
        
        final mimeType = _getMimeType(mainImage.path);
        print('Main image MIME type: $mimeType');
        print('Adding main image: ${mainImage.path}');
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            mainImage.path,
            contentType: mimeType != null ? 
              http_parser.MediaType.parse(mimeType) : null,
          ),
        );
      }

      // Validate and add additional images if exist
      if (additionalImages != null && additionalImages.isNotEmpty) {
        print('Processing ${additionalImages.length} additional images');
        for (int i = 0; i < additionalImages.length; i++) {
          File image = additionalImages[i];
          
          if (await image.exists()) {
            if (!_isValidImageFile(image)) {
              print('Skipping invalid image file: ${image.path}');
              continue;
            }
            
            final mimeType = _getMimeType(image.path);
            print('Additional image $i MIME type: $mimeType');
            print('Adding additional image $i: ${image.path}');
            
            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                image.path,
                contentType: mimeType != null ? 
                  http_parser.MediaType.parse(mimeType) : null,
              ),
            );
          } else {
            print('Image file not found: ${image.path}');
          }
        }
      }

      print('Total files to upload: ${request.files.length}');

      // Add debug headers
      print('Request headers: ${request.headers}');
      print('Request files detail:');
      for (var file in request.files) {
        print('- Field: ${file.field}');
        print('- Filename: ${file.filename}');
        print('- Content-Type: ${file.contentType}');
        print('- Length: ${file.length}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return Place.fromJson(responseData['data']);
        } else {
          throw Exception('Server returned success=false: ${responseData['message']}');
        }
      } else {
        // Handle different error responses
        try {
          final errorData = json.decode(response.body);
          throw Exception('Failed to create place: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('Failed to create place: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error in createPlace: $e');
      rethrow;
    }
  }

  // PUT update place - FIXED VERSION WITH MIME TYPE
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
      print('=== API UPDATE PLACE DEBUG ===');
      print('Updating place ID: $id');
      
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/places/$id'),
      );

      // Add text fields
      request.fields.addAll({
        'name': name.trim(),
        'location': location.trim(),
        'description': description.trim(),
        'weekdaysHours': weekdaysHours.trim(),
        'weekendHours': weekendHours.trim(),
        'price': price.toString(),
        'weekendPrice': weekendPrice.toString(),
        'weekdayPrice': weekdayPrice.toString(),
        'category': category.trim(),
        'facilities': json.encode(facilities),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      });

      // Add existing images if provided
      if (existingImages != null && existingImages.isNotEmpty) {
        request.fields['existingImages'] = json.encode(existingImages);
      }

      // Validate and add new images if exist
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          File image = newImages[i];
          
          if (await image.exists()) {
            if (!_isValidImageFile(image)) {
              print('Skipping invalid image file: ${image.path}');
              continue;
            }
            
            final mimeType = _getMimeType(image.path);
            print('New image $i MIME type: $mimeType');
            
            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                image.path,
                contentType: mimeType != null ? 
                  http_parser.MediaType.parse(mimeType) : null,
              ),
            );
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return Place.fromJson(responseData['data']);
        } else {
          throw Exception('Server returned success=false: ${responseData['message']}');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception('Failed to update place: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('Failed to update place: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error in updatePlace: $e');
      rethrow;
    }
  }

  // DELETE place
  static Future<void> deletePlace(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/places/$id'),
        headers: _headers,
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] != true) {
          throw Exception('Server returned success=false: ${responseData['message']}');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception('Failed to delete place: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception('Failed to delete place: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error in deletePlace: $e');
      rethrow;
    }
  }
}