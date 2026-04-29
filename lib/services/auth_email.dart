import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/user_profile_service.dart';

class EmailAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  required String role,
}) async {
  final cleanEmail = email.trim().toLowerCase();
  final cleanRole = role.trim().toLowerCase();

  if (_edadDesde(fechaNacimiento) < 18) {
    throw FirebaseAuthException(
      code: 'underage',
      message: 'Debes ser mayor de 18 años para registrarte.',
    );
  }

  if (!UserProfileService.instance.isValidRole(cleanRole)) {
    throw FirebaseAuthException(
      code: 'invalid-role',
      message: 'Tipo de cuenta no válido.',
    );
  }

  UserCredential? cred;

  try {
    cred = await _auth.createUserWithEmailAndPassword(
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

    await user.updateDisplayName('${nombre.trim()} ${apellido.trim()}');

    await UserProfileService.instance.createEmailUserProfile(
      uid: user.uid,
      nombre: nombre,
      apellido: apellido,
      email: cleanEmail,
      fechaNacimiento: fechaNacimiento,
      role: cleanRole,
    );

    await user.sendEmailVerification();

    return cred;
  } catch (e) {
    final createdUser = cred?.user ?? _auth.currentUser;

    if (createdUser != null && !createdUser.emailVerified) {
      try {
        await createdUser.delete();
      } catch (_) {}
    }

    rethrow;
  }
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