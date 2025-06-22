// services/review_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/review_model.dart';

const String baseUrl = 'http://10.132.12.217:3000/api';

class ReviewService {

  // Get reviews for a place
  Future<List<Review>> getReviewsByPlace(String placeId, {int? limit}) async {
    try {
      String url = '$baseUrl/reviews/place/$placeId';
      if (limit != null) {
        url += '?limit=$limit';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> reviewsJson = data['data'];
          return reviewsJson.map((json) => Review.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to get reviews');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error getting reviews: $e');
    }
  }

  // Get user's review for specific place
  Future<Review?> getUserReviewForPlace(String placeId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/place/$placeId/user?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Review.fromJson(data['data']);
        }
        return null;
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error getting user review: $e');
    }
  }

  // Create new review
  Future<Review> createReview({
  required String placeId,
  required String userId,
  required String userName,
  required int rating,
  String? comment,
  List<File>? images,
}) async {
  try {
    // Validasi rating
    if (rating < 0 || rating > 5) {
      throw Exception('Rating harus antara 0-5');
    }
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/reviews'),
    );
    
    // Add form fields
    request.fields['placeId'] = placeId;
    request.fields['userId'] = userId;
    request.fields['userName'] = userName;
    request.fields['rating'] = rating.toString();
    if (comment != null && comment.isNotEmpty) {
      request.fields['comment'] = comment;
    }
    
    // Add image files
    if (images != null && images.isNotEmpty) {
      for (var image in images) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }
    }
    
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(responseBody);
      if (data['success'] == true) {
        return Review.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create review');
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(responseBody);
      String errorMessage = errorData['message'] ?? 'HTTP ${response.statusCode}';
      
      // Handle specific error messages
      if (errorMessage.contains('already reviewed')) {
        throw Exception('Anda sudah memberikan review untuk tempat ini');
      }
      
      throw Exception(errorMessage);
    }
  } catch (e) {
    throw Exception('Error creating review: $e');
  }
}

  // Update review
  // Update method updateReview dengan validasi:
Future<Review> updateReview({
  required String reviewId,
  required String userId,
  int? rating,
  String? comment,
  List<ReviewImage>? existingImages,
  List<File>? newImages,
}) async {
  try {
    // Validasi rating jika ada
    if (rating != null && (rating < 0 || rating > 5)) {
      throw Exception('Rating harus antara 0-5');
    }
    
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/reviews/$reviewId'),
    );
    
    // Add form fields
    request.fields['userId'] = userId;
    if (rating != null) {
      request.fields['rating'] = rating.toString();
    }
    if (comment != null) {
      request.fields['comment'] = comment;
    }
    if (existingImages != null) {
      request.fields['existingImages'] = json.encode(
        existingImages.map((img) => {
          'url': img.url,
          'publicId': img.publicId,
        }).toList()
      );
    }
    
    // Add new image files
    if (newImages != null && newImages.isNotEmpty) {
      for (var image in newImages) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'newImages',
          stream,
          length,
          filename: image.path.split('/').last,
        );
        request.files.add(multipartFile);
      }
    }
    
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(responseBody);
      if (data['success'] == true) {
        return Review.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update review');
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(responseBody);
      String errorMessage = errorData['message'] ?? 'HTTP ${response.statusCode}';
      
      // Handle specific error messages
      if (errorMessage.contains('Unauthorized')) {
        throw Exception('Anda tidak memiliki akses untuk mengubah review ini');
      }
      
      throw Exception(errorMessage);
    }
  } catch (e) {
    throw Exception('Error updating review: $e');
  }
}

  // Delete review
  Future<bool> deleteReview(String reviewId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$reviewId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting review: $e');
    }
  }
}

Future<Map<String, dynamic>> getPlaceWithReviews(String placeId, {int? reviewLimit}) async {
  try {
    String url = '$baseUrl/tourism/places/$placeId/reviews';
    if (reviewLimit != null) {
      url += '?reviewLimit=$reviewLimit';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get place with reviews');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Error getting place with reviews: $e');
  }
}
