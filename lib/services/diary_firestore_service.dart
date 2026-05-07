import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_application_1/services/user_profile_service.dart';

class DiaryFirestoreService {
  DiaryFirestoreService._();

  static final instance = DiaryFirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> notesCol(String uid) {
    return _db
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(uid)
        .collection('notas');
  }

  Query<Map<String, dynamic>> notesByCreatedAtQuery(String uid) {
    return notesCol(uid).orderBy('createdAt', descending: true);
  }

  Reference diaryImageRef({
    required String uid,
    required String docId,
  }) {
    return _storage
        .ref()
        .child(UserProfileService.collectionUsuariosPacientes)
        .child(uid)
        .child('diario')
        .child('$docId.jpg');
  }

  Future<String> uploadDiaryImage({
    required String uid,
    required String docId,
    required File file,
  }) async {
    final ref = diaryImageRef(uid: uid, docId: docId);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> addTextNote({
    required String titulo,
    required String texto,
    String? emocion,
    String? icono,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    final cleanTitulo = titulo.trim().isEmpty ? 'Nota' : titulo.trim();
    final cleanTexto = texto.trim();

    if (cleanTexto.isEmpty) {
      throw ArgumentError('La nota no puede estar vacía.');
    }

    await notesCol(uid).add({
      'uid': uid,
      'titulo': cleanTitulo,
      'texto': cleanTexto,
      'tipo': 'texto',
      'imageUrl': null,
      if (emocion != null) 'emocion': emocion,
      if (icono != null) 'icono': icono,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> createImagePlaceholder({
    required String titulo,
    String? texto,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    return notesCol(uid).add({
      'uid': uid,
      'titulo': titulo.trim().isEmpty ? 'Imagen' : titulo.trim(),
      'texto': texto == null || texto.trim().isEmpty ? null : texto.trim(),
      'tipo': 'imagen',
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> attachImageToNote({
    required DocumentReference<Map<String, dynamic>> noteRef,
    required String imageUrl,
  }) async {
    await noteRef.update({
      'imageUrl': imageUrl,
      'tipo': 'imagen',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNote({
    required String docId,
    required String titulo,
    required String? texto,
    required String tipo,
    required String? imageUrl,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    await notesCol(uid).doc(docId).update({
      'titulo': titulo.trim().isEmpty ? 'Nota' : titulo.trim(),
      'texto': texto == null || texto.trim().isEmpty ? null : texto.trim(),
      'tipo': tipo,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote({
    required String docId,
    String? imageUrl,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    await notesCol(uid).doc(docId).delete();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (_) {
        // Si el archivo ya no existe o no se puede borrar,
        // no bloqueamos la eliminación del documento.
      }
    }
  }
}