import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/psychologist.dart';

class PublicPsychologistsService {
  PublicPsychologistsService._();

  static final instance = PublicPsychologistsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Psychologist>> fetchAll({
    String? query,
    int? maxPrice,
    double? minRating,
    String? specialty,
  }) {
    return fetchPublicPsychologists(
      query: query,
      maxPrice: maxPrice,
      minRating: minRating,
      specialty: specialty,
    );
  }

  Future<List<Psychologist>> fetchPublicPsychologists({
  String? query,
  int? maxPrice,
  double? minRating,
  String? specialty,
}) async {
  final snap = await _db
      .collection('usuariosPsicologos')
      .where('estadoValidacion', isEqualTo: 'VALIDADO_OFICIAL')
      .where('professionalProfileCompleted', isEqualTo: true)
      .where('profileVisible', isEqualTo: true)
      .get();

  var items = <Psychologist>[];

  for (final doc in snap.docs) {
    final mainData = doc.data();

    final publicProfileDoc = await _db
        .collection('usuariosPsicologos')
        .doc(doc.id)
        .collection('perfilProfesional')
        .doc('publico')
        .get();

    final publicData = publicProfileDoc.data() ?? {};

    final mergedData = <String, dynamic>{
      ...mainData,
      ...publicData,
    };

    items.add(_psychologistFromFirestore(doc.id, mergedData));
  }

  final cleanQuery = query?.trim().toLowerCase();

  if (cleanQuery != null && cleanQuery.isNotEmpty) {
    items = items.where((p) {
      final name = p.name.toLowerCase();
      final specialties = p.specialties.join(' ').toLowerCase();
      final enfoques = p.enfoquesTerapia.join(' ').toLowerCase();
      final atiendeA = p.atiendeA.join(' ').toLowerCase();

      return name.contains(cleanQuery) ||
          specialties.contains(cleanQuery) ||
          enfoques.contains(cleanQuery) ||
          atiendeA.contains(cleanQuery);
    }).toList();
  }

  if (maxPrice != null) {
    items = items.where((p) => p.price <= maxPrice).toList();
  }

  if (minRating != null) {
    items = items.where((p) => p.rating >= minRating).toList();
  }

  if (specialty != null && specialty.trim().isNotEmpty) {
    final cleanSpecialty = _normalizeFilter(specialty);

    if (cleanSpecialty != 'todas') {
      items = items.where((p) {
        return p.specialties.any(
              (s) => _normalizeFilter(s).contains(cleanSpecialty),
            ) ||
            p.enfoquesTerapia.any(
              (s) => _normalizeFilter(s).contains(cleanSpecialty),
            );
      }).toList();
    }
  }

  items.sort((a, b) => b.rating.compareTo(a.rating));

  return items;
}

  Psychologist _psychologistFromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) {
    final nombreLegal = (data['nombreLegal'] ?? '').toString().trim();
    final nombre = (data['nombre'] ?? '').toString().trim();
    final apellido = (data['apellido'] ?? '').toString().trim();

    final nombrePerfil =
        [nombre, apellido].where((value) => value.isNotEmpty).join(' ').trim();

    final displayName =
        nombreLegal.isNotEmpty
            ? nombreLegal
            : nombrePerfil.isNotEmpty
            ? nombrePerfil
            : 'Psicólogo verificado';

    final specialties =
        _readStringList(data['especialidades']).map(_labelFromKey).toList();

    final modalidades =
        _readStringList(data['modalidades']).map(_labelFromKey).toList();

    final enfoques =
        _readStringList(data['enfoquesTerapia']).map(_labelFromKey).toList();

    final atiendeA =
        _readStringList(data['atiendeA']).map(_labelFromKey).toList();

    final price = _readInt(data['honorariosSesion']);
    final rating = _readDouble(data['ratingPromedio'], fallback: 5.0);

    final descripcion =
        (data['descripcionProfesional'] ?? '').toString().trim();

    final avatarUrl = (data['avatarUrl'] ?? '').toString().trim();

    return Psychologist(
      id: uid,
      name: displayName,
      rating: rating,
      price: price,
      moneda: (data['moneda'] ?? 'MXN').toString(),

      specialties: specialties.isEmpty ? ['Psicología'] : specialties,
      modalidades: modalidades,
      enfoquesTerapia: enfoques,
      atiendeA: atiendeA,

      descripcionProfesional: descripcion,
      aniosExperiencia:
          data['aniosExperiencia'] is int
              ? data['aniosExperiencia'] as int
              : data['aniosExperiencia'] is num
              ? (data['aniosExperiencia'] as num).toInt()
              : null,

      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      avatarAsset: null,

      isAvailable: true,
      isTop: rating >= 4.5,
    );
  }

  List<String> _readStringList(dynamic value) {
    if (value is! List) return [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  double _readDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return fallback;
  }

  String _normalizeFilter(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  String _labelFromKey(String value) {
  switch (value) {
    case 'ansiedad':
      return 'Ansiedad';
    case 'depresion':
      return 'Depresión';
    case 'estres':
      return 'Estrés';
    case 'adicciones':
      return 'Adicciones';
    case 'duelo':
      return 'Duelo';
    case 'autoestima':
      return 'Autoestima';
    case 'relaciones':
      return 'Relaciones';
    case 'crisis_emocional':
      return 'Crisis emocional';
    case 'trastornos_alimentarios':
      return 'Trastornos alimentarios';
    case 'orientacion_vocacional':
      return 'Orientación vocacional';

    case 'online':
      return 'En línea';
    case 'presencial':
      return 'Presencial';

    case 'cognitivo_conductual':
      return 'Cognitivo-conductual';
    case 'humanista':
      return 'Humanista';
    case 'sistemico':
      return 'Sistémico';
    case 'psicoeducativo':
      return 'Psicoeducativo';
    case 'integrativo':
      return 'Integrativo';

    case 'adolescentes':
      return 'Adolescentes';
    case 'adultos':
      return 'Adultos';
    case 'parejas':
      return 'Parejas';
    case 'familias':
      return 'Familias';

    default:
      return value;
  }
}

}