import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LinkedPatientModel {
  final String vinculoId;
  final String patientUid;
  final String psychologistUid;
  final String patientName;
  final String psychologistName;
  final String status;
  final String origen;
  final String primeraCitaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LinkedPatientModel({
    required this.vinculoId,
    required this.patientUid,
    required this.psychologistUid,
    required this.patientName,
    required this.psychologistName,
    required this.status,
    required this.origen,
    required this.primeraCitaId,
    this.createdAt,
    this.updatedAt,
  });

  factory LinkedPatientModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final created = data['createdAt'];
    final updated = data['updatedAt'];

    return LinkedPatientModel(
      vinculoId: (data['vinculoId'] ?? doc.id).toString(),
      patientUid: (data['patientUid'] ?? '').toString(),
      psychologistUid: (data['psychologistUid'] ?? '').toString(),
      patientName: (data['patientName'] ?? 'Paciente').toString(),
      psychologistName: (data['psychologistName'] ?? '').toString(),
      status: (data['status'] ?? 'activo').toString(),
      origen: (data['origen'] ?? '').toString(),
      primeraCitaId: (data['primeraCitaId'] ?? '').toString(),
      createdAt: created is Timestamp ? created.toDate() : null,
      updatedAt: updated is Timestamp ? updated.toDate() : null,
    );
  }
}

class PsychologistPatientsService {
  PsychologistPatientsService._();

  static final instance = PsychologistPatientsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  Stream<List<LinkedPatientModel>> watchMyLinkedPatients() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('vinculosPacientePsicologo')
        .where('psychologistUid', isEqualTo: uid)
        .where('status', isEqualTo: 'activo')
        .snapshots()
        .map((snapshot) {
          final patients =
              snapshot.docs
                  .map(LinkedPatientModel.fromDoc)
                  .where((patient) => patient.status == 'activo')
                  .toList();

          patients.sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt ?? DateTime(2000);
            final bDate = b.updatedAt ?? b.createdAt ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });

          return patients;
        });
  }
}
