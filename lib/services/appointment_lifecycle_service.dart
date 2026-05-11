import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentLifecycleService {
  AppointmentLifecycleService._();

  static final instance = AppointmentLifecycleService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> setMeetUrl({
    required String appointmentId,
    required String meetUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No hay una sesión activa.',
      );
    }

    await _db.collection('citas').doc(appointmentId).update({
      'meetUrl': meetUrl.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeAppointment({
    required String appointmentId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No hay una sesión activa.',
      );
    }

    await _db.collection('citas').doc(appointmentId).update({
      'estado': 'completada',
      'completedAt': FieldValue.serverTimestamp(),
      'completedBy': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markNoShow({
    required String appointmentId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No hay una sesión activa.',
      );
    }

    await _db.collection('citas').doc(appointmentId).update({
      'estado': 'no_asistio',
      'noShowAt': FieldValue.serverTimestamp(),
      'markedBy': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelAppointment({
    required String appointmentId,
    required String currentUserRole,
    String? reason,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'No hay una sesión activa.',
      );
    }

    final estadoCancelacion = currentUserRole == 'psicologo'
        ? 'cancelada_por_psicologo'
        : 'cancelada_por_paciente';

    await _db.collection('citas').doc(appointmentId).update({
      'estado': estadoCancelacion,
      'cancelledAt': FieldValue.serverTimestamp(),
      'cancelledBy': user.uid,
      'cancelReason': reason?.trim().isEmpty == true ? null : reason?.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}