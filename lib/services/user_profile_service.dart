import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  UserProfileService._();

  static final instance = UserProfileService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String rolePaciente = 'paciente';
  static const String rolePsicologo = 'psicologo';

  static const String collectionUsuariosIndex = 'usuariosIndex';
  static const String collectionUsuariosPacientes = 'usuariosPacientes';
  static const String collectionUsuariosPsicologos = 'usuariosPsicologos';

  bool isValidRole(String role) {
    final cleanRole = role.trim().toLowerCase();
    return cleanRole == rolePaciente || cleanRole == rolePsicologo;
  }

  String normalizeRole(String role) {
    return role.trim().toLowerCase();
  }

  String professionalStatusForRole(String role) {
    final cleanRole = normalizeRole(role);

    if (cleanRole == rolePsicologo) {
      return 'documents_pending';
    }

    return 'not_required';
  }

  Future<void> createEmailUserProfile({
    required String uid,
    required String nombre,
    required String apellido,
    required String email,
    required DateTime fechaNacimiento,
    required String role,
  }) async {
    final cleanRole = normalizeRole(role);
    final cleanEmail = email.trim().toLowerCase();

    if (!isValidRole(cleanRole)) {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'Tipo de cuenta no válido.',
      );
    }

    final indexRef = _db.collection(collectionUsuariosIndex).doc(uid);
    final pacienteRef = _db.collection(collectionUsuariosPacientes).doc(uid);
    final psicologoRef = _db.collection(collectionUsuariosPsicologos).doc(uid);

    final batch = _db.batch();

    batch.set(indexRef, {
      'uid': uid,
      'email': cleanEmail,
      'role': cleanRole,
      'profileCompleted': true,
      'provider': 'password',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (cleanRole == rolePaciente) {
      batch.set(pacienteRef, {
        'uid': uid,
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'email': cleanEmail,
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
        'role': rolePaciente,
        'profileCompleted': true,
        'provider': 'password',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Evita que un UID quede duplicado en ambas colecciones.
      
    }

    if (cleanRole == rolePsicologo) {
      batch.set(psicologoRef, {
        'uid': uid,
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'email': cleanEmail,
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
        'role': rolePsicologo,
        'profileCompleted': true,
        'provider': 'password',

        // Estado profesional. El cliente jamás debe ponerse "verified".
        'professionalVerificationStatus': 'documents_pending',

        'professionalDocuments': {
          'ineFrontUrl': null,
          'ineBackUrl': null,
          'cedulaUrl': null,
          'submittedAt': null,
          'reviewedAt': null,
          'reviewedBy': null,
          'rejectionReason': null,
        },

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Evita que un UID quede duplicado en ambas colecciones.
      
    }

    await batch.commit();
  }

  Future<void> createGoogleBaseIndex({
    required User user,
    DateTime? fechaNacimiento,
  }) async {
    final indexRef = _db.collection(collectionUsuariosIndex).doc(user.uid);

    await indexRef.set({
      'uid': user.uid,
      'email': user.email?.trim().toLowerCase(),
      'role': null,
      'profileCompleted': false,
      'provider': 'google',
      'foto': user.photoURL,
      if (fechaNacimiento != null)
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> completeGoogleRegistration({
    required User user,
    required String role,
    DateTime? fechaNacimiento,
  }) async {
    final cleanRole = normalizeRole(role);

    if (!isValidRole(cleanRole)) {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'Tipo de cuenta no válido.',
      );
    }

    final nombre = user.displayName?.split(' ').first ?? '';
    final apellido = user.displayName?.split(' ').skip(1).join(' ') ?? '';
    final email = user.email?.trim().toLowerCase() ?? '';

    final indexRef = _db.collection(collectionUsuariosIndex).doc(user.uid);
    final pacienteRef =
        _db.collection(collectionUsuariosPacientes).doc(user.uid);
    final psicologoRef =
        _db.collection(collectionUsuariosPsicologos).doc(user.uid);

    final batch = _db.batch();

    batch.set(indexRef, {
      'uid': user.uid,
      'email': email,
      'role': cleanRole,
      'profileCompleted': true,
      'provider': 'google',
      'foto': user.photoURL,
      if (fechaNacimiento != null)
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (cleanRole == rolePaciente) {
      batch.set(pacienteRef, {
        'uid': user.uid,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'foto': user.photoURL,
        'role': rolePaciente,
        'profileCompleted': true,
        'provider': 'google',
        if (fechaNacimiento != null)
          'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      
    }

    if (cleanRole == rolePsicologo) {
      batch.set(psicologoRef, {
        'uid': user.uid,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'foto': user.photoURL,
        'role': rolePsicologo,
        'profileCompleted': true,
        'provider': 'google',
        if (fechaNacimiento != null)
          'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),

        'professionalVerificationStatus': 'documents_pending',

        'professionalDocuments': {
          'ineFrontUrl': null,
          'ineBackUrl': null,
          'cedulaUrl': null,
          'submittedAt': null,
          'reviewedAt': null,
          'reviewedBy': null,
          'rejectionReason': null,
        },

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      
    }

    await batch.commit();
  }

  Future<AuthUserProfile?> loadProfileAfterAuth(String uid) async {
    final indexDoc =
        await _db.collection(collectionUsuariosIndex).doc(uid).get();

    if (!indexDoc.exists || indexDoc.data() == null) {
      return _loadProfileFallback(uid);
    }

    final indexData = indexDoc.data()!;
    final role = (indexData['role'] ?? '').toString().trim().toLowerCase();
    final profileCompleted = indexData['profileCompleted'] == true;

    if (!profileCompleted || role.isEmpty || role == 'null') {
      return AuthUserProfile(
        uid: uid,
        role: null,
        profileCompleted: false,
        collectionName: collectionUsuariosIndex,
        data: indexData,
      );
    }

    if (role == rolePaciente) {
      final pacienteDoc =
          await _db.collection(collectionUsuariosPacientes).doc(uid).get();

      if (!pacienteDoc.exists || pacienteDoc.data() == null) {
        return null;
      }

      return AuthUserProfile(
        uid: uid,
        role: rolePaciente,
        profileCompleted: true,
        collectionName: collectionUsuariosPacientes,
        data: pacienteDoc.data()!,
      );
    }

    if (role == rolePsicologo) {
      final psicologoDoc =
          await _db.collection(collectionUsuariosPsicologos).doc(uid).get();

      if (!psicologoDoc.exists || psicologoDoc.data() == null) {
        return null;
      }

      final data = psicologoDoc.data()!;

      return AuthUserProfile(
        uid: uid,
        role: rolePsicologo,
        profileCompleted: true,
        collectionName: collectionUsuariosPsicologos,
        data: data,
        professionalVerificationStatus:
            (data['professionalVerificationStatus'] ?? '')
                .toString()
                .trim()
                .toLowerCase(),
      );
    }

    return null;
  }

  Future<AuthUserProfile?> _loadProfileFallback(String uid) async {
    final pacienteDoc =
        await _db.collection(collectionUsuariosPacientes).doc(uid).get();

    if (pacienteDoc.exists && pacienteDoc.data() != null) {
      final data = pacienteDoc.data()!;

      return AuthUserProfile(
        uid: uid,
        role: rolePaciente,
        profileCompleted: true,
        collectionName: collectionUsuariosPacientes,
        data: data,
      );
    }

    final psicologoDoc =
        await _db.collection(collectionUsuariosPsicologos).doc(uid).get();

    if (psicologoDoc.exists && psicologoDoc.data() != null) {
      final data = psicologoDoc.data()!;

      return AuthUserProfile(
        uid: uid,
        role: rolePsicologo,
        profileCompleted: true,
        collectionName: collectionUsuariosPsicologos,
        data: data,
        professionalVerificationStatus:
            (data['professionalVerificationStatus'] ?? '')
                .toString()
                .trim()
                .toLowerCase(),
      );
    }

    return null;
  }
}

class AuthUserProfile {
  final String uid;
  final String? role;
  final bool profileCompleted;
  final String collectionName;
  final Map<String, dynamic> data;
  final String? professionalVerificationStatus;

  AuthUserProfile({
    required this.uid,
    required this.role,
    required this.profileCompleted,
    required this.collectionName,
    required this.data,
    this.professionalVerificationStatus,
  });

  bool get isPaciente => role == UserProfileService.rolePaciente;

  bool get isPsicologo => role == UserProfileService.rolePsicologo;

  bool get isVerifiedPsychologist =>
      isPsicologo && professionalVerificationStatus == 'verified';

  bool get needsProfessionalVerification {
    if (!isPsicologo) return false;
    return professionalVerificationStatus != 'verified';
  }
}