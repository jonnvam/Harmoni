import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesService {
  static final NotesService instance = NotesService._();
  NotesService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }
    return _db.collection('usuarios').doc(uid).collection('metas');
  }

  Future<void> addNote({
    required String titulo,
    required String descripcion,
  }) async {
    await _col().add({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'creada': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notesStream() {
    return _col().orderBy('creada', descending: true).snapshots();
  }

  Future<void> updateNote(String id, {required String titulo, required String descripcion}) async {
    await _col().doc(id).update({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
    });
  }

  Future<void> deleteNote(String id) async {
    await _col().doc(id).delete();
  }
}
