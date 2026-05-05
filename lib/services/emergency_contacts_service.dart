import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_1/services/user_profile_service.dart';

class EmergencyContactModel {
  final String id;
  final String uid;
  final String name;
  final String phone;
  final String? relation;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const EmergencyContactModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.phone,
    this.relation,
    this.createdAt,
    this.updatedAt,
  });

  factory EmergencyContactModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return EmergencyContactModel(
      id: doc.id,
      uid: (data['uid'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      relation: data['relation'] == null ? null : data['relation'].toString(),
      createdAt:
          data['createdAt'] is Timestamp
              ? data['createdAt'] as Timestamp
              : null,
      updatedAt:
          data['updatedAt'] is Timestamp
              ? data['updatedAt'] as Timestamp
              : null,
    );
  }
}

class EmergencyContactsService {
  EmergencyContactsService._();

  static final instance = EmergencyContactsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _contactsCol(String uid) {
    return _db
        .collection(UserProfileService.collectionUsuariosPacientes)
        .doc(uid)
        .collection('emergencyContacts');
  }

  Stream<List<EmergencyContactModel>> contactsStream() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _contactsCol(
      uid,
    ).orderBy('createdAt', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map(EmergencyContactModel.fromDoc).where((contact) {
        return contact.uid == uid &&
            contact.name.trim().isNotEmpty &&
            contact.phone.trim().isNotEmpty;
      }).toList();
    });
  }

  Future<void> addContact({
    required String name,
    required String phone,
    String? relation,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    final cleanName = _cleanName(name);
    final cleanPhone = sanitizePhone(phone);
    final cleanRelation = _cleanOptional(relation);

    _validateContact(
      name: cleanName,
      phone: cleanPhone,
      relation: cleanRelation,
    );

    await _contactsCol(uid).add({
      'uid': uid,
      'name': cleanName,
      'phone': cleanPhone,
      'relation': cleanRelation,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateContact({
    required String contactId,
    required String name,
    required String phone,
    String? relation,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    final cleanName = _cleanName(name);
    final cleanPhone = sanitizePhone(phone);
    final cleanRelation = _cleanOptional(relation);

    _validateContact(
      name: cleanName,
      phone: cleanPhone,
      relation: cleanRelation,
    );

    await _contactsCol(uid).doc(contactId).update({
      'name': cleanName,
      'phone': cleanPhone,
      'relation': cleanRelation,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContact(String contactId) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    await _contactsCol(uid).doc(contactId).delete();
  }

  String sanitizePhone(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String phoneForDialer(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _cleanName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String? _cleanOptional(String? value) {
    final clean = value?.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean == null || clean.isEmpty) return null;
    return clean;
  }

  void _validateContact({
    required String name,
    required String phone,
    required String? relation,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('El nombre es obligatorio.');
    }

    if (phone.isEmpty) {
      throw ArgumentError('El teléfono es obligatorio.');
    }

    if (name.length > 80) {
      throw ArgumentError('El nombre es demasiado largo.');
    }

    if (relation != null && relation.length > 60) {
      throw ArgumentError('La relación es demasiado larga.');
    }

    final phoneRegex = RegExp(r'^[0-9+\-\s()]{7,20}$');

    if (!phoneRegex.hasMatch(phone)) {
      throw ArgumentError(
        'El teléfono solo puede contener números, +, espacios, guiones o paréntesis.',
      );
    }

    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 10) {
      throw ArgumentError('Ingresa un número de 10 dígitos.');
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(digitsOnly)) {
      throw ArgumentError('El teléfono solo debe contener números.');
    }
  }
}
