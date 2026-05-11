import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientAppointmentModel {
  final String id;
  final String patientUid;
  final String psychologistUid;
  final String patientName;
  final String psychologistName;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String modalidad;
  final String estado;
  final String motivoConsulta;
  final int precio;
  final String moneda;
  final String metodoPago;
  final String pagoEstado;
  final String meetUrl;

  const PatientAppointmentModel({
    required this.id,
    required this.patientUid,
    required this.psychologistUid,
    required this.patientName,
    required this.psychologistName,
    required this.fechaInicio,
    required this.fechaFin,
    required this.modalidad,
    required this.estado,
    required this.motivoConsulta,
    required this.precio,
    required this.moneda,
    required this.metodoPago,
    required this.pagoEstado,
    required this.meetUrl,
  });

  factory PatientAppointmentModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final start = data['fechaInicio'];
    final end = data['fechaFin'];

    return PatientAppointmentModel(
      id: doc.id,
      patientUid: (data['patientUid'] ?? '').toString(),
      psychologistUid: (data['psychologistUid'] ?? '').toString(),
      patientName: (data['patientName'] ?? 'Paciente').toString(),
      psychologistName: (data['psychologistName'] ?? 'Psicólogo').toString(),
      fechaInicio: start is Timestamp ? start.toDate() : DateTime.now(),
      fechaFin: end is Timestamp ? end.toDate() : DateTime.now(),
      modalidad: (data['modalidad'] ?? '').toString(),
      estado: (data['estado'] ?? 'solicitada').toString(),
      motivoConsulta: (data['motivoConsulta'] ?? '').toString(),
      precio:
          data['precio'] is int
              ? data['precio'] as int
              : data['precio'] is num
              ? (data['precio'] as num).toInt()
              : 0,
      moneda: (data['moneda'] ?? 'MXN').toString(),
      metodoPago: (data['metodoPago'] ?? 'pendiente').toString(),
      pagoEstado: (data['pagoEstado'] ?? 'pendiente').toString(),
      meetUrl: (data['meetUrl'] ?? '').toString(),
    );
  }
}

class PatientAppointmentsService {
  PatientAppointmentsService._();

  static final instance = PatientAppointmentsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  Future<void> cancelAppointment({
  required PatientAppointmentModel appointment,
  String? reason,
}) async {
  final uid = currentUid;

  if (uid == null) {
    throw FirebaseAuthException(
      code: 'not-authenticated',
      message: 'Debes iniciar sesión.',
    );
  }

  if (appointment.patientUid != uid) {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'No puedes cancelar una cita que no te pertenece.',
    );
  }

  if (appointment.estado != 'confirmada') {
    throw ArgumentError('Solo puedes cancelar citas confirmadas.');
  }

  final cleanReason = reason?.trim();

  await _db.collection('citas').doc(appointment.id).update({
    'estado': 'cancelada_por_paciente',
    'cancelledAt': FieldValue.serverTimestamp(),
    'cancelledBy': uid,
    'cancelReason':
        cleanReason == null || cleanReason.isEmpty ? null : cleanReason,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

  Stream<List<PatientAppointmentModel>> watchMyAppointments() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('citas')
        .where('patientUid', isEqualTo: uid)
        .orderBy('fechaInicio', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(PatientAppointmentModel.fromDoc).toList();
        });
  }
}
