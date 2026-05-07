import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentService {
  AppointmentService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  static final instance = AppointmentService();

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _citasCol =>
      _db.collection('citas');

  Future<DocumentSnapshot<Map<String, dynamic>>?> getAssignedPsychologist(
    String patientId,
  ) async {
    final snap = await _citasCol
        .where('pacienteId', isEqualTo: patientId)
        .where('estado', whereIn: const ['pendiente', 'confirmada'])
        .orderBy('fecha', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final cita = snap.docs.first.data();
    final psychologistId = (cita['psicologoId'] ?? '').toString().trim();
    if (psychologistId.isEmpty) return null;

    final doc = await _db.collection('psicologos').doc(psychologistId).get();
    if (!doc.exists) return null;

    return doc;
  }

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getAssignedPatients(
    String psychologistId,
  ) {
    return _citasCol
        .where('psicologoId', isEqualTo: psychologistId)
        .where('estado', whereIn: const ['pendiente', 'confirmada'])
        .snapshots()
        .asyncMap((snap) async {
      final patientIds = <String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final pid = (data['pacienteId'] ?? '').toString().trim();
        if (pid.isNotEmpty) patientIds.add(pid);
      }

      if (patientIds.isEmpty) return <DocumentSnapshot<Map<String, dynamic>>>[];

      final futures = patientIds.map(_fetchPatientDoc).toList();
      final docs = await Future.wait(futures);
      return docs.whereType<DocumentSnapshot<Map<String, dynamic>>>().toList();
    });
  }

  Future<void> createAppointment({
    required String patientId,
    required String psychologistId,
    required DateTime fecha,
  }) async {
    final docId = '${patientId}_${psychologistId}_${fecha.toIso8601String()}';
    final ref = _citasCol.doc(docId);

    final patient = _auth.currentUser;
    final patientName =
        (patient?.displayName ?? '').trim().isNotEmpty
            ? patient!.displayName!.trim()
            : 'Paciente';

    final psychologistDoc =
        await _db.collection('psicologos').doc(psychologistId).get();

    final psychologistName =
        (psychologistDoc.data()?['displayName'] ?? '').toString().trim();
    final psychologistPhotoUrl =
        (psychologistDoc.data()?['photoUrl'] ?? '').toString().trim();

    await _db.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) return;

      tx.set(ref, {
        'pacienteId': patientId,
        'psicologoId': psychologistId,
        'fecha': Timestamp.fromDate(fecha),
        'estado': 'pendiente',
        'creadaEn': FieldValue.serverTimestamp(),
        'patientName': patientName,
        if (psychologistName.isNotEmpty) 'psychologistName': psychologistName,
        if (psychologistPhotoUrl.isNotEmpty)
          'psychologistPhotoUrl': psychologistPhotoUrl,
      });
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _fetchPatientDoc(
    String patientId,
  ) async {
    final usuariosDoc = await _db.collection('usuarios').doc(patientId).get();
    if (usuariosDoc.exists) return usuariosDoc;

    final usersDoc = await _db.collection('users').doc(patientId).get();
    if (usersDoc.exists) return usersDoc;

    final pacientesDoc =
        await _db.collection('usuariosPacientes').doc(patientId).get();
    if (pacientesDoc.exists) return pacientesDoc;

    return null;
  }
}
