import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PsychologistAppointmentModel {
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

  const PsychologistAppointmentModel({
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
  });

  factory PsychologistAppointmentModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final start = data['fechaInicio'];
    final end = data['fechaFin'];

    return PsychologistAppointmentModel(
      id: doc.id,
      patientUid: (data['patientUid'] ?? '').toString(),
      psychologistUid: (data['psychologistUid'] ?? '').toString(),
      patientName: (data['patientName'] ?? 'Paciente').toString(),
      psychologistName: (data['psychologistName'] ?? '').toString(),
      fechaInicio: start is Timestamp ? start.toDate() : DateTime.now(),
      fechaFin: end is Timestamp ? end.toDate() : DateTime.now(),
      modalidad: (data['modalidad'] ?? '').toString(),
      estado: (data['estado'] ?? 'solicitada').toString(),
      motivoConsulta: (data['motivoConsulta'] ?? '').toString(),
      precio: data['precio'] is int
          ? data['precio'] as int
          : data['precio'] is num
              ? (data['precio'] as num).toInt()
              : 0,
      moneda: (data['moneda'] ?? 'MXN').toString(),
      metodoPago: (data['metodoPago'] ?? 'pendiente').toString(),
      pagoEstado: (data['pagoEstado'] ?? 'pendiente').toString(),
    );
  }
}

class PsychologistAppointmentsService {
  PsychologistAppointmentsService._();

  static final instance = PsychologistAppointmentsService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  Stream<List<PsychologistAppointmentModel>> watchMyAppointments() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _db
        .collection('citas')
        .where('psychologistUid', isEqualTo: uid)
        .orderBy('fechaInicio')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(PsychologistAppointmentModel.fromDoc)
          .toList();
    });
  }

  Future<void> confirmAppointment({
    required PsychologistAppointmentModel appointment,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes confirmar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'solicitada') {
      throw ArgumentError('Solo puedes confirmar citas solicitadas.');
    }

    final citaRef = _db.collection('citas').doc(appointment.id);

    final vinculoId = '${appointment.patientUid}_${appointment.psychologistUid}';

    final vinculoRef =
        _db.collection('vinculosPacientePsicologo').doc(vinculoId);

    final batch = _db.batch();

    batch.update(citaRef, {
      'estado': 'confirmada',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      vinculoRef,
      {
        'vinculoId': vinculoId,
        'patientUid': appointment.patientUid,
        'psychologistUid': appointment.psychologistUid,
        'patientName': appointment.patientName,
        'psychologistName': appointment.psychologistName,
        'status': 'activo',
        'origen': 'cita_confirmada',
        'primeraCitaId': appointment.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> rejectAppointment({
    required PsychologistAppointmentModel appointment,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Debes iniciar sesión.',
      );
    }

    if (appointment.psychologistUid != uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'No puedes rechazar una cita que no te pertenece.',
      );
    }

    if (appointment.estado != 'solicitada') {
      throw ArgumentError('Solo puedes rechazar citas solicitadas.');
    }

    await _db.collection('citas').doc(appointment.id).update({
      'estado': 'rechazada',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}