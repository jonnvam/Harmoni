import 'dart:async';

import 'package:flutter_application_1/models/psychologist.dart';

/// Abstracción del origen de datos (local/remoto)
abstract class PsychologistsDataSource {
  Future<List<Psychologist>> fetchAll({
    String? query,
    int? maxPrice,
    double? minRating,
    String? specialty,
  });
}

class PsychologistsRepo {
  static final PsychologistsRepo instance = PsychologistsRepo._();
  PsychologistsRepo._();

  // Por defecto usa remoto con fallback a local
  PsychologistsDataSource remote = _RemotePsychologistsDataSource();
  PsychologistsDataSource local = _LocalPsychologistsDataSource();

  Future<List<Psychologist>> fetchAll({
    String? query,
    int? maxPrice,
    double? minRating,
    String? specialty,
  }) async {
    try {
      final list = await remote.fetchAll(
        query: query,
        maxPrice: maxPrice,
        minRating: minRating,
        specialty: specialty,
      );
      return list;
    } catch (_) {
      // Fallback a local cuando falle remoto
      return local.fetchAll(
        query: query,
        maxPrice: maxPrice,
        minRating: minRating,
        specialty: specialty,
      );
    }
  }
}

class _LocalPsychologistsDataSource implements PsychologistsDataSource {
  final List<Psychologist> _all = [
    Psychologist(
      id: 'p1',
      name: 'Ana López',
      rating: 4.9,
      price: 650,
      specialties: ['Ansiedad', 'Estrés'],
      isTop: true,
      isAvailable: true,
      avatarAsset: 'assets/images/icon/psicologos.svg',
    ),
    Psychologist(
      id: 'p2',
      name: 'Carlos Rivera',
      rating: 4.6,
      price: 500,
      specialties: ['Depresión', 'Duelo'],
      isAvailable: false,
    ),
    Psychologist(
      id: 'p3',
      name: 'María Pérez',
      rating: 5.0,
      price: 800,
      specialties: ['Pareja', 'Autoestima'],
      isTop: true,
      isAvailable: true,
    ),
    Psychologist(
      id: 'p4',
      name: 'Jorge Soto',
      rating: 4.3,
      price: 400,
      specialties: ['Adicciones'],
    ),
    Psychologist(
      id: 'p5',
      name: 'Lucía Gómez',
      rating: 4.7,
      price: 550,
      specialties: ['Trauma', 'Mindfulness'],
      isAvailable: true,
    ),
    // ... puedes agregar más
  ];

  @override
  Future<List<Psychologist>> fetchAll({
    String? query,
    int? maxPrice,
    double? minRating,
    String? specialty,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    Iterable<Psychologist> list = _all;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.specialties.any((s) => s.toLowerCase().contains(q)));
    }
    if (maxPrice != null) {
      list = list.where((p) => p.price <= maxPrice);
    }
    if (minRating != null) {
      list = list.where((p) => p.rating >= minRating);
    }
    if (specialty != null && specialty.isNotEmpty) {
      final s = specialty.toLowerCase();
      list = list.where((p) => p.specialties.any((e) => e.toLowerCase().contains(s)));
    }
    return list.toList();
  }
}

/// Data source remoto: reemplaza la URL y la estructura cuando tengas tu backend listo.
class _RemotePsychologistsDataSource implements PsychologistsDataSource {
  // Por hacer: Inyectar cliente http y baseUrl desde configuración
  @override
  Future<List<Psychologist>> fetchAll({
    String? query,
    int? maxPrice,
    double? minRating,
    String? specialty,
  }) async {
    // Placeholder: lanza para forzar fallback hasta conectar backend
    throw UnimplementedError('Configura backend remoto para psicólogos');
  }
}
