class Psychologist {
  final String id;
  final String name;
  final double rating; // 0..5
  final int price; // precio por sesión en MXN
  final List<String> specialties;
  final bool isTop;
  final bool isAvailable;
  final String? avatarAsset; // opcional, para assets locales
  final String? avatarUrl;   // opcional, para imágenes desde backend

  Psychologist({
    required this.id,
    required this.name,
    required this.rating,
    required this.price,
    required this.specialties,
    this.isTop = false,
    this.isAvailable = false,
    this.avatarAsset,
    this.avatarUrl,
  });

  factory Psychologist.fromJson(Map<String, dynamic> json) {
    return Psychologist(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num).toDouble(),
      price: (json['price'] as num).toInt(),
      specialties: (json['specialties'] as List<dynamic>).map((e) => e.toString()).toList(),
      isTop: json['isTop'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      avatarAsset: json['avatarAsset'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'price': price,
      'specialties': specialties,
      'isTop': isTop,
      'isAvailable': isAvailable,
      'avatarAsset': avatarAsset,
      'avatarUrl': avatarUrl,
    };
  }
}
