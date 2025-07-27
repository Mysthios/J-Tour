import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:j_tour/models/place_model.dart';
import 'package:mime/mime.dart'; // Add this dependency: dart pub add mime

class ApiService {
  static const String baseUrl = 'http://10.132.12.217:3000/api';

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
        throw Exception(
            'Failed to load places by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST create new place - FIXED VERSION
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
      print('Main image: ${mainImage?.path}');
      print('Additional images: ${additionalImages?.length ?? 0}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/places'),
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

      print('Request fields: ${request.fields}');

      // Tambahkan semua gambar dengan field 'images'
      final allImages = <File>[];
      if (mainImage != null && await mainImage.exists()) {
        if (!_isValidImageFile(mainImage)) {
          throw Exception(
              'File utama bukan file gambar yang valid: ${mainImage.path}');
        }
        final mimeType = _getMimeType(mainImage.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'mainImage',
            mainImage.path,
            contentType:
                mimeType != null ? http_parser.MediaType.parse(mimeType) : null,
          ),
        );
        print('Adding main image: ${mainImage.path}');
      }

      if (additionalImages != null && additionalImages.isNotEmpty) {
        for (var image in additionalImages) {
          if (await image.exists() && _isValidImageFile(image)) {
            final mimeType = _getMimeType(image.path);
            request.files.add(
              await http.MultipartFile.fromPath(
                'additionalImages',
                image.path,
                contentType: mimeType != null
                    ? http_parser.MediaType.parse(mimeType)
                    : null,
              ),
            );
            print('Adding additional image: ${image.path}');
          }
        }
      }
      for (var image in allImages) {
        final mimeType = _getMimeType(image.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // Field name sesuai backend
            image.path,
            contentType:
                mimeType != null ? http_parser.MediaType.parse(mimeType) : null,
          ),
        );
      }

      print('Total files to upload: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final place = Place.fromJson(responseData['data']);
          print(
              'Place created: ID=${place.id}, Images=${place.image}, AdditionalImages=${place.additionalImages?.length}');
          return place;
        } else {
          throw Exception(
              'Server returned success=false: ${responseData['message']}');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to create place: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error in createPlace: $e');
      rethrow;
    }
  }

// PUT update place - IMPROVED VERSION
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
    File? image,
    List<File>? newImages,
    List<String>? existingImages,
  }) async {
    try {
      print('=== API UPDATE PLACE DEBUG ===');
      print('Updating place ID: $id');
      print('URL: $baseUrl/places/$id');
      print('Main image provided: ${image != null}');
      print('New additional images count: ${newImages?.length ?? 0}');
      print('Existing additional images count: ${existingImages?.length ?? 0}');

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/places/$id'),
      );

      final Map<String, String> fields = {
        'name': name.trim(),
        'location': location.trim(),
        'description': description.trim(),
        'weekdaysHours': weekdaysHours.trim(),
        'weekendHours': weekendHours.trim(),
        'price': price.toString(),
        'weekendPrice': weekendPrice.toString(),
        'weekdayPrice': weekdayPrice.toString(),
        'category': category.trim(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (facilities.isNotEmpty) {
        fields['facilities'] = json.encode(facilities);
      }

      if (existingImages != null) {
        fields['existingImages'] = json.encode(existingImages);
        print('Existing additional images sent: ${existingImages.length}');
      } else {
        fields['existingImages'] = json.encode([]);
        print('No existing additional images to keep');
      }

      request.fields.addAll(fields);
      print('Request fields: ${request.fields}');

      if (image != null && await image.exists()) {
        if (!_isValidImageFile(image)) {
          throw Exception(
              'File utama bukan file gambar yang valid: ${image.path}');
        }
        final mimeType = _getMimeType(image.path);
        print('Main image MIME type: $mimeType');
        print('Adding main image: ${image.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'mainImage',
            image.path,
            contentType:
                mimeType != null ? http_parser.MediaType.parse(mimeType) : null,
          ),
        );
      }

      if (newImages != null && newImages.isNotEmpty) {
        print('Processing ${newImages.length} new additional images');
        for (int i = 0; i < newImages.length; i++) {
          File imageFile = newImages[i];
          if (await imageFile.exists()) {
            if (!_isValidImageFile(imageFile)) {
              print('Skipping invalid image file: ${imageFile.path}');
              continue;
            }
            final mimeType = _getMimeType(imageFile.path);
            print('New additional image $i MIME type: $mimeType');
            print('Adding new additional image $i: ${imageFile.path}');
            request.files.add(
              await http.MultipartFile.fromPath(
                'additionalImages',
                imageFile.path,
                contentType: mimeType != null
                    ? http_parser.MediaType.parse(mimeType)
                    : null,
              ),
            );
          }
        }
      }

      print('Total files to upload: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('Place updated successfully');
          return Place.fromJson(responseData['data']);
        } else {
          throw Exception('Server error: ${responseData['message']}');
        }
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        } catch (_) {
          errorMessage = 'HTTP ${response.statusCode} - ${response.body}';
        }
        throw Exception('Failed to update place: $errorMessage');
      }
    } catch (e) {
      print('Error in updatePlace: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException')) {
        throw Exception(
            'Network connection error. Please check your internet connection.');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout. Please try again.');
      } else if (e.toString().contains('FormatException')) {
        throw Exception('Invalid data format. Please check your input.');
      }
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
          throw Exception(
              'Server returned success=false: ${responseData['message']}');
        }
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(
              'Failed to delete place: ${errorData['message'] ?? errorData['error'] ?? 'Unknown error'}');
        } catch (e) {
          throw Exception(
              'Failed to delete place: HTTP ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error in deletePlace: $e');
      rethrow;
    }
  }
}
