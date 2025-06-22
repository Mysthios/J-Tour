// models/review_model.dart
class ReviewImage {
  final String url;
  final String publicId;
  
  ReviewImage({
    required this.url,
    required this.publicId,
  });
  
  factory ReviewImage.fromJson(Map<String, dynamic> json) {
    return ReviewImage(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'publicId': publicId,
    };
  }
}

class Review {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final List<ReviewImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      placeId: json['placeId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((img) => ReviewImage.fromJson(img))
          .toList(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'images': images.map((img) => img.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  Review copyWith({
    String? id,
    String? placeId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    List<ReviewImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}