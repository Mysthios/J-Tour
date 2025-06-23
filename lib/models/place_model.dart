class Place {
  final String id;
  final String name;
  final String location;
  final double? rating;
  final int price;
  final String image;
  final bool isLocalImage;
  final String? description;
  final String? weekdaysHours;
  final String? weekendHours;
  final int? weekdayPrice;
  final int? weekendPrice;
  final List<String>? facilities;
  final int? reviewCount;
  final List<String>? additionalImages;
  final double? latitude;
  final double? longitude;
  final String? category;

  Place({
    String? id,
    required this.name,
    required this.location,
    this.rating,
    required this.price,
    required this.image,
    this.isLocalImage = false,
    this.description,
    this.weekdaysHours,
    this.weekendHours,
    this.weekdayPrice,
    this.weekendPrice,
    this.facilities,
    this.reviewCount,
    this.category,
    this.additionalImages,
    required this.latitude,
    required this.longitude,
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
    int? weekdayPrice,
    int? weekendPrice,
    List<String>? facilities,
    int? reviewCount,
    List<String>? additionalImages,
    double? latitude,
    double? longitude,
    String? category,
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
      weekdayPrice: weekdayPrice ?? this.weekdayPrice,
      weekendPrice: weekendPrice ?? this.weekendPrice,
      facilities: facilities ?? this.facilities,
      reviewCount: reviewCount ?? this.reviewCount,
      additionalImages: additionalImages ?? this.additionalImages,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
    );
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    // Helper function untuk safely parse double
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    // Helper function untuk safely parse int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    // Extract coordinates (handle both flat and nested structure)
    double? lat, lng;
    if (json['coordinates'] != null) {
      // Nested structure from backend
      lat = parseDouble(json['coordinates']['latitude']);
      lng = parseDouble(json['coordinates']['longitude']);
    } else {
      // Flat structure
      lat = parseDouble(json['latitude']);
      lng = parseDouble(json['longitude']);
    }

    // Extract operating hours (handle both flat and nested structure)
    String? weekdaysHours, weekendHours;
    if (json['operatingHours'] != null) {
      // Nested structure from backend
      weekdaysHours = json['operatingHours']['weekdays'];
      weekendHours = json['operatingHours']['weekend'];
    } else {
      // Flat structure
      weekdaysHours = json['weekdaysHours'];
      weekendHours = json['weekendHours'];
    }

    // Extract pricing (handle both flat and nested structure)
    int? weekdayPrice, weekendPrice, mainPrice;
    if (json['pricing'] != null) {
      // Nested structure from backend
      weekdayPrice = parseInt(json['pricing']['weekday']);
      weekendPrice = parseInt(json['pricing']['weekend']);
      mainPrice = weekdayPrice ?? weekendPrice ?? 0;
    } else {
      // Flat structure
      weekdayPrice = parseInt(json['weekdayPrice']);
      weekendPrice = parseInt(json['weekendPrice']);
      mainPrice = parseInt(json['price']) ?? weekdayPrice ?? weekendPrice ?? 0;
    }

    // Extract images (handle both formats)
    String mainImage = '';
    List<String> additionalImages = [];
    
    if (json['images'] != null && json['images'] is List) {
      // Backend format: array of image objects
      List<dynamic> images = json['images'];
      if (images.isNotEmpty) {
        mainImage = images[0]['url'] ?? '';
        additionalImages = images.skip(1).map((img) => img['url'] as String).toList();
      }
    } else {
      // Flat structure
      mainImage = json['image'] ?? '';
      if (json['additionalImages'] != null) {
        additionalImages = List<String>.from(json['additionalImages']);
      }
    }

    return Place(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: parseDouble(json['rating']) ?? 0.0,
      price: mainPrice,
      image: mainImage,
      isLocalImage: json['isLocalImage'] ?? false,
      description: json['description'],
      weekdaysHours: weekdaysHours,
      weekendHours: weekendHours,
      weekendPrice: weekendPrice,
      weekdayPrice: weekdayPrice,
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : null,
      reviewCount: parseInt(json['reviewCount']),
      additionalImages: additionalImages,
      latitude: lat ?? 0.0,
      longitude: lng ?? 0.0,
      category: json['category'],
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
      'weekdayPrice': weekdayPrice,
      'facilities': facilities,
      'reviewCount': reviewCount,
      'additionalImages': additionalImages,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
    };
  }

  @override
  String toString() {
    return 'Place(id: $id, name: $name, location: $location, rating: $rating, price: $price, image: $image, isLocalImage: $isLocalImage, description: $description, weekdaysHours: $weekdaysHours, weekendHours: $weekendHours, weekendPrice: $weekendPrice, weekdayPrice: $weekdayPrice ,facilities: $facilities, reviewCount: $reviewCount, additionalImages: $additionalImages, latitude: $latitude, longitude: $longitude, category: $category)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Place && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  get phoneNumber => null;
}