import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvailabilityBlock {
  final String inicio;
  final String fin;

  const AvailabilityBlock({
    required this.inicio,
    required this.fin,
  });

  Map<String, dynamic> toMap() {
    return {
      'inicio': inicio,
      'fin': fin,
    };
  }

  factory AvailabilityBlock.fromMap(Map<String, dynamic> map) {
    return AvailabilityBlock(
      inicio: (map['inicio'] ?? '').toString(),
      fin: (map['fin'] ?? '').toString(),
    );
  }
}

class DayAvailability {
  final String diaId;
  final String diaNombre;
  final bool activo;
  final List<AvailabilityBlock> bloques;
  final List<String> modalidades;

  const DayAvailability({
    required this.diaId,
    required this.diaNombre,
    required this.activo,
    required this.bloques,
    required this.modalidades,
  });

  factory DayAvailability.empty({
    required String diaId,
    required String diaNombre,
  }) {
    return DayAvailability(
      diaId: diaId,
      diaNombre: diaNombre,
      activo: false,
      bloques: const [],
      modalidades: const ['online'],
    );
  }

  factory DayAvailability.fromMap({
    required String diaId,
    required String diaNombre,
    required Map<String, dynamic> data,
  }) {
    final rawBlocks = data['bloques'];

    final blocks = rawBlocks is List
        ? rawBlocks
            .whereType<Map>()
            .map((item) => AvailabilityBlock.fromMap(
                  Map<String, dynamic>.from(item),
                ))
            .toList()
        : <AvailabilityBlock>[];

    final rawModalidades = data['modalidades'];

    final modalidades = rawModalidades is List
        ? rawModalidades
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList()
        : <String>['online'];

    return DayAvailability(
      diaId: diaId,
      diaNombre: diaNombre,
      activo: data['activo'] == true,
      bloques: blocks,
      modalidades: modalidades,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'diaId': diaId,
      'diaNombre': diaNombre,
      'activo': activo,
      'bloques': bloques.map((block) => block.toMap()).toList(),
      'modalidades': modalidades,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  DayAvailability copyWith({
    bool? activo,
    List<AvailabilityBlock>? bloques,
    List<String>? modalidades,
  }) {
    return DayAvailability(
      diaId: diaId,
      diaNombre: diaNombre,
      activo: activo ?? this.activo,
      bloques: bloques ?? this.bloques,
      modalidades: modalidades ?? this.modalidades,
    );
  }
}

class PsychologistAvailabilityService {
  PsychologistAvailabilityService._();

  static final instance = PsychologistAvailabilityService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const List<Map<String, String>> days = [
    {'id': 'lunes', 'name': 'Lunes'},
    {'id': 'martes', 'name': 'Martes'},
    {'id': 'miercoles', 'name': 'Miércoles'},
    {'id': 'jueves', 'name': 'Jueves'},
    {'id': 'viernes', 'name': 'Viernes'},
    {'id': 'sabado', 'name': 'Sábado'},
    {'id': 'domingo', 'name': 'Domingo'},
  ];

  String? get currentUid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> availabilityCol(String uid) {
    return _db
        .collection('usuariosPsicologos')
        .doc(uid)
        .collection('disponibilidad');
  }

  Stream<List<DayAvailability>> watchMyAvailability() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return availabilityCol(uid).snapshots().map((snapshot) {
      final docsById = {
        for (final doc in snapshot.docs) doc.id: doc.data(),
      };

      return days.map((day) {
        final id = day['id']!;
        final name = day['name']!;
        final data = docsById[id];

        if (data == null) {
          return DayAvailability.empty(
            diaId: id,
            diaNombre: name,
          );
        }

        return DayAvailability.fromMap(
          diaId: id,
          diaNombre: name,
          data: data,
        );
      }).toList();
    });
  }

  Future<void> saveAvailability({
    required List<DayAvailability> availability,
    required int sessionDurationMinutes,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    _validateAvailability(
      availability: availability,
      sessionDurationMinutes: sessionDurationMinutes,
    );

    final batch = _db.batch();

    for (final day in availability) {
      final ref = availabilityCol(uid).doc(day.diaId);
      batch.set(ref, day.toMap(), SetOptions(merge: true));
    }

    batch.set(
      _db.collection('usuariosPsicologos').doc(uid),
      {
        'sessionDurationMinutes': sessionDurationMinutes,
        'availabilityConfigured': true,
        'availabilityUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  void _validateAvailability({
    required List<DayAvailability> availability,
    required int sessionDurationMinutes,
  }) {
    if (![30, 45, 50, 60, 90].contains(sessionDurationMinutes)) {
      throw ArgumentError('La duración de sesión no es válida.');
    }

    for (final day in availability) {
      if (day.activo && day.bloques.isEmpty) {
        throw ArgumentError(
          'Agrega al menos un bloque horario para ${day.diaNombre}.',
        );
      }

      if (!day.modalidades.every((m) => ['online', 'presencial'].contains(m))) {
        throw ArgumentError('Hay una modalidad no válida.');
      }

      for (final block in day.bloques) {
        final start = _timeToMinutes(block.inicio);
        final end = _timeToMinutes(block.fin);

        if (start == null || end == null) {
          throw ArgumentError('El formato de horario no es válido.');
        }

        if (start >= end) {
          throw ArgumentError(
            'El bloque de ${day.diaNombre} tiene una hora final inválida.',
          );
        }

        if (end - start < sessionDurationMinutes) {
          throw ArgumentError(
            'Un bloque de ${day.diaNombre} es menor que la duración de sesión.',
          );
        }
      }
    }
  }

  int? _timeToMinutes(String value) {
    final parts = value.split(':');

    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }
}