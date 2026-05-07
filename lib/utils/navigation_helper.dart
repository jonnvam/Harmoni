import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> navigateToHome(
  BuildContext context, {
  FirebaseAuth? auth,
  FirebaseFirestore? firestore,
}) async {
  final authInstance = auth ?? FirebaseAuth.instance;
  final db = firestore ?? FirebaseFirestore.instance;
  final user = authInstance.currentUser;

  if (user == null) {
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    return;
  }

  String role = 'paciente';

  final usuariosDoc = await db.collection('usuarios').doc(user.uid).get();
  if (usuariosDoc.exists) {
    role = (usuariosDoc.data()?['role'] ?? 'paciente').toString();
  } else {
    final usersDoc = await db.collection('users').doc(user.uid).get();
    if (usersDoc.exists) {
      role = (usersDoc.data()?['role'] ?? 'paciente').toString();
    }
  }

  final target = role == 'psicologo' ? '/psychologist_home' : '/patient_home';

  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(context, target, (_) => false);
}
