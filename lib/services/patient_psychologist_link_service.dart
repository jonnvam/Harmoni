import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/psychologist.dart';
import 'package:flutter_application_1/services/public_psychologists_service.dart';

class PatientPsychologistLinkService {
  PatientPsychologistLinkService._();

  static final instance = PatientPsychologistLinkService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  Stream<Psychologist?> watchLinkedPsychologist() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('vinculosPacientePsicologo')
        .where('patientUid', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
      final activeLinks = snapshot.docs.where((doc) {
        final data = doc.data();
        return data['status'] == 'activo';
      }).toList();

      if (activeLinks.isEmpty) {
        return null;
      }

      activeLinks.sort((a, b) {
        final aDate = a.data()['updatedAt'];
        final bDate = b.data()['updatedAt'];

        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }

        return 0;
      });

      final linkData = activeLinks.first.data();
      final psychologistUid = (linkData['psychologistUid'] ?? '').toString();

      if (psychologistUid.isEmpty) {
        return null;
      }

      return PublicPsychologistsService.instance
          .fetchPublicPsychologistByUid(psychologistUid);
    });
  }
}