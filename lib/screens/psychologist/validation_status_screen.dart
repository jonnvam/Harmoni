import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ValidationStatusScreen extends StatelessWidget {
  const ValidationStatusScreen({super.key});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'VALIDADO_OFICIAL':
        return Colors.green;
      case 'PREVALIDADO':
        return Colors.blue;
      case 'PENDIENTE_REVISION_SELFIE':
        return Colors.orange;
      case 'RECHAZADO':
      case 'RECHAZADO_SELFIE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _estadoTexto(String estado) {
    switch (estado) {
      case 'VALIDADO_OFICIAL':
        return 'Validado oficialmente';
      case 'PREVALIDADO':
        return 'Prevalidado';
      case 'PENDIENTE_REVISION_SELFIE':
        return 'Pendiente de revisión';
      case 'RECHAZADO':
      case 'RECHAZADO_SELFIE':
        return 'Rechazado';
      default:
        return 'Sin verificar';
    }
  }

  String _descripcion(String estado, bool puedeEjercer) {
    if (estado == 'VALIDADO_OFICIAL' && puedeEjercer) {
      return 'Validación completa. Ya puedes ejercer dentro de la app.';
    }
    if (estado == 'PREVALIDADO') {
      return 'Tus documentos fueron validados. Falta completar la selfie desde la pantalla de verificación.';
    }
    if (estado == 'PENDIENTE_REVISION_SELFIE') {
      return 'La comparación facial requiere revisión manual.';
    }
    if (estado == 'RECHAZADO' || estado == 'RECHAZADO_SELFIE') {
      return 'No se pudo completar la validación.';
    }
    return 'Aún no has completado el proceso.';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver tu estado.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Estado de validación'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('verificacionesProfesionales')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Aún no has enviado tu verificación.'),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final estado = data['estadoValidacion'] ?? 'SIN_VERIFICAR';
          final puedeEjercer = data['puedeEjercer'] ?? false;
          final motivo = data['motivoRechazo'] ?? '';
          final nombreIne = data['nombreCompletoIne'] ?? '';
          final nombreBuho = data['nombreBuholegal'] ?? '';
          final cedula = data['cedulaBuholegal'] ?? '';
          final carrera = data['carreraBuholegal'] ?? '';
          final selfieRealizada = data['selfieRealizada'] ?? false;
          final livenessPassed = data['livenessPassed'] ?? false;
          final faceMatchPassed = data['faceMatchPassed'] ?? false;
          final faceMatchScore = data['faceMatchScore'] ?? 0.0;
          final modelo = data['modeloFaceMatch'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _estadoColor(estado).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _estadoColor(estado)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _estadoTexto(estado),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _estadoColor(estado),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_descripcion(estado, puedeEjercer)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Nombre INE: $nombreIne'),
                const SizedBox(height: 8),
                Text('Nombre Búho Legal: $nombreBuho'),
                const SizedBox(height: 8),
                Text('Cédula: $cedula'),
                const SizedBox(height: 8),
                Text('Carrera: $carrera'),
                const SizedBox(height: 16),
                Text('Selfie realizada: ${selfieRealizada ? "Sí" : "No"}'),
                const SizedBox(height: 8),
                Text('Prueba de vida: ${livenessPassed ? "Aprobada" : "Pendiente"}'),
                const SizedBox(height: 8),
                Text('Face match: ${faceMatchPassed ? "Aprobado" : "No aprobado"}'),
                const SizedBox(height: 8),
                Text('Score facial: $faceMatchScore'),
                const SizedBox(height: 8),
                Text('Modelo: $modelo'),
                if ((estado == 'RECHAZADO' || estado == 'RECHAZADO_SELFIE') &&
                    motivo.toString().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Motivo: $motivo',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}