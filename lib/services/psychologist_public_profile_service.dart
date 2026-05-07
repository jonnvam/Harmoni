import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PsychologistPublicProfileModel {
  final String uid;
  final List<String> especialidades;
  final List<String> modalidades;
  final List<String> enfoquesTerapia;
  final List<String> atiendeA;
  final int honorariosSesion;
  final String moneda;
  final String descripcionProfesional;
  final int? aniosExperiencia;
  final bool perfilPublicado;
  final bool visibleParaPacientes;

  const PsychologistPublicProfileModel({
    required this.uid,
    required this.especialidades,
    required this.modalidades,
    required this.enfoquesTerapia,
    required this.atiendeA,
    required this.honorariosSesion,
    required this.moneda,
    required this.descripcionProfesional,
    required this.aniosExperiencia,
    required this.perfilPublicado,
    required this.visibleParaPacientes,
  });

  factory PsychologistPublicProfileModel.fromMap(
    Map<String, dynamic> data,
  ) {
    return PsychologistPublicProfileModel(
      uid: (data['uid'] ?? '').toString(),
      especialidades: _stringList(data['especialidades']),
      modalidades: _stringList(data['modalidades']),
      enfoquesTerapia: _stringList(data['enfoquesTerapia']),
      atiendeA: _stringList(data['atiendeA']),
      honorariosSesion: _intValue(data['honorariosSesion']),
      moneda: (data['moneda'] ?? 'MXN').toString(),
      descripcionProfesional:
          (data['descripcionProfesional'] ?? '').toString(),
      aniosExperiencia: data['aniosExperiencia'] is int
          ? data['aniosExperiencia'] as int
          : null,
      perfilPublicado: data['perfilPublicado'] == true,
      visibleParaPacientes: data['visibleParaPacientes'] == true,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  bool get isComplete {
    return uid.isNotEmpty &&
        especialidades.isNotEmpty &&
        modalidades.isNotEmpty &&
        honorariosSesion > 0 &&
        descripcionProfesional.trim().isNotEmpty &&
        perfilPublicado == true &&
        visibleParaPacientes == true;
  }
}

class PsychologistPublicProfileService {
  PsychologistPublicProfileService._();

  static final instance = PsychologistPublicProfileService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> publicProfileRef(String uid) {
    return _db
        .collection('usuariosPsicologos')
        .doc(uid)
        .collection('perfilProfesional')
        .doc('publico');
  }

  Stream<PsychologistPublicProfileModel?> publicProfileStream() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return publicProfileRef(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PsychologistPublicProfileModel.fromMap(doc.data()!);
    });
  }

  Future<void> savePublicProfile({
    required List<String> especialidades,
    required List<String> modalidades,
    required int honorariosSesion,
    required String descripcionProfesional,
    required List<String> enfoquesTerapia,
    required List<String> atiendeA,
    int? aniosExperiencia,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    final cleanEspecialidades = _cleanList(especialidades);
    final cleanModalidades = _cleanList(modalidades);
    final cleanEnfoques = _cleanList(enfoquesTerapia);
    final cleanAtiendeA = _cleanList(atiendeA);
    final cleanDescription = _cleanText(descripcionProfesional);

    _validatePublicProfile(
      especialidades: cleanEspecialidades,
      modalidades: cleanModalidades,
      honorariosSesion: honorariosSesion,
      descripcionProfesional: cleanDescription,
      enfoquesTerapia: cleanEnfoques,
      atiendeA: cleanAtiendeA,
      aniosExperiencia: aniosExperiencia,
    );

    final profileRef = publicProfileRef(uid);
    final psychologistRef = _db.collection('usuariosPsicologos').doc(uid);

    final batch = _db.batch();

    batch.set(
      profileRef,
      {
        'uid': uid,
        'especialidades': cleanEspecialidades,
        'modalidades': cleanModalidades,
        'honorariosSesion': honorariosSesion,
        'moneda': 'MXN',
        'descripcionProfesional': cleanDescription,
        'enfoquesTerapia': cleanEnfoques,
        'atiendeA': cleanAtiendeA,
        'aniosExperiencia': aniosExperiencia,
        'perfilPublicado': true,
        'visibleParaPacientes': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      psychologistRef,
      {
        'professionalProfileCompleted': true,
        'profileVisible': true,
        'publicProfileUpdatedAt': FieldValue.serverTimestamp(),

        // Resumen útil para búsquedas/listados posteriores.
        'especialidades': cleanEspecialidades,
        'modalidades': cleanModalidades,
        'honorariosSesion': honorariosSesion,
        'moneda': 'MXN',
        'descripcionProfesional': cleanDescription,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  List<String> _cleanList(List<String> values) {
    return values
        .map((value) => value.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  String _cleanText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  void _validatePublicProfile({
    required List<String> especialidades,
    required List<String> modalidades,
    required int honorariosSesion,
    required String descripcionProfesional,
    required List<String> enfoquesTerapia,
    required List<String> atiendeA,
    required int? aniosExperiencia,
  }) {
    const allowedEspecialidades = {
      'ansiedad',
      'depresion',
      'estres',
      'adicciones',
      'duelo',
      'autoestima',
      'relaciones',
      'crisis_emocional',
      'trastornos_alimentarios',
      'orientacion_vocacional',
    };

    const allowedModalidades = {
      'online',
      'presencial',
    };

    const allowedEnfoques = {
      'cognitivo_conductual',
      'humanista',
      'sistemico',
      'psicoeducativo',
      'integrativo',
    };

    const allowedAtiendeA = {
      'adolescentes',
      'adultos',
      'parejas',
      'familias',
    };

    if (especialidades.isEmpty) {
      throw ArgumentError('Selecciona al menos una especialidad.');
    }

    if (!especialidades.every(allowedEspecialidades.contains)) {
      throw ArgumentError('Hay una especialidad no válida.');
    }

    if (modalidades.isEmpty) {
      throw ArgumentError('Selecciona al menos una modalidad.');
    }

    if (!modalidades.every(allowedModalidades.contains)) {
      throw ArgumentError('Hay una modalidad no válida.');
    }

    if (!enfoquesTerapia.every(allowedEnfoques.contains)) {
      throw ArgumentError('Hay un enfoque terapéutico no válido.');
    }

    if (!atiendeA.every(allowedAtiendeA.contains)) {
      throw ArgumentError('Hay un tipo de población no válido.');
    }

    if (honorariosSesion < 0 || honorariosSesion > 5000) {
      throw ArgumentError('Ingresa honorarios válidos.');
    }

    if (descripcionProfesional.length < 80) {
      throw ArgumentError(
        'La descripción debe tener al menos 80 caracteres.',
      );
    }

    if (descripcionProfesional.length > 600) {
      throw ArgumentError(
        'La descripción no debe superar los 600 caracteres.',
      );
    }

    if (aniosExperiencia != null &&
        (aniosExperiencia < 0 || aniosExperiencia > 60)) {
      throw ArgumentError('Los años de experiencia no son válidos.');
    }
  }
}