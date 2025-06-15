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
    return Place(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'],
      location: json['location'],
      rating: (json['rating'] as num).toDouble(),
      price: (json['price'] is int)
          ? json['price']
          : (json['price'] * 1000).toInt(),
      image: json['image'],
      isLocalImage: json['isLocalImage'] ?? false,
      description: json['description'],
      weekdaysHours: json['weekdaysHours'],
      weekendHours: json['weekendHours'],
      weekendPrice: json['weekendPrice'],
      weekdayPrice: json['weekdayPrice'],
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : null,
      reviewCount: json['reviewCount'],
      additionalImages: json['additionalImages'] != null
          ? List<String>.from(json['additionalImages'])
          : null,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
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
