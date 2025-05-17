import 'dart:convert';
import 'dart:io';

class Place {
  final String id; // Added ID for CRUD operations
  final String name;
  final String location;
  final double rating;
  final int price;
  final String image;
  final bool
      isLocalImage; // To differentiate between asset images and locally stored images
  final String? description; // Deskripsi wisata
  final String? weekdaysHours; // Jam operasi weekday (06:00 - 17:00)
  final String? weekendHours; // Jam operasi weekend (06:00 - 18:00)
  final int? weekendPrice; // Harga akhir pekan
  final List<String>? facilities; // Fasilitas (Area Parkir, Toilet dll)
  final int? reviewCount; // Jumlah ulasan
  final List<String>? additionalImages; // Additional images for gallery
  Place({
    String? id,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.image,
    this.isLocalImage = false,
    this.description,
    this.weekdaysHours,
    this.weekendHours,
    this.weekendPrice,
    this.facilities,
    this.reviewCount,
    this.additionalImages,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  Place copyWith({
    String? id,
    String? name,
    String? location,
    double? rating,
    int? price,
    String? image,
    bool? isLocalImage,
    String? description,
    String? weekdaysHours,
    String? weekendHours,
    int? weekendPrice,
    List<String>? facilities,
    int? reviewCount,
    List<String>? additionalImages,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      image: image ?? this.image,
      isLocalImage: isLocalImage ?? this.isLocalImage,
      description: description ?? this.description,
      weekdaysHours: weekdaysHours ?? this.weekdaysHours,
      weekendHours: weekendHours ?? this.weekendHours,
      weekendPrice: weekendPrice ?? this.weekendPrice,
      facilities: facilities ?? this.facilities,
      reviewCount: reviewCount ?? this.reviewCount,
      additionalImages: additionalImages ?? this.additionalImages,
    );
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'],
      location: json['location'],
      rating: json['rating'].toDouble(),
      price: (json['price'] is int)
          ? json['price']
          : (json['price'] * 1000).toInt(), // Convert to thousands if needed
      image: json['image'],
      isLocalImage: json['isLocalImage'] ?? false,
      description: json['description'],
      weekdaysHours: json['weekdaysHours'],
      weekendHours: json['weekendHours'],
      weekendPrice: json['weekendPrice'],
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : null,
      reviewCount: json['reviewCount'],
      additionalImages: json['additionalImages'] != null
          ? List<String>.from(json['additionalImages'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'rating': rating,
      'price': price,
      'image': image,
      'isLocalImage': isLocalImage,
      'description': description,
      'weekdaysHours': weekdaysHours,
      'weekendHours': weekendHours,
      'weekendPrice': weekendPrice,
      'facilities': facilities,
      'additionalImages': additionalImages,
      'reviewCount': reviewCount,
    };
  }

  factory Place.empty() {
    return Place(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      name: '',
      location: '',
      image: 'assets/images/placeholder.jpg', // Use a placeholder image
      price: 0,
      rating: 4.0, // Default rating
      facilities: const ['Area Parkir', 'Toilet'], // Default facilities
      isLocalImage: false,
    );
  }

  @override
  String toString() {
    return 'Place(id: $id, name: $name, location: $location, rating: $rating, price: $price, image: $image, isLocalImage: $isLocalImage, description: $description, hours: $weekdaysHours/$weekendHours, weekendPrice: $weekendPrice, facilities: $facilities, reviewCount: $reviewCount, additionalImages: $additionalImages)';
  }
}
