import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int _edadDesde(DateTime dob) {
    final hoy = DateTime.now();
    int edad = hoy.year - dob.year;
    final cumpleEsteAnio = DateTime(hoy.year, dob.month, dob.day);

    if (hoy.isBefore(cumpleEsteAnio)) edad--;

    return edad;
  }

  bool _isValidRole(String role) {
    return role == 'paciente' || role == 'psicologo';
  }

  String _professionalStatusForRole(String role) {
    if (role == 'psicologo') {
      return 'documents_pending';
    }

    return 'not_required';
  }

  Future<UserCredential> signUp({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required DateTime fechaNacimiento,
    required String role,
  }) async {
    final cleanRole = role.trim().toLowerCase();

    if (!_isValidRole(cleanRole)) {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'Tipo de cuenta no válido.',
      );
    }

    if (_edadDesde(fechaNacimiento) < 18) {
      throw FirebaseAuthException(
        code: 'underage',
        message: 'Debes ser mayor de 18 años para registrarte.',
      );
    }

    final cleanEmail = email.trim().toLowerCase();

    final cred = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = cred.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'No se pudo crear el usuario.',
      );
    }

    await user.updateDisplayName('$nombre $apellido');

    await _db.collection('usuarios').doc(user.uid).set({
      'uid': user.uid,
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'email': cleanEmail,
      'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),

      // Rol declarado durante el registro.
      'role': cleanRole,
      'profileCompleted': true,

      // Estado de verificación profesional.
      // Paciente: no requiere documentos.
      // Psicólogo: queda bloqueado hasta subir y aprobar documentos.
      'professionalVerificationStatus': _professionalStatusForRole(cleanRole),

      // Campos preparados para documentos profesionales.
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

    await user.sendEmailVerification();

    return cred;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = cred.user;

    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
      } catch (_) {}

      await _auth.signOut();

      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Tu correo aún no está verificado.',
      );
    }

    return user;
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> refreshVerificationStatus() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    await user.reload();

    return _auth.currentUser?.emailVerified == true;
  }
}