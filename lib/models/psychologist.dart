class Psychologist {
  final String id;
  final String name;

  final double rating; // 0..5
  final int price; // precio por sesión en MXN
  final String moneda;

  final List<String> specialties;
  final List<String> modalidades;
  final List<String> enfoquesTerapia;
  final List<String> atiendeA;

  final String descripcionProfesional;
  final int? aniosExperiencia;

  final bool isTop;
  final bool isAvailable;

  final String? avatarAsset; // opcional, para assets locales
  final String? avatarUrl; // opcional, para imágenes desde backend

  Psychologist({
    required this.id,
    required this.name,
    required this.rating,
    required this.price,
    required this.specialties,
    this.moneda = 'MXN',
    this.modalidades = const [],
    this.enfoquesTerapia = const [],
    this.atiendeA = const [],
    this.descripcionProfesional = '',
    this.aniosExperiencia,
    this.isTop = false,
    this.isAvailable = false,
    this.avatarAsset,
    this.avatarUrl,
  });

  factory Psychologist.fromJson(Map<String, dynamic> json) {
    return Psychologist(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),

      rating: _readDouble(json['rating'], fallback: 0.0),
      price: _readInt(json['price']),
      moneda: (json['moneda'] ?? 'MXN').toString(),

      specialties: _readStringList(json['specialties']),
      modalidades: _readStringList(json['modalidades']),
      enfoquesTerapia: _readStringList(json['enfoquesTerapia']),
      atiendeA: _readStringList(json['atiendeA']),

      descripcionProfesional:
          (json['descripcionProfesional'] ?? json['bio'] ?? '').toString(),

      aniosExperiencia: json['aniosExperiencia'] is int
          ? json['aniosExperiencia'] as int
          : json['aniosExperiencia'] is num
              ? (json['aniosExperiencia'] as num).toInt()
              : null,

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
      'moneda': moneda,

      'specialties': specialties,
      'modalidades': modalidades,
      'enfoquesTerapia': enfoquesTerapia,
      'atiendeA': atiendeA,

      'descripcionProfesional': descripcionProfesional,
      'aniosExperiencia': aniosExperiencia,

      'isTop': isTop,
      'isAvailable': isAvailable,

      'avatarAsset': avatarAsset,
      'avatarUrl': avatarUrl,
    };
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) return [];

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static double _readDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return fallback;
  }
}