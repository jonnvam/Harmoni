import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/goals_manager.dart';
import 'package:flutter_application_1/services/user_profile_service.dart';

class GoalsFirestoreService {
  GoalsFirestoreService._();

  static final instance = GoalsFirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _metasCol(String uid) {
    return _db
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(uid)
        .collection('metas');
  }

  String? get currentUid => _auth.currentUser?.uid;

  Query<Map<String, dynamic>> metasPorEstadoQuery({
    required String uid,
    required String estado,
  }) {
    return _metasCol(uid)
        .where('estado', isEqualTo: estado)
        .orderBy('creada', descending: true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> allGoalsStream(String uid) {
  return _metasCol(uid).snapshots();
}

  Future<void> startRecommendedGoal(Goal goal) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    final docId = _safeGoalId(goal.titulo);

    await _metasCol(uid).doc(docId).set({
      'uid': uid,
      'titulo': goal.titulo.trim(),
      'descripcion': goal.descripcion.trim(),
      'estado': 'en_progreso',
      'prioridad': 'media',
      'source': 'recommended',
      'creada': FieldValue.serverTimestamp(),
      'actualizada': FieldValue.serverTimestamp(),
      'completadaAt': null,
    }, SetOptions(merge: true));
  }

  Future<void> createManualGoal({
    required String titulo,
    required String descripcion,
    required String prioridad,
    DateTime? fechaLimite,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    final cleanTitulo = titulo.trim();
    final cleanDescripcion = descripcion.trim();
    final cleanPrioridad = prioridad.trim().toLowerCase();

    if (cleanTitulo.isEmpty || cleanDescripcion.isEmpty) {
      throw ArgumentError('Completa título y descripción.');
    }

    if (!['baja', 'media', 'alta'].contains(cleanPrioridad)) {
      throw ArgumentError('Prioridad no válida.');
    }

    await _metasCol(uid).add({
      'uid': uid,
      'titulo': cleanTitulo,
      'descripcion': cleanDescripcion,
      'estado': 'en_progreso',
      'prioridad': cleanPrioridad,
      'source': 'manual',
      'creada': FieldValue.serverTimestamp(),
      'actualizada': FieldValue.serverTimestamp(),
      'completadaAt': null,
      if (fechaLimite != null)
        'fechaLimite': Timestamp.fromDate(fechaLimite),
    });
  }

  Future<void> updateGoal({
  required DocumentReference<Map<String, dynamic>> goalRef,
  required String titulo,
  required String descripcion,
  required String prioridad,
  DateTime? fechaLimite,
}) async {
  final uid = currentUid;

  if (uid == null) {
    throw FirebaseAuthException(
      code: 'not-authenticated',
      message: 'Debes iniciar sesión.',
    );
  }

  final cleanTitulo = titulo.trim();
  final cleanDescripcion = descripcion.trim();
  final cleanPrioridad = prioridad.trim().toLowerCase();

  if (cleanTitulo.isEmpty || cleanDescripcion.isEmpty) {
    throw ArgumentError('Completa título y descripción.');
  }

  if (!['baja', 'media', 'alta'].contains(cleanPrioridad)) {
    throw ArgumentError('Prioridad no válida.');
  }

  await goalRef.update({
    'titulo': cleanTitulo,
    'descripcion': cleanDescripcion,
    'prioridad': cleanPrioridad,
    'actualizada': FieldValue.serverTimestamp(),
    if (fechaLimite != null)
      'fechaLimite': Timestamp.fromDate(fechaLimite)
    else
      'fechaLimite': FieldValue.delete(),
  });
}

  Future<void> completeGoal({
    required DocumentReference<Map<String, dynamic>> goalRef,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    await goalRef.update({
      'estado': 'completada',
      'completadaAt': FieldValue.serverTimestamp(),
      'actualizada': FieldValue.serverTimestamp(),
    });
  }

  String _safeGoalId(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9áéíóúñü]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}