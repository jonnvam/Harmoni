import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailAuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  int _edadDesde(DateTime dob) {
    final hoy = DateTime.now();
    int edad = hoy.year - dob.year;
    final cumpleEsteAnio = DateTime(hoy.year, dob.month, dob.day);
    if (hoy.isBefore(cumpleEsteAnio)) edad--;
    return edad;
  }

  Future<UserCredential> signUp({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required DateTime fechaNacimiento,
  }) async {
    if (_edadDesde(fechaNacimiento) < 18) {
      throw FirebaseAuthException(
        code: 'underage',
        message: 'Debes ser mayor de 18 años para registrarte.',
      );
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await cred.user!.updateDisplayName('$nombre $apellido');

    await _db.collection('usuarios').doc(cred.user!.uid).set({
      'nombre': nombre,
      'apellido': apellido,
      'email': email.trim(),
      'fechaNacimiento': Timestamp.fromDate(fechaNacimiento)
    }, SetOptions(merge: true));

    await cred.user!.sendEmailVerification();

    return cred;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user;
    if (user != null && !user.emailVerified) {
      // Opcional: reenviar automáticamente para mejorar UX
      try { await user.sendEmailVerification(); } catch (_) {}
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
