import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AgeGateException implements Exception {
  final String message;

  AgeGateException([this.message = 'Debes ser mayor de 18 años']);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/user.birthday.read',
    ],
  );

  Future<UserCredential?> signUpWithGoogle(BuildContext context) async {
    try {
      await _safeDisconnect();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      final userRef = _db.collection('usuarios').doc(user.uid);
      final currentDoc = await userRef.get();

      DateTime? birthDate = await _fetchBirthday(googleAuth.accessToken);
      birthDate ??= await _askBirthdate(context);

      if (birthDate == null) {
        await _handleUnderageOrUnknown(
          user,
          context,
          reason: 'No proporcionaste fecha de nacimiento.',
        );
        return null;
      }

      if (!_isAdult(birthDate)) {
        await _handleUnderageOrUnknown(user, context);
        return null;
      }

      final nombre = user.displayName?.split(' ').first ?? '';
      final apellido = user.displayName?.split(' ').skip(1).join(' ') ?? '';

      if (!currentDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'nombre': nombre,
          'apellido': apellido,
          'email': user.email,
          'foto': user.photoURL,
          'fechaNacimiento': Timestamp.fromDate(birthDate),

          // Google aún no tiene rol hasta completar registro.
          'role': null,
          'professionalVerificationStatus': null,
          'profileCompleted': false,

          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.set({
          'nombre': nombre,
          'apellido': apellido,
          'email': user.email,
          'foto': user.photoURL,
          'fechaNacimiento': Timestamp.fromDate(birthDate),
          'provider': 'google',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error en registro con Google: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? existing =
          await _googleSignIn.signInSilently();

      final GoogleSignInAccount? googleUser =
          existing ?? await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      final userRef = _db.collection('usuarios').doc(user.uid);
      final currentDoc = await userRef.get();

      if (!currentDoc.exists) {
        DateTime? birthDate = await _fetchBirthday(googleAuth.accessToken);
        birthDate ??= await _askBirthdate(context);

        if (birthDate == null) {
          await _handleUnderageOrUnknown(
            user,
            context,
            reason: 'No proporcionaste fecha de nacimiento.',
          );
          return null;
        }

        if (!_isAdult(birthDate)) {
          await _handleUnderageOrUnknown(user, context);
          return null;
        }

        await userRef.set({
          'uid': user.uid,
          'nombre': user.displayName?.split(' ').first ?? '',
          'apellido': user.displayName?.split(' ').skip(1).join(' ') ?? '',
          'email': user.email,
          'foto': user.photoURL,
          'fechaNacimiento': Timestamp.fromDate(birthDate),

          // No se asigna rol desde login.
          'role': null,
          'professionalVerificationStatus': null,
          'profileCompleted': false,

          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.set({
          'email': user.email,
          'foto': user.photoURL,
          'provider': 'google',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error al iniciar sesión con Google: $e');
      return null;
    }
  }

  Future<void> completeGoogleRegistration({
    required String uid,
    required String role,
  }) async {
    final cleanRole = role.trim().toLowerCase();

    if (cleanRole != 'paciente' && cleanRole != 'psicologo') {
      throw FirebaseAuthException(
        code: 'invalid-role',
        message: 'Tipo de cuenta no válido.',
      );
    }

    final professionalStatus =
        cleanRole == 'psicologo' ? 'documents_pending' : 'not_required';

    await _db.collection('usuarios').doc(uid).set({
      'role': cleanRole,
      'professionalVerificationStatus': professionalStatus,
      'profileCompleted': true,
      'professionalDocuments': {
        'ineFrontUrl': null,
        'ineBackUrl': null,
        'cedulaUrl': null,
        'submittedAt': null,
        'reviewedAt': null,
        'reviewedBy': null,
        'rejectionReason': null,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _safeDisconnect();
    await _auth.signOut();
  }

  Future<void> _safeDisconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      await _googleSignIn.signOut();
    }
  }

  Future<DateTime?> _fetchBirthday(String? accessToken) async {
    if (accessToken == null) return null;

    try {
      final uri = Uri.parse(
        'https://people.googleapis.com/v1/people/me?personFields=birthdays',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final birthdays = data['birthdays'];

      if (birthdays == null || birthdays is! List || birthdays.isEmpty) {
        return null;
      }

      Map<String, dynamic>? bestDate;

      for (final birthday in birthdays) {
        if (birthday is Map &&
            birthday['date'] is Map &&
            birthday['date']['year'] != null) {
          bestDate = Map<String, dynamic>.from(birthday['date']);
          break;
        }
      }

      bestDate ??= birthdays.first['date'] is Map
          ? Map<String, dynamic>.from(birthdays.first['date'])
          : null;

      if (bestDate == null) return null;

      final year = bestDate['year'];
      final month = bestDate['month'];
      final day = bestDate['day'];

      if (year == null || month == null || day == null) return null;

      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> _askBirthdate(BuildContext context) async {
    DateTime? selected;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Completa tu información'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selecciona tu fecha de nacimiento:'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000, 1, 1),
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      setDialogState(() {
                        selected = picked;
                      });
                    }
                  },
                  child: Text(
                    selected == null
                        ? 'Elegir fecha'
                        : '${selected!.day.toString().padLeft(2, '0')}/${selected!.month.toString().padLeft(2, '0')}/${selected!.year}',
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              selected = null;
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    return selected;
  }

  bool _isAdult(DateTime birth) {
    final now = DateTime.now();

    int age = now.year - birth.year;

    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }

    return age >= 18;
  }

  Future<void> _handleUnderageOrUnknown(
    User user,
    BuildContext context, {
    String? reason,
  }) async {
    try {
      await user.delete();
    } catch (_) {}

    await _safeDisconnect();
    await _auth.signOut();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reason ?? 'Debes ser mayor de 18 años para usar la app.',
          ),
        ),
      );
    }
  }
}