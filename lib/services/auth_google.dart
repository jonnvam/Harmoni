import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null; // usuario canceló

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userDoc = _db.collection('usuarios').doc(user.uid);
      final snapshot = await userDoc.get();

      String? fechaNacimiento;

      //Intentar obtener fecha de nacimiento desde People API
      try {
        final response = await http.get(
          Uri.parse('https://people.googleapis.com/v1/people/me?personFields=birthdays'),
          headers: {'Authorization': 'Bearer ${googleAuth.accessToken}'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['birthdays'] != null && data['birthdays'].isNotEmpty) {
            final date = data['birthdays'][0]['date'];
            fechaNacimiento =
                "${date['year']}-${date['month'].toString().padLeft(2, '0')}-${date['day'].toString().padLeft(2, '0')}";
          }
        }
      } catch (e) {
        print("⚠️ No se pudo obtener fecha automáticamente: $e");
      }

      // Crear documento si no existe
      if (!snapshot.exists) {
        await userDoc.set({
          'nombre': user.displayName?.split(' ').first ?? '',
          'apellido': user.displayName?.split(' ').skip(1).join(' ') ?? '',
          'email': user.email,
          'foto': user.photoURL,
          'fechaRegistro': DateTime.now(),
          'fechaNacimiento': fechaNacimiento,
        });

        //Si no se obtuvo la fecha, pedirla al usuario
        if (fechaNacimiento == null) {
          await _pedirFechaNacimiento(context, userDoc);
        }
      }

      return userCredential;
    } catch (e) {
      print("Error en registro con Google: $e");
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      // Si no hay sesión activa, abre selector de cuentas
      final GoogleSignInAccount? userToUse =
          googleUser ?? await _googleSignIn.signIn();

      if (userToUse == null) return null; // usuario canceló

      final googleAuth = await userToUse.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userDoc = _db.collection('usuarios').doc(user.uid);
      final snapshot = await userDoc.get();

      // Si el documento no existe, crearlo
      if (!snapshot.exists) {
        await userDoc.set({
          'nombre': user.displayName?.split(' ').first ?? '',
          'apellido': user.displayName?.split(' ').skip(1).join(' ') ?? '',
          'email': user.email,
          'foto': user.photoURL,
          'fechaRegistro': DateTime.now(),
          'fechaNacimiento': null,
        });
      }

      // Verificar si falta fecha de nacimiento
      final data = (await userDoc.get()).data();
      if (data != null &&
          (data['fechaNacimiento'] == null || data['fechaNacimiento'] == "")) {
        await _pedirFechaNacimiento(context, userDoc);
      }

      return userCredential;
    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _pedirFechaNacimiento(
      BuildContext context, DocumentReference userDoc) async {
    DateTime? fechaSeleccionada;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Completa tu información"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Selecciona tu fecha de nacimiento:"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  fechaSeleccionada = picked;
                }
              },
              child: const Text("Elegir fecha"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              if (fechaSeleccionada != null) {
                await userDoc.update({
                  'fechaNacimiento': fechaSeleccionada!.toIso8601String(),
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
