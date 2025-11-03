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
      final user = userCredential.user!;
      final userDoc = _db.collection('usuarios').doc(user.uid);

      DateTime? cumple = await _fetchBirthday(googleAuth.accessToken);
      cumple ??= await _askBirthdate(context);

      if (cumple == null) {
        await _handleUnderageOrUnknown(user, context,
            reason: 'No proporcionaste fecha de nacimiento.');
        return null;
      }
      if (!_isAdult(cumple)) {
        await _handleUnderageOrUnknown(user, context);
        return null;
      }

      final nombre = user.displayName?.split(' ').first ?? '';
      final apellido = user.displayName?.split(' ').skip(1).join(' ') ?? '';

      await userDoc.set({
        'nombre': nombre,
        'apellido': apellido,
        'email': user.email,
        'foto': user.photoURL,
        'fechaRegistro': DateTime.now(),
        'fechaNacimiento': cumple.toIso8601String(),
      }, SetOptions(merge: true));

      return userCredential;
    } catch (e) {
      debugPrint('Error en registro con Google: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? existing = await _googleSignIn.signInSilently();
      final GoogleSignInAccount? googleUser = existing ?? await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      final userDoc = _db.collection('usuarios').doc(user.uid);

      await userDoc.set({
        'nombre': user.displayName?.split(' ').first ?? '',
        'apellido': user.displayName?.split(' ').skip(1).join(' ') ?? '',
        'email': user.email,
        'foto': user.photoURL,
      }, SetOptions(merge: true));

      DateTime? cumple = await _fetchBirthday(googleAuth.accessToken);
      cumple ??= await _askBirthdate(context);

      if (cumple == null) {
        await _handleUnderageOrUnknown(user, context,
            reason: 'No proporcionaste fecha de nacimiento.');
        return null;
      }
      if (!_isAdult(cumple)) {
        await _handleUnderageOrUnknown(user, context);
        return null;
      }

      await userDoc.set({
        'fechaNacimiento': cumple.toIso8601String(),
      }, SetOptions(merge: true));

      return userCredential;
    } catch (e) {
      debugPrint('Error al iniciar sesión con Google: $e');
      return null;
    }
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
          'https://people.googleapis.com/v1/people/me?personFields=birthdays');
      final r = await http.get(uri, headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (r.statusCode != 200) return null;

      final data = jsonDecode(r.body);
      final list = data['birthdays'];
      if (list == null || list is! List || list.isEmpty) return null;

      Map<String, dynamic>? best;
      for (final b in list) {
        if (b is Map && b['date'] is Map && b['date']['year'] != null) {
          best = Map<String, dynamic>.from(b['date']);
          break;
        }
      }
      best ??= (list.first['date'] is Map) ? Map<String, dynamic>.from(list.first['date']) : null;
      if (best == null) return null;

      final y = best['year'];
      final m = best['month'];
      final d = best['day'];
      if (y == null || m == null || d == null) return null;

      return DateTime(y, m, d);
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
        content: Column(
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
                if (picked != null) selected = picked;
              },
              child: const Text('Elegir fecha'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    } catch (_) {
    }
    await _safeDisconnect();
    await _auth.signOut();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reason ?? 'Debes ser mayor de 18 años para usar la app.'),
        ),
      );
    }
  }
}
