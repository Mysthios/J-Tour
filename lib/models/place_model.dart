class Place {
  final String name;
  final String location;
  final double rating;
  final int price;
  final String image;

  Place({
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.image,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      location: json['location'],
      rating: json['rating'].toDouble(),
      price: json['price'],
      image: json['image'],
    );
  }
}
